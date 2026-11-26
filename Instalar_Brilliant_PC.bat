@echo off
chcp 65001 >nul
title Instalador y Empaquetador de Brilliant para Windows

set "ORIGEN=%~dp0build\windows\x64\runner\Release"
set "DESTINO=%LOCALAPPDATA%\Programs\Brilliant"
set "INSTALADOR_UNICO=%~dp0Brilliant_Instalador.exe"
set "ZIP_TEMP=%~dp0build\windows\BrilliantPayload_temp.zip"
set "CSC=C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
set "ICONO=%~dp0windows\runner\resources\app_icon.ico"
set "STUB=%~dp0windows\installer_stub.cs"

if not exist "%ORIGEN%\Brilliant.exe" (
    echo No se encontro Brilliant.exe en "%ORIGEN%".
    echo Primero ejecuta: flutter build windows --release
    pause
    exit /b 1
)

echo [1/3] Instalando Brilliant en tu computadora ("%DESTINO%")...
if not exist "%DESTINO%" mkdir "%DESTINO%"
xcopy "%ORIGEN%\*" "%DESTINO%\" /E /I /Y >nul

echo [2/3] Creando acceso directo "Brilliant" en tu Escritorio y Menu Inicio...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$WshShell = New-Object -ComObject WScript.Shell; $DesktopPath = [Environment]::GetFolderPath('Desktop'); $StartMenuPath = [Environment]::GetFolderPath('Programs'); foreach ($Dir in @($DesktopPath, $StartMenuPath)) { $Shortcut = $WshShell.CreateShortcut((Join-Path $Dir 'Brilliant.lnk')); $Shortcut.TargetPath = '%DESTINO%\Brilliant.exe'; $Shortcut.WorkingDirectory = '%DESTINO%'; $Shortcut.IconLocation = '%DESTINO%\Brilliant.exe,0'; $Shortcut.Description = 'Brilliant - Juego de estrategia numerica'; $Shortcut.Save(); }"

echo [3/3] Generando instalador de un solo archivo "Brilliant_Instalador.exe" para compartir...
if exist "%ZIP_TEMP%" del /f /q "%ZIP_TEMP%"
if exist "%INSTALADOR_UNICO%" del /f /q "%INSTALADOR_UNICO%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::CreateFromDirectory('%ORIGEN%', '%ZIP_TEMP%', [System.IO.Compression.CompressionLevel]::Optimal, $false)"

"%CSC%" /nologo /target:winexe /optimize+ /out:"%INSTALADOR_UNICO%" /win32icon:"%ICONO%" /reference:System.dll /reference:System.Drawing.dll /reference:System.Windows.Forms.dll /reference:System.IO.Compression.dll /reference:System.IO.Compression.FileSystem.dll /resource:"%ZIP_TEMP%,BrilliantPayload.zip" "%STUB%"

if exist "%ZIP_TEMP%" del /f /q "%ZIP_TEMP%"

echo.
echo ======================================================================
echo   LISTO! Se realizaron las dos cosas con exito:
echo.
echo   1. Brilliant ya quedo instalado en tu PC (icono en tu Escritorio).
echo   2. Se creo el archivo unico:
echo      Brilliant_Instalador.exe
echo      en la carpeta principal de tu proyecto.
echo.
echo   SOLO PASALES ESE ARCHIVO "Brilliant_Instalador.exe" a tus amigos!
echo   Cuando ellos lo abran con doble clic, les instalara y abrira el
echo   juego automaticamente en sus computadoras.
echo ======================================================================
echo.
start "" "%DESTINO%\Brilliant.exe"
pause
