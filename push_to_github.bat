@echo off
rem push_to_github.bat — initializes repo, commits, and pushes to GitHub
rem Usage: double-click or run from cmd in this folder

cd /d "%~dp0"
echo Working directory: %cd%

git --version >nul 2>&1
if errorlevel 1 (
  echo Git not found on PATH. Install Git from https://git-scm.com/downloads and re-run this script.
  pause
  exit /b 1
)

rem Initialize repo if not already a git repository
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 (
  echo Initializing git repository...
  git init
) else (
  echo Git repository already initialized.
)

rem Ensure user.name and user.email are set (local config)
for /f "usebackq delims=" %%A in (`git config user.name 2^>nul`) do set GIT_NAME=%%A
for /f "usebackq delims=" %%A in (`git config user.email 2^>nul`) do set GIT_EMAIL=%%A

if "%GIT_NAME%"=="" (
  set /p GIT_NAME="Enter git user.name (will be set locally): "
  if not "%GIT_NAME%"=="" git config user.name "%GIT_NAME%"
)

if "%GIT_EMAIL%"=="" (
  set /p GIT_EMAIL="Enter git user.email (will be set locally): "
  if not "%GIT_EMAIL%"=="" git config user.email "%GIT_EMAIL%"
)

rem Stage and commit
git add -A
git commit -m "Initial commit" 2>nul
if errorlevel 1 (
  echo No commit was created (maybe no changes or commit failed). Continuing...
) else (
  echo Commit created.
)

rem Ensure main branch name
git branch --show-current >nul 2>&1
for /f "usebackq delims=" %%B in (`git rev-parse --abbrev-ref HEAD 2^>nul`) do set CUR_BRANCH=%%B
if "%CUR_BRANCH%"=="" (
  git branch -M main
) else (
  git branch -M main >nul 2>&1
)

echo.
echo Now add the remote repository URL (HTTPS or SSH).
set /p REPOURL="Enter remote repository URL (or leave empty to skip push): "
if "%REPOURL%"=="" (
  echo Skipping remote add/push. You can add a remote later with:
  echo   git remote add origin https://github.com/username/repo.git
  pause
  exit /b 0
)

rem Add or update origin
git remote add origin %REPOURL% 2>nul || git remote set-url origin %REPOURL%

echo Pushing to origin main...
git push -u origin main
if errorlevel 1 (
  echo Push failed. If using HTTPS, you may be prompted for credentials or need a PAT. If using SSH, ensure your SSH key is added to GitHub.
) else (
  echo Push succeeded.
)

pause
