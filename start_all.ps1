# Supplexio World Trade Intelligence - System Launcher (PowerShell)
Write-Host "=====================================================================" -ForegroundColor Cyan
Write-Host "          SUPPLEXIO WORLD TRADE INTELLIGENCE SYSTEM                   " -ForegroundColor Cyan
Write-Host "=====================================================================" -ForegroundColor Cyan

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot
$env:PYTHONUTF8 = "1"

# 1. GlassFish
Write-Host "`n[1/4] Starting GlassFish Application Server (Port 8080)..." -ForegroundColor Yellow
try {
    & "C:\glassfish4\bin\asadmin.bat" start-domain domain1
} catch {
    Write-Host "    Note: GlassFish may already be running." -ForegroundColor Gray
}

# 2. Flask API
Write-Host "`n[2/4] Starting Flask AI & Intelligence Backend (Port 5000)..." -ForegroundColor Yellow
Start-Process cmd.exe -ArgumentList "/k cd /d `"$projectRoot`" && set PYTHONUTF8=1 && python flask_api.py" -WindowStyle Normal

# 3. Streamlit
Write-Host "`n[3/4] Starting Streamlit Global Trade Dashboard (Port 8501)..." -ForegroundColor Yellow
Start-Process cmd.exe -ArgumentList "/k cd /d `"$projectRoot`" && set PYTHONUTF8=1 && streamlit run trade_dashboard.py --server.port 8501" -WindowStyle Normal

# 4. Open Browser
Write-Host "`n[4/4] Opening Web Application in Browser..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Start-Process "http://localhost:8080/SupplexioWebApp/auction"
Start-Process "http://localhost:8501"

Write-Host "`n=====================================================================" -ForegroundColor Green
Write-Host "                   ALL SERVICES LAUNCHED!                            " -ForegroundColor Green
Write-Host "=====================================================================" -ForegroundColor Green
Write-Host "  Main Application:      http://localhost:8080/SupplexioWebApp/auction" -ForegroundColor White
Write-Host "  Purchase Orders:       http://localhost:8080/SupplexioWebApp/user-po-view" -ForegroundColor White
Write-Host "  Inventory Management:  http://localhost:8080/SupplexioWebApp/inventory" -ForegroundColor White
Write-Host "  Streamlit Analytics:   http://localhost:8501" -ForegroundColor White
Write-Host "  Flask ML Engine:       http://localhost:5000" -ForegroundColor White
Write-Host "=====================================================================" -ForegroundColor Green

