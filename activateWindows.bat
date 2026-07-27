@echo off
title Windows Activation Tool
color 0A
mode con: cols=65 lines=25

:banner
cls
echo.
echo  ========================================================
echo         WINDOWS ACTIVATION TOOL
echo  ========================================================
echo.
echo         [1] Windows 10/11 Home
echo         [2] Windows 10/11 Pro
echo         [3] Exit
echo.
echo  ========================================================
echo         Credits: itz.zennyfr
echo  ========================================================
echo.

set /p choice="  Select option (1-3): "

if "%choice%"=="1" goto home
if "%choice%"=="2" goto pro
if "%choice%"=="3" goto exit
goto banner

:home
cls
color 9
@echo Windows Home Activation
echo.
slmgr //B /ipk TX9XD-98N7V-6WMQ6-BX7FG-H8Q99
slmgr //B /skms kms8.msguides.com
slmgr //B /ato
echo.
@echo Done
timeout 2 >nul
color 0A
goto banner

:pro
cls
color 9
@echo Windows Pro Activation
echo.
slmgr //B /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
slmgr //B /skms kms8.msguides.com
slmgr //B /ato
echo.
@echo Done
timeout 2 >nul
color 0A
goto banner

:exit
cls
echo.
echo  Exiting...
timeout 1 >nul
exit
