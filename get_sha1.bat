@echo off
REM Get SHA-1 fingerprint from debug keystore
REM This script searches for keytool in common Java installation locations

set JAVA_PATHS=
set "JAVA_PATHS=%JAVA_PATHS%;C:\Program Files\Android\Android Studio\jbr\bin"
set "JAVA_PATHS=%JAVA_PATHS%;C:\Program Files\Java\jdk\bin"
set "JAVA_PATHS=%JAVA_PATHS%;C:\Program Files\Java\jdk-17\bin"
set "JAVA_PATHS=%JAVA_PATHS%;C:\Program Files\Java\jdk-11\bin"

for %%P in (%JAVA_PATHS%) do (
    if exist "%%P\keytool.exe" (
        "%%P\keytool.exe" -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android | findstr "SHA1"
        goto :end
    )
)

echo keytool not found. Please install Java JDK or Android Studio.
echo Alternatively, run this manually in Android Studio Terminal:
echo keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android

:end
pause
