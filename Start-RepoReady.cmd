@echo off
setlocal
cd /d "%~dp0"
where pwsh >nul 2>nul
if %errorlevel%==0 (
  pwsh -NoProfile -File "%~dp0Start-RepoReady.ps1" %*
) else (
  powershell.exe -NoProfile -File "%~dp0Start-RepoReady.ps1" %*
)
echo.
if not defined REPOREADY_NO_PAUSE pause
