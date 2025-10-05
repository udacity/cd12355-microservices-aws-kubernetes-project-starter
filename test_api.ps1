# Test the analytics API endpoints

Write-Host "Testing health check..." -ForegroundColor Green
curl http://127.0.0.1:5153/health_check

Write-Host "`n`nTesting readiness check..." -ForegroundColor Green
curl http://127.0.0.1:5153/readiness_check

Write-Host "`n`nTesting daily usage report..." -ForegroundColor Green
curl http://127.0.0.1:5153/api/reports/daily_usage

Write-Host "`n`nTesting user visits report..." -ForegroundColor Green
curl http://127.0.0.1:5153/api/reports/user_visits

