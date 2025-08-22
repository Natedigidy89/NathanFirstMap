#------------------------------------------
# push-to-git.ps1
# Simple PowerShell script to push local changes to GitHub
#------------------------------------------

# Make sure we are in a git repo
$gitCheck = git rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: This folder is not a Git repository." -ForegroundColor Red
    exit
}

# Check if 'origin' remote exists
$remoteCheck = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: No 'origin' remote found. Please add a remote first." -ForegroundColor Red
    exit
} else {
    Write-Host "Remote 'origin' found: $remoteCheck"
}

# Prompt for commit message
$commitMessage = Read-Host "Enter your commit message"

# Stage all changes
git add .

# Commit changes
git commit -m "$commitMessage"

if ($LASTEXITCODE -eq 0) {
    Write-Host "Commit successful." -ForegroundColor Green
} else {
    Write-Host "Nothing to commit." -ForegroundColor Yellow
}

# Push to remote main branch
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "Push successful!" -ForegroundColor Green
} else {
    Write-Host "Push failed. Check remote repository and authentication." -ForegroundColor Red
}
