@echo off
title Supplexio World Trade Intelligence - System Launcher
echo =====================================================================
echo           SUPPLEXIO WORLD TRADE INTELLIGENCE SYSTEM
echo =====================================================================
echo.

cd /d "%~dp0"
set PYTHONUTF8=1

echo [1/4] Starting GlassFish Application Server (Port 8080)...
call "C:\glassfish4\bin\asadmin.bat" start-domain domain1
if %ERRORLEVEL% EQU 0 (
    echo     GlassFish started successfully!
) else (
    echo     GlassFish may already be running or encountered a warning. Continuing...
)
echo.

echo [2/4] Starting Flask AI & Intelligence Backend (Port 5000)...
start "Supplexio - Flask API (Port 5000)" cmd /k "cd /d %~dp0 && set PYTHONUTF8=1 && python flask_api.py"
echo     Flask API launcher initiated in new window.
echo.

echo [3/4] Starting Streamlit Global Trade Dashboard (Port 8501)...
start "Supplexio - Streamlit Analytics (Port 8501)" cmd /k "cd /d %~dp0 && set PYTHONUTF8=1 && streamlit run trade_dashboard.py --server.port 8501"
echo     Streamlit Dashboard launcher initiated in new window.
echo.

echo [4/4] Opening Web Application in Browser...
timeout /t 3 /nobreak >nul
start http://localhost:8080/SupplexioWebApp/auction
start http://localhost:8501

echo.
echo =====================================================================
echo                    ALL SERVICES LAUNCHED!
echo =====================================================================
echo   Main Application:      http://localhost:8080/SupplexioWebApp/auction
echo   Purchase Orders:       http://localhost:8080/SupplexioWebApp/user-po-view
echo   Inventory Management:  http://localhost:8080/SupplexioWebApp/inventory
echo   Streamlit Analytics:   http://localhost:8501
echo   Flask ML Engine:       http://localhost:5000
echo =====================================================================
echo Keep the launched terminal windows open while using the application.
echo You can close this window now.
pause

