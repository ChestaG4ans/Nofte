@echo off
cd /d "%~dp0"
echo =====================================
echo   NoFTe APK Builder
echo =====================================
echo.

REM Get dependencies
echo [1/4] Getting dependencies...
flutter pub get

REM Clean previous builds
echo [2/4] Cleaning previous builds...
flutter clean >nul 2>&1

REM Get dependencies again after clean
flutter pub get

REM Build debug APK
echo [3/4] Building debug APK...
flutter build apk --debug

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

REM Show APK location
echo.
echo [4/4] Build complete!
echo =====================================
echo.
echo APK Location:
dir /s /b build\app\outputs\flutter-apk\*.apk 2>nul
echo.
echo =====================================
pause
