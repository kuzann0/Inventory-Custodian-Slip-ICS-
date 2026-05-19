Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "       ICS SYSTEM COMPREHENSIVE WORKFLOW TEST - MAY 17, 2026" -ForegroundColor Cyan
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:3001"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testResults = @()
$passCount = 0
$failCount = 0

# =========================================================================
# SECTION 1: DATABASE CONNECTIVITY
# =========================================================================
Write-Host "========== SECTION 1: DATABASE CONNECTIVITY ==========" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "[1] Database Connection Test..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/connect.php" -Method GET -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ PASS: Database connected" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Database connection error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

# =========================================================================
# SECTION 2: AUTHENTICATION
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 2: AUTHENTICATION ==========" -ForegroundColor Cyan
Write-Host ""

$token = $null
try {
    Write-Host "[2] SuperAdmin Login Test..." -ForegroundColor White
    $loginBody = @{
        username = "superadmin"
        password = "SuperAdmin@2026"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$baseUrl/login.php" -Method POST -Body $loginBody `
        -ContentType 'application/json' -UseBasicParsing -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    Write-Host "✓ PASS: Login successful" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    if ($result.token) {
        $token = $result.token
        Write-Host "  Token: $($token.Substring(0, 20))..." -ForegroundColor Yellow
    }
    $passCount++
} catch {
    Write-Host "✗ FAIL: Login error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

# =========================================================================
# SECTION 3: USER MANAGEMENT
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 3: USER MANAGEMENT ==========" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "[3] Get All Users..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/get_all_users.php" -Method GET `
        -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ PASS: Retrieved users" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Get users error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

try {
    Write-Host "[4] Get Employees List..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/get_employees.php" -Method GET `
        -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ PASS: Retrieved employees" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Get employees error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

# =========================================================================
# SECTION 4: INVENTORY ENTRIES
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 4: INVENTORY ENTRIES ==========" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "[5] Get All Entries (ICS Forms)..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/get_entries.php" -Method GET `
        -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    Write-Host "✓ PASS: Retrieved entries" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode) - Found $($result.data.count) entries" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Get entries error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

# =========================================================================
# SECTION 5: PURCHASE REQUESTS
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 5: PURCHASE REQUESTS ==========" -ForegroundColor Cyan
Write-Host ""

$pr_id = $null

try {
    Write-Host "[6] Create Purchase Request..." -ForegroundColor White
    $pr_no = "PR-AUTO-$timestamp"
    $createBody = @{
        pr_no = $pr_no
        item_name = "Test Equipment"
        description = "Automated test - do not use"
        quantity = 5
        unit = "units"
        unit_cost = 1000
        office = "IT"
        division_section = "Testing"
        user_id = "1"
    } | ConvertTo-Json
    
    $response = Invoke-WebRequest -Uri "$baseUrl/submit_purchase_request.php" -Method POST `
        -Body $createBody -ContentType 'application/json' -UseBasicParsing -TimeoutSec 10
    $result = $response.Content | ConvertFrom-Json
    
    if ($result.pr_id) {
        $pr_id = $result.pr_id
        Write-Host "✓ PASS: PR created" -ForegroundColor Green
        Write-Host "  PR ID: $pr_id - Amount: $($result.total_amount)" -ForegroundColor Green
        $passCount++
    } else {
        Write-Host "✗ FAIL: PR creation returned no ID" -ForegroundColor Red
        $failCount++
    }
} catch {
    Write-Host "✗ FAIL: PR creation error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

if ($pr_id) {
    try {
        Write-Host "[7] Get PR Details (ID: $pr_id)..." -ForegroundColor White
        $response = Invoke-WebRequest -Uri "$baseUrl/get_pr_details.php?pr_id=$pr_id" -Method GET `
            -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
        Write-Host "✓ PASS: Retrieved PR details" -ForegroundColor Green
        Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
        $passCount++
    } catch {
        Write-Host "✗ FAIL: Get PR details error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }

    try {
        Write-Host "[8] Get All Purchase Requests..." -ForegroundColor White
        $response = Invoke-WebRequest -Uri "$baseUrl/get_purchase_requests.php" -Method GET `
            -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
        Write-Host "✓ PASS: Retrieved all PRs" -ForegroundColor Green
        Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
        $passCount++
    } catch {
        Write-Host "✗ FAIL: Get PRs error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

# =========================================================================
# SECTION 6: CAPABILITIES & PERMISSIONS
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 6: CAPABILITIES & PERMISSIONS ==========" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "[9] Get User Capabilities..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/get_user_capabilities.php?user_id=1" -Method GET `
        -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ PASS: Retrieved user capabilities" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Get capabilities error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

try {
    Write-Host "[10] Get All Capabilities..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/get_capabilities.php" -Method GET `
        -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ PASS: Retrieved all capabilities" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Get all capabilities error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

# =========================================================================
# SECTION 7: AUDIT & LOGGING
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 7: AUDIT & LOGGING ==========" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "[11] Get Audit Logs..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/get_audit_logs.php" -Method GET `
        -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ PASS: Retrieved audit logs" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Get audit logs error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

# =========================================================================
# SECTION 8: INSPECTION ASSIGNMENTS
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 8: INSPECTION ASSIGNMENTS ==========" -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "[12] Get Inspection Assignments..." -ForegroundColor White
    $response = Invoke-WebRequest -Uri "$baseUrl/get_inspection_assignments.php" -Method GET `
        -Headers @{"X-User-ID"="1"} -UseBasicParsing -TimeoutSec 10
    Write-Host "✓ PASS: Retrieved inspection assignments" -ForegroundColor Green
    Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    $passCount++
} catch {
    Write-Host "✗ FAIL: Get inspections error: $($_.Exception.Message)" -ForegroundColor Red
    $failCount++
}

# =========================================================================
# TEST SUMMARY
# =========================================================================
Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "                      TEST SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $passCount + $failCount
$successRate = if ($totalTests -gt 0) { [math]::Round(($passCount / $totalTests) * 100, 1) } else { 0 }

Write-Host "Total Tests Run:     $totalTests" -ForegroundColor White
Write-Host "Passed:              $passCount" -ForegroundColor Green
Write-Host "Failed:              $failCount" -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Red' })
Write-Host "Success Rate:        $successRate%" -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "✓ ALL TESTS PASSED - SYSTEM FULLY OPERATIONAL" -ForegroundColor Green -BackgroundColor DarkGreen
} else {
    Write-Host "⚠ $failCount TEST(S) FAILED - REVIEW ERRORS ABOVE" -ForegroundColor Red -BackgroundColor DarkRed
}

Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "Report Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "=========================================================================" -ForegroundColor Cyan
