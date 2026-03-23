---
name: task-agent
description: >
  Reads a list of tasks in a yaml to be done in certain github repos. Agents clone the repo, do the task,
  commit the changes and create a PR. Not to be called automatically by Claude by any means.
tools: Bash, Read, Write, Edit, Glob, Grep, Agent, mcp__github__search_repositories, mcp__github__create_pull_request
---

# Task Agent

Each invocation does **exactly one task**: the next pending item from `agent-tasks.yml`.
State is persisted in `agent-tasks-state.yml` in the same directory, so reruns always
pick up where the previous run left off.

**Prereqs:** `python3`, `git`.

---

## Phase 1 — Load config and state

### 1.1 Find and parse the config

Look for `agent-tasks.yml` (or `agent-tasks.yaml`) in the current directory, or use the
path the user specified. Stop and show the expected format if not found.

```bash
python3 - <<'EOF'
import yaml, json, os
for name in ['agent-tasks.yml', 'agent-tasks.yaml']:
    if os.path.exists(name):
        with open(name) as f:
            print(json.dumps(yaml.safe_load(f), indent=2))
        break
else:
    print("NOT_FOUND")
EOF
```

**Expected config format:**
```yaml
projects:
  - repo: "owner/repo-name"
    tasks:
      - "Add unit tests for the authentication module"
      - "Fix the typo in README.md"
  - repo: "another-owner/another-repo"
    tasks:
      - "Refactor the API layer to use async/await"
```

### 1.2 Load state

Read `agent-tasks-state.yml` if it exists; treat it as empty if it doesn't.

```bash
python3 - <<'EOF'
import yaml, json, os
if os.path.exists('agent-tasks-state.yml'):
    with open('agent-tasks-state.yml') as f:
        print(json.dumps(yaml.safe_load(f) or {}, indent=2))
else:
    print("{}")
EOF
```

The state file records every task that has been completed:

```yaml
# agent-tasks-state.yml — managed automatically, do not edit by hand
completed:
  - repo: "owner/repo-name"
    task: "Add unit tests for the authentication module"
    branch: "task/add-unit-tests-abc123"
    pr_url: "https://github.com/owner/repo-name/pull/42"
    date: "2026-03-20"
```

### 1.3 Pick the next pending task

Walk the config in order (project by project, task by task) and find the first task that
does NOT appear in `state.completed` (matched by `repo` + `task` text). That is today's
task.

If every task is already completed, tell the user — all done, nothing left to do.

Print the chosen task clearly before proceeding:
```
Today's task:
  Repo: owner/repo-name
  Task: "Add unit tests for the authentication module"
```

---

## Phase 2 — Prepare the repo

Only clone the **one repo** containing today's task if not already cloned locally.
Each repo should be worked on in `/tmp/multi-repo-tasks/REPO_NAME` so the local clone
is reused across runs.

Spawn a new agent to do this phase.

### 2.1 Determine the default branch

Call `mcp__github__search_repositories` with `query: "repo:OWNER/REPO_NAME"` and
`minimal_output: false`. Read the `default_branch` field from the returned repository object.

### 2.2 Clone or update the repo locally

```bash
LOCAL_PATH="/tmp/multi-repo-tasks/REPO_NAME"

if [ -d "$LOCAL_PATH/.git" ]; then
  git -C "$LOCAL_PATH" fetch origin
  git -C "$LOCAL_PATH" checkout DEFAULT_BRANCH
  git -C "$LOCAL_PATH" reset --hard origin/DEFAULT_BRANCH
else
  mkdir -p /tmp/multi-repo-tasks
  git clone "https://github.com/OWNER/REPO_NAME.git" "$LOCAL_PATH"
fi
```

---

## Phase 3 — Execute the task

Spawn a new agent to do this phase.

### 3.1 Create a branch name

Slugify the task text and append a short hash for uniqueness:

```bash
TASK="<today's task text>"
SLUG=$(echo "$TASK" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g' | cut -c1-45)
HASH=$(echo "$TASK" | python3 -c "import sys,hashlib; print(hashlib.md5(sys.stdin.read().encode()).hexdigest()[:6])")
BRANCH="task/${SLUG}-${HASH}"
```

### 3.2 Create the branch

```bash
git -C "$LOCAL_PATH" checkout DEFAULT_BRANCH
git -C "$LOCAL_PATH" checkout -b "$BRANCH"
```

### 3.3 Read relevant references

Before spawning the subagent, read the reference files from the skill's `/references`
directory that are relevant to the task's technology stack. Include their full content
verbatim in the subagent prompt below.

For example:
- Task involves JavaScript/npm → read `/references/npm.md`
- Task involves Java/Maven → read `/references/maven.md` (if it exists)

Read only files that are relevant. Do not guess — check what files exist first with Glob.

### 3.4 Spawn a new subagent to implement the task

Include the content of the relevant reference files (from 3.3) in the prompt under a
"## Reference guides" section.

```
You are working on a git repository located at: LOCAL_PATH
Repository: OWNER/REPO_NAME
Current branch: BRANCH_NAME

Your task:
TASK_DESCRIPTION

## Reference guides

REFERENCE_FILE_CONTENTS (full content of each relevant file from /references)

Instructions:
1. Read the codebase to understand its structure and conventions.
2. Output a list of reference filenames you will use from the /references directory, and their purpose.
3. Implement the task — be focused, do only what is asked.
   Follow the reference guides above for the correct tooling and commands.
4. Stage your changes: git -C LOCAL_PATH add -A
5. Commit with a clear message: git -C LOCAL_PATH commit -m "YOUR_MESSAGE"
   If nothing needed to change (task already done), say so explicitly instead.
6. Do NOT push — the caller handles that.

Return a short paragraph summarising what you changed and why.
```

### 3.5 Push the branch

```bash
git -C "$LOCAL_PATH" push origin "$BRANCH" --force-with-lease
```

If there are no commits to push, mark the task as "nothing to commit" and skip to Phase 4
(still update state so we don't retry it tomorrow).

### 3.6 Open the PR

Call `mcp__github__create_pull_request` with:
- `owner`: OWNER
- `repo`: REPO_NAME
- `title`: TASK_DESCRIPTION
- `head`: BRANCH
- `base`: DEFAULT_BRANCH
- `body`:
  ```
  ## Summary

  AGENT_SUMMARY

  ---
  *Opened by task-agent via Claude Code.*
  ```

Capture the `html_url` field from the response as the PR URL.

---

## Phase 4 — Update state and report

### 4.1 Remove task from agent-tasks.yml

Remove the completed task entry from `agent-tasks.yml` using python3 so the file stays
valid YAML. If a project's task list becomes empty after removal, remove that project
entry too.

```bash
python3 - <<'EOF'
import yaml

with open('agent-tasks.yml') as f:
    config = yaml.safe_load(f)

for project in config['projects']:
    if project['repo'] == 'OWNER/REPO_NAME':
        project['tasks'] = [t for t in project['tasks'] if t != 'TASK_DESCRIPTION']

config['projects'] = [p for p in config['projects'] if p.get('tasks')]

with open('agent-tasks.yml', 'w') as f:
    yaml.dump(config, f, default_flow_style=False, allow_unicode=True)
EOF
```

### 4.2 Append to state file

Add the completed task to `agent-tasks-state.yml`. Use `Edit` if the file exists, `Write`
if creating it fresh. Never overwrite existing entries — only append.

```yaml
# New entry to append under `completed:`
- repo: "OWNER/REPO_NAME"
  task: "TASK_DESCRIPTION"
  branch: "BRANCH_NAME"
  pr_url: "PR_URL_OR_none"
  date: "TODAY_ISO_DATE"
```

### 4.3 Print the summary

```
## Task — Done

✅  owner/repo-name
    Task:   "Add unit tests for the authentication module"
    Branch: task/add-unit-tests-abc123
    PR:     https://github.com/owner/repo-name/pull/42

Progress: 1 of 5 tasks completed across 2 repos.
Next up:  "Fix the typo in README.md" (owner/repo-name)
```

- Show **progress** as completed/total across all projects.
- Show **next up** so the user knows what the next run will do.
- If this was the last task, congratulate the user — all done.


## Rules
- Reference files in `/references` must be read **before** spawning the Phase 3 subagent and injected into its prompt. The subagent has no memory of the skill directory — passing content explicitly is the only way it can follow the correct tooling conventions.