@echo off
REM Restore script for DishDiary
REM Usage: restore_backup.bat <backup_directory>

if "%1"=="" (
    echo Error: No backup directory specified
    echo Usage: restore_backup.bat ^<backup_directory^>
    pause
    exit /b 1
)

set BACKUP_DIR=%1

if not exist %BACKUP_DIR% (
    echo Error: Backup directory does not exist: %BACKUP_DIR%
    pause
    exit /b 1
)

echo Restoring from backup: %BACKUP_DIR%
echo.

echo Restoring pubspec.yaml...
copy %BACKUP_DIR%\pubspec.yaml pubspec.yaml

echo Restoring auth_service.dart...
copy %BACKUP_DIR%\auth_service.dart lib\services\auth_service.dart

echo Restoring login_screen.dart...
copy %BACKUP_DIR%\login_screen.dart lib\features\auth\login_screen.dart

echo Restoring settings_screen.dart...
copy %BACKUP_DIR%\settings_screen.dart lib\features\settings\settings_screen.dart

echo Restoring providers.dart...
copy %BACKUP_DIR%\providers.dart lib\providers\providers.dart

echo Restoring android app build.gradle...
copy %BACKUP_DIR%\android_app_build.gradle android\app\build.gradle

echo Restoring android root build.gradle...
copy %BACKUP_DIR%\android_root_build.gradle android\build.gradle

echo Restoring AndroidManifest.xml...
copy %BACKUP_DIR%\AndroidManifest.xml android\app\src\main\AndroidManifest.xml

echo Restoring Info.plist...
copy %BACKUP_DIR%\Info.plist ios\Runner\Info.plist

echo.
echo Restore completed successfully!
echo.
echo Now run:
echo   flutter clean
echo   flutter pub get
echo   flutter run
pause
