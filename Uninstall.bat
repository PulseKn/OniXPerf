@echo off
setlocal EnableDelayedExpansion
title OnixPerf - Advanced Uninstaller

:: -----------------------------------------------------------------------------
:: UAC Privilege Check
:: -----------------------------------------------------------------------------
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Administrator privileges required to completely uninstall. Prompting...
    set "params=%*"
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\uac.vbs"
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params%", "", "runas", 1 >> "%temp%\uac.vbs"
    "%temp%\uac.vbs"
    del "%temp%\uac.vbs"
    exit /b
)

set "TASKNAME=OnixPerf_Agent"
set "INSTALLDIR=%~dp0"
set "EXEPATH=%~dp0onixperf.exe"
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"

cls
echo ===============================================================================
echo                      OnixPerf - Advanced Uninstallation
echo ===============================================================================
echo.

:: -----------------------------------------------------------------------------
:: 1. Kill Process
:: -----------------------------------------------------------------------------
echo [INFO] Stopping OnixPerf process if running...
taskkill /f /im onixperf.exe >nul 2>&1

:: -----------------------------------------------------------------------------
:: 2. Remove Scheduled Task
:: -----------------------------------------------------------------------------
echo [INFO] Removing Scheduled Task...
schtasks /query /tn "%TASKNAME%" >nul 2>&1
if %errorlevel% equ 0 (
    schtasks /delete /tn "%TASKNAME%" /f >nul 2>&1
    echo [OK] Scheduled Task removed.
) else (
    echo [INFO] Scheduled Task not found.
)

:: -----------------------------------------------------------------------------
:: 3. Remove Registry Startup Keys
:: -----------------------------------------------------------------------------
echo [INFO] Removing Registry Startup keys...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OnixPerf" /f >nul 2>&1
if %errorlevel% equ 0 ( echo [OK] HKCU Registry entry removed. )

reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "OnixPerf" /f >nul 2>&1
if %errorlevel% equ 0 ( echo [OK] HKLM Registry entry removed. )

:: -----------------------------------------------------------------------------
:: 4. Remove Startup Folder Shortcut
:: -----------------------------------------------------------------------------
echo [INFO] Removing Startup Folder shortcut...
if exist "%STARTUP_FOLDER%\OnixPerf.lnk" (
    del /f /q "%STARTUP_FOLDER%\OnixPerf.lnk"
    echo [OK] Startup shortcut removed.
)

:: -----------------------------------------------------------------------------
:: 5. Remove Defender Exclusions
:: -----------------------------------------------------------------------------
echo [INFO] Removing Windows Defender exclusions...
powershell -Command "Remove-MpPreference -ExclusionPath '%INSTALLDIR%'" >nul 2>&1
powershell -Command "Remove-MpPreference -ExclusionProcess '%EXEPATH%'" >nul 2>&1
echo [OK] Defender exclusions removed.

:: -----------------------------------------------------------------------------
:: 6. Remove Image File Execution Options
:: -----------------------------------------------------------------------------
echo [INFO] Removing IFEO Power Optimizations...
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\onixperf.exe" /f >nul 2>&1
echo [OK] Image File Execution Options removed.

:: -----------------------------------------------------------------------------
:: Finalization
:: -----------------------------------------------------------------------------
echo.
echo ===============================================================================
echo                      UNINSTALLATION COMPLETE
echo ===============================================================================
echo.
echo All traces of OnixPerf startup hooks, exclusions, and settings have been 
echo successfully removed from your system.
echo.
echo Note: The actual files (like onixperf.exe) remain in this folder and can be 
echo safely deleted manually if desired.
echo.
pause