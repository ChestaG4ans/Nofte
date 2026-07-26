@echo off
cd /d "%~dp0"

echo =====================================
echo   NoFTe Flutter
echo =====================================
echo.

echo Installing dependencies...
call flutter pub get

echo.
echo Building APK...
call flutter build apk --debug

echo.
echo Done! APK ada di:
echo build\app\outputs\flutter-apk\app-debug.apk
echo.
pause