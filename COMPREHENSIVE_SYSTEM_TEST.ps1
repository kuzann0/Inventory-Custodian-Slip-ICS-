Write-Host "========================================================================="
Write-Host "       ICS SYSTEM COMPREHENSIVE WORKFLOW TEST - APRIL 15, 2026"
Write-Host "========================================================================="
Write-Host ""

$baseUrl = "http://localhost:3001"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$testResults = @()

# Test counter
$testCount = 0
$passCount = 0
$failCount = 0

function Test-Endpoint {
    param(
        [string]$name,
        [string]$url,
        [string]$method = "GET",
        [object]$body,
        [hashtable]$headers
    )
    
    $script:testCount++
    $testName = "[$($script:testCount)] $name"
    
    try {
        $params = @{
            Uri = "$baseUrl$url"
            Method = $method
            UseBasicParsing = $true
            TimeoutSec = 10
        }
        
        if ($body) {
            $params['Body'] = if ($body -is [string]) { $body } else { $body | ConvertTo-Json }
            $params['ContentType'] = 'application/json'
        }
        
        if ($headers) {
            $params['Headers'] = $headers
        } else {
            $params['Headers'] = @{'Content-Type' = 'application/json'}
        }
        
        $response = Invoke-WebRequest @params
        $result = $response.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        Write-Host "✓ PASS: $testName" -ForegroundColor Green
        Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
        if ($result) {
            Write-Host "  Response: $($result | ConvertTo-Json -Depth 1)" -ForegroundColor Gray
        }
        $script:passCount++
        $script:testResults += @{Name=$testName; Status="PASS"; Response=$result}
        return $result
    }
    catch {
        Write-Host "✗ FAIL: $testName" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:failCount++
        $script:testResults += @{Name=$testName; Status="FAIL"; Error=$_.Exception.Message}
        return $null
    }
}

# =========================================================================
# SECTION 1: DATABASE CONNECTIVITY
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 1: DATABASE CONNECTIVITY ==========" -ForegroundColor Cyan
Write-Host ""

Test-Endpoint -name "Database Connection Test" -url "/connect.php" -method "GET"

# =========================================================================
# SECTION 2: AUTHENTICATION and LOGIN
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 2: AUTHENTICATION and LOGIN ==========" -ForegroundColor Cyan
Write-Host ""

$loginBody = @{
    username = "superadmin"
    password = "SuperAdmin@2026"
}
$loginResult = Test-Endpoint -name "SuperAdmin Login" -url "/login.php" -method "POST" -body $loginBody

$token = $null
if ($loginResult -and $loginResult.token) {
    $token = $loginResult.token
    Write-Host "  Token obtained: $($token.Substring(0, 20))..." -ForegroundColor Yellow
}

# =========================================================================
# SECTION 3: USER MANAGEMENT
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 3: USER MANAGEMENT ==========" -ForegroundColor Cyan
Write-Host ""

Test-Endpoint -name "Get All Users" -url "/get_all_users.php" -method "GET" -headers @{"X-User-ID"="1"}

Test-Endpoint -name "Get Employees List" -url "/get_employees.php" -method "GET" -headers @{"X-User-ID"="1"}

# =========================================================================
# SECTION 4: PURCHASE REQUEST WORKFLOW
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 4: PURCHASE REQUEST WORKFLOW ==========" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create Purchase Request
$pr_no = "PR-COMPREHENSIVE-$timestamp"
$createBody = @{
    pr_no = $pr_no
    item_name = "System Test Equipment"
    description = "Comprehensive workflow testing equipment"
    quantity = 10
    unit = "units"
    unit_cost = 5000
    office = "IT"
    division_section = "Testing"
    user_id = "1"
}

$prResult = Test-Endpoint -name "Create Purchase Request (PR-$timestamp)" -url "/submit_purchase_request.php" -method "POST" -body $createBody

$pr_id = $null
if ($prResult -and $prResult.pr_id) {
    $pr_id = $prResult.pr_id
    Write-Host "  PR ID: $pr_id (Total Amount: $($prResult.total_amount))" -ForegroundColor Yellow
}

# Step 2: Get Purchase Request Details
if ($pr_id) {
    Test-Endpoint -name "Get Purchase Request Details (PR ID: $pr_id)" -url "/get_pr_details.php?pr_id=$pr_id" -method "GET" -headers @{"X-User-ID"="1"}
}

# Step 3: Approve Purchase Request
if ($pr_id) {
    $approveBody = @{
        pr_id = $pr_id
        action = "approve"
        notes = "Approved for comprehensive system testing"
        user_id = "1"
    }
    Test-Endpoint -name "Approve Purchase Request (PR ID: $pr_id)" -url "/approve_purchase_request.php" -method "POST" -body $approveBody
}

# Step 4: Submit Delivery Notes
if ($pr_id) {
    $deliveryBody = @{
        pr_id = $pr_id
        delivery_notes = "All equipment delivered and verified"
        actual_delivery_date = Get-Date -Format "yyyy-MM-dd"
        user_id = "1"
    }
    Test-Endpoint -name "Submit Delivery Notes (PR ID: $pr_id)" -url "/submit_delivery_notes.php" -method "POST" -body $deliveryBody
}

# Step 5: Get Inspection Assignments
Write-Host ""
Write-Host "Getting inspection assignments..." -ForegroundColor Gray
$inspectAssignments = Test-Endpoint -name "Get Inspection Assignments" -url "/get_inspection_assignments.php" -method "GET" -headers @{"X-User-ID"="1"}

# Step 6: Submit Inspection
if ($pr_id -and $inspectAssignments) {
    $inspectionBody = @{
        assignment_id = 1
        pr_id = $pr_id
        inspection_notes = "All items verified in good condition"
        condition_report = "Excellent condition - ready for use"
        user_id = "1"
    }
    Test-Endpoint -name "Submit Inspection (PR ID: $pr_id)" -url "/submit_inspection.php" -method "POST" -body $inspectionBody
}

# =========================================================================
# SECTION 5: PROCESS TRACKING
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 5: PROCESS TRACKING ==========" -ForegroundColor Cyan
Write-Host ""

if ($pr_id) {
    Test-Endpoint -name "Get Process Status (PR ID: $pr_id)" -url "/get_process_status.php?pr_id=$pr_id" -method "GET" -headers @{"X-User-ID"="1"}
}

Test-Endpoint -name "Get All Purchase Requests" -url "/get_purchase_requests.php" -method "GET" -headers @{"X-User-ID"="1"}

# =========================================================================
# SECTION 6: CAPABILITIES and PERMISSIONS
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 6: CAPABILITIES and PERMISSIONS ==========" -ForegroundColor Cyan
Write-Host ""

Test-Endpoint -name "Get User Capabilities" -url "/get_user_capabilities.php?user_id=1" -method "GET" -headers @{"X-User-ID"="1"}

Test-Endpoint -name "Get All Capabilities" -url "/get_capabilities.php" -method "GET" -headers @{"X-User-ID"="1"}

# =========================================================================
# SECTION 7: AUDIT and LOGGING
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 7: AUDIT and LOGGING ==========" -ForegroundColor Cyan
Write-Host ""

Test-Endpoint -name "Get Audit Logs" -url "/get_audit_logs.php" -method "GET" -headers @{"X-User-ID"="1"}

# =========================================================================
# SECTION 8: FORM SUBMISSIONS (ICS & PPE)
# =========================================================================
Write-Host ""
Write-Host "========== SECTION 8: FORM SUBMISSIONS ==========" -ForegroundColor Cyan
Write-Host ""

Test-Endpoint -name "Get All Entries (ICS Forms)" -url "/get_entries.php" -method "GET" -headers @{"X-User-ID"="1"}

# =========================================================================
# TEST SUMMARY
# =========================================================================
Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "                         TEST SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""

$totalTests = $passCount + $failCount

Write-Host "Total Tests Run:     $totalTests" -ForegroundColor White
Write-Host "Passed:              $passCount" -ForegroundColor Green
Write-Host "Failed:              $failCount" -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Red' })
Write-Host "Success Rate:        $(($passCount/$totalTests)*100)%" -ForegroundColor $(if ($failCount -eq 0) { 'Green' } else { 'Yellow' })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "✓ ALL TESTS PASSED - SYSTEM OPERATIONAL" -ForegroundColor Green -BackgroundColor DarkGreen
} else {
    Write-Host "✗ SOME TESTS FAILED - REVIEW ERRORS ABOVE" -ForegroundColor Red -BackgroundColor DarkRed
}

Write-Host ""
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "Test Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "=========================================================================" -ForegroundColor Cyan
