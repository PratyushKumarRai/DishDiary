@echo off
echo Fixing Isar namespace issue...

set ISAR_BUILD_GRADLE=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle

if not exist "%ISAR_BUILD_GRADLE%" (
    echo Error: Could not find isar_flutter_libs build.gradle
    echo Please run: flutter pub get
    exit /b 1
)

echo Patching %ISAR_BUILD_GRADLE%...

REM Read the current content
setlocal enabledelayedexpansion
set "content="
for /f "delims=" %%a in ('type "%ISAR_BUILD_GRADLE%"') do (
    set "line=%%a"
    set "line=!line:android {=android {^
    namespace 'com.isar.isar_flutter_libs'^
!"
    set "content=!content!!line!^
"
)

REM Write the patched content
echo !content! > "%ISAR_BUILD_GRADLE%"
endlocal

echo Done! Please rebuild your project.
pause
