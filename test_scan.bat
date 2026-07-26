@echo off
cd /d "%~dp0"
venv\Scripts\python.exe scripts\test_scan.py
pause
