@echo off
cd /d "%~dp0"
set DB_USERNAME=myuser
set DB_PASSWORD=mypassword
set DB_HOST=127.0.0.1
set DB_PORT=5433
set DB_NAME=mydatabase
echo Starting Flask application...
echo Database: %DB_NAME% at %DB_HOST%:%DB_PORT%
python app.py
pause
