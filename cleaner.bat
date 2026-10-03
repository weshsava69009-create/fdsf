@echo off
echo Starting system cleanup...

REM Run as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
) else (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo [1/10] Resetting network stack...
netsh winsock reset
netsh winsock reset catalog
netsh int ip reset
netsh advfirewall reset
netsh int reset all
netsh int ipv4 reset
netsh int ipv6 reset

echo.
echo [2/10] Flushing DNS and network settings...
ipconfig /release
ipconfig /flushdns
ipconfig /renew
ipconfig /flushdns

echo.
echo [3/10] Resetting network adapters...
WMIC PATH WIN32_NETWORKADAPTER WHERE PHYSICALADAPTER=TRUE CALL DISABLE >nul 2>&1
timeout /t 2 /nobreak >nul
WMIC PATH WIN32_NETWORKADAPTER WHERE PHYSICALADAPTER=TRUE CALL ENABLE >nul 2>&1

echo.
echo [4/10] Clearing ARP cache...
arp -d

echo.
echo [5/10] Restarting Windows Management service...
net stop winmgmt /y
net start winmgmt

echo.
echo [6/10] Clearing Windows temp files...
del /q /f /s %temp%\* >nul 2>&1
del /q /f /s C:\Windows\Temp\* >nul 2>&1

echo.
echo [7/10] Clearing browser cache...
del /q /f /s "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
del /q /f /s "%USERPROFILE%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*" >nul 2>&1
del /q /f /s "%USERPROFILE%\AppData\Roaming\Mozilla\Firefox\Profiles\*\cache2\*" >nul 2>&1

echo.
echo [8/10] Clearing Windows logs...
del /q /f /s C:\Windows\Logs\* >nul 2>&1
del /q /f /s C:\Windows\System32\LogFiles\* >nul 2>&1

echo.
echo [9/10] Clearing prefetch files...
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1

echo.
echo [10/10] Final cleanup...
sfc /scannow >nul 2>&1
dism /online /cleanup-image /restorehealth >nul 2>&1

echo.
echo Cleanup completed successfully!
echo Please restart your computer for all changes to take effect.
echo.
pause

