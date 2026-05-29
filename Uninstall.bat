@echo off

:: Prompt for UAC (Administrator)
:: We need this to remove OniXPerf because it's set as an elevated task (Needs Administrator)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator elevation required to uninstall. Prompting...
    set "params=%*"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\uac.vbs"
    "%temp%\uac.vbs"
    del "%temp%\uac.vbs"
    exit /b
)

set TASKNAME=OniXPerf_Agent

:: Check if task exists before attempting to delete
schtasks /query /tn "%TASKNAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Stopping OniXPerf process if it's running...
    taskkill /f /im onixperf.exe >nul 2>&1
    
    echo Removing OniXPerf scheduled task...
    schtasks /delete /tn "%TASKNAME%" /f >nul 2>&1
    
    cls
    echo OniXPerf has been successfully uninstalled.
    echo All background tasks have been removed.
    echo.
    echo Note: The actual files remain in this folder and can be safely deleted manually.
    echo.
    echo OniXPerf : Made by its.pulse
) else (
    echo OniXPerf is not installed on this system. Nothing to remove.
)

pause
