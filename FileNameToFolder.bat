@echo off
setlocal

:: Set the folder path to pass as an argument
set "targetFolder=P:\Library\Audiobooks"

:: Do NOT use -sourceFolder anymore
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0FileNameToFolder.ps1" "%targetFolder%"

pause



