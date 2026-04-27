@echo off
REM Backup script for DishDiary before Google Sign-In changes
REM Run this to create backups of important files

echo Creating backup of current DishDiary files...
echo.

set BACKUP_DIR=backup_before_google_signin_%DATE:~-4,4%%DATE:~-7,2%%DATE:~-10,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
set BACKUP_DIR=%BACKUP_DIR: =%

mkdir %BACKUP_DIR%

echo Backing up pubspec.yaml...
copy pubspec.yaml %BACKUP_DIR%\pubspec.yaml

echo Backing up auth_service.dart...
copy lib\services\auth_service.dart %BACKUP_DIR%\auth_service.dart

echo Backing up login_screen.dart...
copy lib\features\auth\login_screen.dart %BACKUP_DIR%\login_screen.dart

echo Backing up settings_screen.dart...
copy lib\features\settings\settings_screen.dart %BACKUP_DIR%\settings_screen.dart

echo Backing up providers.dart...
copy lib\providers\providers.dart %BACKUP_DIR%\providers.dart

echo Backing up android app build.gradle...
copy android\app\build.gradle %BACKUP_DIR%\android_app_build.gradle

echo Backing up android root build.gradle...
copy android\build.gradle %BACKUP_DIR%\android_root_build.gradle

echo Backing up AndroidManifest.xml...
copy android\app\src\main\AndroidManifest.xml %BACKUP_DIR%\AndroidManifest.xml

echo Backing up Info.plist...
copy ios\Runner\Info.plist %BACKUP_DIR%\Info.plist

echo.
echo Backup completed successfully!
echo Backup location: %CD%\%BACKUP_DIR%
echo.
echo To restore, use: restore_backup.bat %BACKUP_DIR%
pause
