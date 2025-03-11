@echo off

setlocal enabledelayedexpansion

if not exist ".git" (
    echo This script must be run in the root of the git repository.
    exit /b 1
)

if not exist ".git\hooks" (
    mkdir ".git\hooks"
)
for %%f in (Tools\GitHook\hooks\\*) do (
    set "hook_name=%%~nxf"
    @echo off
    copy /Y "%%f" ".git\hooks\!hook_name!" > NUL
    echo Installed hook: !hook_name!
)

echo All hooks installed successfully.

pause