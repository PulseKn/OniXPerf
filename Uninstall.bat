@echo off

:: Prompt for UAC (Administrator)
:: We need this because OniXPerf's task requires Administrator to both carry out its functionality and embed itself in startup
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator elevation required. Prompting...
    set "params=%*"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\uac.vbs"
    "%temp%\uac.vbs"
    del "%temp%\uac.vbs"
    exit /b
)

:: Name = OniXPerf_Agent
set TASKNAME=OniXPerf_Agent
set EXEPATH=%~dp0onixperf.exe

:: Check if task already exists
schtasks /query /tn "%TASKNAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo OniXPerf : '%TASKNAME%' already exists. Skipping installation.
    echo If you wish to reinstall it, run Uninstall.bat first.
    pause
    exit /b
)

:: Create elevated scheduled task
:: Elevation is required since OniXPerf modifies other processes' Windows configuration settings
schtasks /create ^
  /tn "%TASKNAME%" ^
  /f ^
  /rl highest ^
  /sc onlogon ^
  /tr "\"%EXEPATH%\"" ^
  /ru "%USERNAME%"

cls
echo OniXPerf has been successfully installed.
echo.
echo OniXPerf v0.3 BETA : Made by its.pulse
echo OniXPerf will run silently in the background and start with your computer.
echo To uninstall, run Uninstall.bat
pause
