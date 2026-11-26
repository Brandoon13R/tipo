@echo off
chcp 65001 >nul
title Instalador de Brilliant para Windows

set "ORIGEN=%~dp0build\windows\x64\runner\Release"
set "DESTINO=%LOCALAPPDATA%\Programs\Brilliant"

if not exist "%ORIGEN%\Brilliant.exe" (
    echo No se encontro Brilliant.exe en "%ORIGEN%".
    echo Primero ejecuta: flutter build windows --release
    pause
    exit /b 1
)

echo Instalando Brilliant en "%DESTINO%"...
if not exist "%DESTINO%" mkdir "%DESTINO%"
xcopy "%ORIGEN%\*" "%DESTINO%\" /E /I /Y >nul

echo Creando acceso directo "Brilliant" en el Escritorio y en el Menu Inicio...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$WshShell = New-Object -ComObject WScript.Shell; " ^
  "$DesktopPath = [Environment]::GetFolderPath('Desktop'); " ^
  "$StartMenuPath = [Environment]::GetFolderPath('Programs'); " ^
  "foreach ($Dir in @($DesktopPath, $StartMenuPath)) { " ^
  "  $Shortcut = $WshShell.CreateShortcut((Join-Path $Dir 'Brilliant.lnk')); " ^
  "  $Shortcut.TargetPath = '%DESTINO%\Brilliant.exe'; " ^
  "  $Shortcut.WorkingDirectory = '%DESTINO%'; " ^
  "  $Shortcut.IconLocation = '%DESTINO%\Brilliant.exe,0'; " ^
  "  $Shortcut.Description = 'Brilliant - Juego de estrategia numerica'; " ^
  "  $Shortcut.Save(); " ^
  "}"

echo.
echo ========================================================
echo   Brilliant se instalo correctamente en tu computadora!
echo   Ya tienes el icono "Brilliant" en tu Escritorio.
echo ========================================================
echo.
start "" "%DESTINO%\Brilliant.exe"
pause
