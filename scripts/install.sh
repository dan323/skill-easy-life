#!/usr/bin/env sh
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"

install_skills() {
  DEST="$1"
  echo "Installing to $DEST/skills/ ..."
  mkdir -p "$DEST/skills"
  for skill in "$SKILLS_DIR"/*/; do
    name="$(basename "$skill")"
    cp -r "$skill" "$DEST/skills/$name"
    echo "  ✓ $name"
  done
}

install_skills "$HOME/.claude"
install_skills "$HOME/.copilot"

echo "Done."
