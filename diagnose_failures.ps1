# Verify user passwords in database

Write-Host "Checking user authentication details..." -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, username, email, account_status FROM users"

Write-Host ""
Write-Host "Testing each user separately..." -ForegroundColor Green

$baseUrl = "http://localhost:3001"

# Test superadmin
Write-Host ""
Write-Host "Testing superadmin login..." -ForegroundColor Cyan
$loginData = @{ username = "superadmin"; password = "SuperAdmin@2026" } | ConvertTo-Json
$resp = Invoke-RestMethod "$baseUrl/login.php" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
if ($resp.token) { Write-Host "  Result: SUCCESS" -ForegroundColor Green } else { Write-Host "  Result: FAIL" -ForegroundColor Red }

# Test admin with different passwords
Write-Host ""
Write-Host "Testing admin login..." -ForegroundColor Cyan
@("Admin@2026", "admin", "admin123", "password") | ForEach-Object {
    $pwd = $_
    $loginData = @{ username = "admin"; password = $pwd } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod "$baseUrl/login.php" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
        if ($resp.token) { Write-Host "  SUCCESS with password: $pwd" -ForegroundColor Green }
    } catch {
        Write-Host "  Failed with password: $pwd" -ForegroundColor Red
    }
}

# Test kuzano with different passwords
Write-Host ""
Write-Host "Testing kuzano login..." -ForegroundColor Cyan
@("Password@2026", "kuzano", "password123", "password") | ForEach-Object {
    $pwd = $_
    $loginData = @{ username = "kuzano"; password = $pwd } | ConvertTo-Json
    try {
        $resp = Invoke-RestMethod "$baseUrl/login.php" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
        if ($resp.token) { Write-Host "  SUCCESS with password: $pwd" -ForegroundColor Green }
    } catch {
        Write-Host "  Failed with password: $pwd" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Testing failed API endpoints..." -ForegroundColor Green

$baseUrl = "http://localhost:3001"

Write-Host ""
Write-Host "Testing get_audit_logs..." -ForegroundColor Cyan
try {
    $resp = Invoke-RestMethod "$baseUrl/get_audit_logs.php" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  Result: SUCCESS" -ForegroundColor Green
    $resp | ConvertTo-Json | Write-Host
} catch {
    Write-Host "  Result: FAILED" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Testing get_inspection_assignments..." -ForegroundColor Cyan
try {
    $resp = Invoke-RestMethod "$baseUrl/get_inspection_assignments.php" -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  Result: SUCCESS" -ForegroundColor Green
    $resp | ConvertTo-Json | Write-Host
} catch {
    Write-Host "  Result: FAILED" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Yellow
}
