@echo off
cd /d "%~dp0"
echo ======================================
echo   Starting NoFTe API
echo ======================================
echo.

REM Install dependencies if needed
echo [1/3] Checking dependencies...
pip install -r requirements.txt >nul 2>&1
if errorlevel 1 (
    echo    pip install failed, trying anyway...
)

REM Create tables if needed
echo [2/3] Creating database tables...
python create_tables.py >nul 2>&1
if errorlevel 1 (
    echo    Note: Database might not be available.
    echo    Make sure PostgreSQL is running!
    echo.
)

echo [3/3] Starting API server...
echo.
echo API will run at: http://127.0.0.1:8000
echo Docs available at: http://127.0.0.1:8000/docs
echo.
echo Press Ctrl+C to stop.
echo ======================================
echo.

venv\Scripts\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
pause
