$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsDir = Join-Path $RepoDir "skills"

function Install-Skills($Dest) {
    Write-Host "Installing to $Dest\skills\ ..."
    $target = Join-Path $Dest "skills"
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    foreach ($skill in Get-ChildItem -Directory $SkillsDir) {
        $destSkill = Join-Path $target $skill.Name
        Copy-Item -Recurse -Force $skill.FullName $destSkill
        Write-Host "  v $($skill.Name)"
    }
}

Install-Skills (Join-Path $env:USERPROFILE ".claude")
Install-Skills (Join-Path $env:USERPROFILE ".copilot")

Write-Host "Done."
