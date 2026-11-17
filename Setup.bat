@echo off

# install-hooks

setlocal enabledelayedexpansion

if not exist ".git" (
    echo This script must be run in the root of the git repository.
    exit /b 1
)

REM -- Project plugins are tracked as top-level git submodules.
REM    A plain clone leaves Plugins/UE* empty; always initialise them.
echo Initializing plugin submodules...
git submodule update --init --recursive
if errorlevel 1 (
    echo ERROR: failed to initialize plugin submodules.
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

echo Install ptvsd for Python develop.
..\AnnUnrealEngine\Engine\Binaries\ThirdParty\Python3\Win64\python -m pip install --upgrade ptvsd
