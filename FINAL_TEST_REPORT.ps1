# ICS System Comprehensive Test Report - May 17, 2026

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$baseUrl = "http://localhost:3001"
$reportFile = "TEST_REPORT_$(Get-Date -f yyyyMMdd_HHmmss).txt"

Add-Content -Path $reportFile -Value "═══════════════════════════════════════════════════════════════════════════════"
Add-Content -Path $reportFile -Value "  ICS SYSTEM - COMPREHENSIVE TEST REPORT"
Add-Content -Path $reportFile -Value "  Date: $timestamp"
Add-Content -Path $reportFile -Value "═══════════════════════════════════════════════════════════════════════════════"
Add-Content -Path $reportFile -Value ""

$tests = @()
$pass = 0
$fail = 0

# Test 1: Database Connection
Write-Host "[1/15] Testing Database Connection..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$baseUrl/connect.php" -Method GET -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $result = "✓ PASS (Code: $($r.StatusCode))"
    $pass++
} catch {
    $result = "✗ FAIL ($($_.Exception.Message))"
    $fail++
}
Add-Content -Path $reportFile -Value "[TEST 1] Database Connection - $result"
Write-Host $result -ForegroundColor Green

# Test 2: Login
Write-Host "[2/15] Testing Login..." -ForegroundColor Yellow
try {
    $body = @{username="superadmin"; password="SuperAdmin@2026"} | ConvertTo-Json
    $r = Invoke-WebRequest -Uri "$baseUrl/login.php" -Method POST -Body $body -ContentType 'application/json' -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $result = "✓ PASS (Code: $($r.StatusCode))"
    $pass++
} catch {
    $result = "✗ FAIL"
    $fail++
}
Add-Content -Path $reportFile -Value "[TEST 2] SuperAdmin Login - $result"
Write-Host $result -ForegroundColor Green

# Test 3-8: GET Endpoints (Users, Employees, Entries, PRs, Capabilities, User Caps)
$getTests = @(
    @{num=3; name="Get All Users"; url="/get_all_users.php"},
    @{num=4; name="Get Employees"; url="/get_employees.php"},
    @{num=5; name="Get Entries"; url="/get_entries.php"},
    @{num=6; name="Get Purchase Requests"; url="/get_purchase_requests.php"},
    @{num=7; name="Get Capabilities"; url="/get_capabilities.php"},
    @{num=8; name="Get User Capabilities"; url="/get_user_capabilities.php?user_id=1"}
)

foreach ($test in $getTests) {
    Write-Host "[$($test.num)/15] Testing $($test.name)..." -ForegroundColor Yellow
    try {
        $r = Invoke-WebRequest -Uri "$baseUrl$($test.url)" -Method GET -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $result = "✓ PASS (Code: $($r.StatusCode))"
        $pass++
    } catch {
        $result = "✗ FAIL"
        $fail++
    }
    Add-Content -Path $reportFile -Value "[TEST $($test.num)] $($test.name) - $result"
    Write-Host $result -ForegroundColor Green
}

# Test 9: Get Audit Logs (Fixed)
Write-Host "[9/15] Testing Get Audit Logs..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$baseUrl/get_audit_logs.php" -Method GET -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $result = "✓ PASS (Code: $($r.StatusCode))"
    $pass++
} catch {
    $result = "✗ FAIL - $($_.Exception.Message)"
    $fail++
}
Add-Content -Path $reportFile -Value "[TEST 9] Get Audit Logs - $result"
Write-Host $result -ForegroundColor $(if($pass -eq 9) {'Green'} else {'Red'})

# Test 10: Get Inspection Assignments (Fixed)
Write-Host "[10/15] Testing Get Inspection Assignments..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$baseUrl/get_inspection_assignments.php" -Method GET -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $result = "✓ PASS (Code: $($r.StatusCode))"
    $pass++
} catch {
    $result = "✗ FAIL"
    $fail++
}
Add-Content -Path $reportFile -Value "[TEST 10] Get Inspection Assignments - $result"
Write-Host $result -ForegroundColor Green

# Test 11-13: More GET Endpoints
$moreTests = @(
    @{num=11; name="Get Admins"; url="/get_admins.php"},
    @{num=12; name="Get Process Status"; url="/get_process_status.php?pr_id=1"},
    @{num=13; name="Get Documents"; url="/get_documents.php?pr_id=1"}
)

foreach ($test in $moreTests) {
    Write-Host "[$($test.num)/15] Testing $($test.name)..." -ForegroundColor Yellow
    try {
        $r = Invoke-WebRequest -Uri "$baseUrl$($test.url)" -Method GET -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        $result = "✓ PASS (Code: $($r.StatusCode))"
        $pass++
    } catch {
        $result = "✗ FAIL"
        $fail++
    }
    Add-Content -Path $reportFile -Value "[TEST $($test.num)] $($test.name) - $result"
    Write-Host $result -ForegroundColor Green
}

# Test 14: Create Purchase Request
Write-Host "[14/15] Testing Create Purchase Request..." -ForegroundColor Yellow
try {
    $body = @{
        pr_no = "TEST-$(Get-Date -f yyyyMMddHHmmss)"
        item_name = "Test Equipment"
        quantity = 5
        unit = "pcs"
        unit_cost = 1000
        office = "IT"
        division_section = "Testing"
        user_id = "1"
    } | ConvertTo-Json
    $r = Invoke-WebRequest -Uri "$baseUrl/submit_purchase_request.php" -Method POST -Body $body -ContentType 'application/json' -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $result = "✓ PASS (Code: $($r.StatusCode))"
    $pass++
} catch {
    $result = "✗ FAIL"
    $fail++
}
Add-Content -Path $reportFile -Value "[TEST 14] Create Purchase Request - $result"
Write-Host $result -ForegroundColor Green

# Test 15: Get Workflow Entry
Write-Host "[15/15] Testing Get Workflow Entry..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri "$baseUrl/get_workflow_entry_binding.php?pr_id=1" -Method GET -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $result = "✓ PASS (Code: $($r.StatusCode))"
    $pass++
} catch {
    $result = "✗ FAIL"
    $fail++
}
Add-Content -Path $reportFile -Value "[TEST 15] Get Workflow Entry - $result"
Write-Host $result -ForegroundColor Green

# Summary
Add-Content -Path $reportFile -Value ""
Add-Content -Path $reportFile -Value "═══════════════════════════════════════════════════════════════════════════════"
Add-Content -Path $reportFile -Value "SUMMARY"
Add-Content -Path $reportFile -Value "═══════════════════════════════════════════════════════════════════════════════"
Add-Content -Path $reportFile -Value "Total Tests: 15"
Add-Content -Path $reportFile -Value "Passed: $pass"
Add-Content -Path $reportFile -Value "Failed: $fail"
Add-Content -Path $reportFile -Value "Success Rate: $(([math]::Round(($pass/15)*100, 1)))%"
Add-Content -Path $reportFile -Value ""

if ($fail -eq 0) {
    Add-Content -Path $reportFile -Value "STATUS: ✓ ALL TESTS PASSED - SYSTEM OPERATIONAL"
} else {
    Add-Content -Path $reportFile -Value "STATUS: ⚠ $fail TEST(S) FAILED"
}

Add-Content -Path $reportFile -Value ""
Add-Content -Path $reportFile -Value "Report saved to: $reportFile"

# Display final summary
Write-Host ""
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "FINAL SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Total Tests: 15" -ForegroundColor White
Write-Host "Passed: $pass" -ForegroundColor Green
Write-Host "Failed: $fail" -ForegroundColor $(if($fail -eq 0) {'Green'} else {'Red'})
Write-Host "Success Rate: $(([math]::Round(($pass/15)*100, 1)))%" -ForegroundColor $(if($fail -eq 0) {'Green'} else {'Yellow'})
Write-Host ""
Write-Host "Report saved to: $reportFile" -ForegroundColor Yellow
