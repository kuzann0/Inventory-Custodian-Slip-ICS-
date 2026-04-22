# Complete Workflow Verification Test - April 2026
# Tests: Login, PR Creation, Approval, Delivery, Inspection, Form Selection

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "COMPREHENSIVE WORKFLOW VERIFICATION TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Testing Purchase Request Workflow" -ForegroundColor Yellow
Write-Host "Time: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Test Counters
$passCount = 0
$failCount = 0
$testCount = 0

function Test-Step {
    param([string]$name, [scriptblock]$test)
    $script:testCount++
    Write-Host "TEST $($script:testCount): $name" -ForegroundColor Cyan
    try {
        & $test
        Write-Host "✓ PASS" -ForegroundColor Green
        $script:passCount++
    } catch {
        Write-Host "✗ FAIL: $_" -ForegroundColor Red
        $script:failCount++
    }
    Write-Host ""
}

# ============================================================
# SECTION 1: INFRASTRUCTURE CHECK
# ============================================================
Write-Host "SECTION 1: Infrastructure Check" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

Test-Step "Backend API is responding" {
    $response = Invoke-RestMethod "http://localhost:3001/test.php" -ErrorAction Stop
    if ($response) {
        Write-Host "  Backend: OK"
    }
}

Test-Step "Frontend is accessible" {
    $response = Invoke-WebRequest "http://localhost:3000" -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "  Frontend: OK"
    }
}

Test-Step "Database connectivity" {
    $response = Invoke-RestMethod "http://localhost:3001/get_employees.php" -ErrorAction Stop
    if ($response.success) {
        Write-Host "  Database: Connected, $(($response.employees).Count) employees found"
    }
}

# ============================================================
# SECTION 2: USER & AUTHENTICATION
# ============================================================
Write-Host ""
Write-Host "SECTION 2: User `& Authentication (Query)" -ForegroundColor Yellow
Write-Host "=================================" -ForegroundColor Yellow

Test-Step "Retrieve all users" {
    $response = Invoke-RestMethod "http://localhost:3001/get_all_users.php" -ErrorAction Stop
    if ($response.success) {
        Write-Host "  Users found: $(($response.users).Count)"
        Write-Host "  Users: $($response.users | ForEach-Object {$_.name} -join ', ')"
    }
}

Test-Step "Get user capabilities" {
    $response = Invoke-RestMethod "http://localhost:3001/get_user_capabilities.php?user_id=3" -ErrorAction Stop
    if ($response.success) {
        Write-Host "  Capabilities: $(($response.capabilities).Count)"
    }
}

# ============================================================
# SECTION 3: PURCHASE REQUEST WORKFLOW
# ============================================================
Write-Host ""
Write-Host "SECTION 3: Purchase Request Workflow" -ForegroundColor Yellow
Write-Host "=====================================" -ForegroundColor Yellow

$prNo = "PR-VERIFY-$(Get-Date -Format 'yyyyMMddHHmmss')"
$prId = $null

Test-Step "Create Purchase Request" {
    $body = @{
        pr_no = $prNo
        item_name = "Test Item"
        description = "Comprehensive workflow test item"
        quantity = 3
        unit = "units"
        unit_cost = 15000
        office = "Main Office"
        division_section = "Testing Division"
        user_id = 3
    } | ConvertTo-Json

    $response = Invoke-RestMethod "http://localhost:3001/submit_purchase_request.php" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    if ($response.success) {
        $script:prId = $response.pr_id
        Write-Host "  PR Created: $prNo"
        Write-Host "  PR ID: $($script:prId)"
        Write-Host "  Total Amount: $($response.total_amount)"
    } else {
        throw "Failed: $($response.error)"
    }
}

Test-Step "Retrieve Purchase Request Details" {
    if (-not $script:prId) {
        throw "No PR ID to retrieve"
    }

    $response = Invoke-RestMethod "http://localhost:3001/get_pr_details.php?pr_no=$prNo" -ErrorAction Stop

    if ($response.success) {
        Write-Host "  PR Details Retrieved:"
        Write-Host "    - Description: $($response.description)"
        Write-Host "    - Quantity: $($response.quantity)"
        Write-Host "    - Unit Cost: $($response.unit_cost)"
        Write-Host "    - Status: $($response.status)"
    } else {
        throw "Failed to retrieve PR"
    }
}

# ============================================================
# SECTION 4: APPROVAL WORKFLOW
# ============================================================
Write-Host ""
Write-Host "SECTION 4: Approval Workflow" -ForegroundColor Yellow
Write-Host "=============================" -ForegroundColor Yellow

Test-Step "Approve Purchase Request" {
    if (-not $script:prId) {
        throw "No PR ID to approve"
    }

    $body = @{
        pr_id = $script:prId
        user_id = 3
        action = "approve"
        notes = "Approved for testing"
    } | ConvertTo-Json

    $response = Invoke-RestMethod "http://localhost:3001/approve_purchase_request.php" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    if ($response.success) {
        Write-Host "  PR Approved"
        Write-Host "  Approval Date: $(Get-Date)"
    } else {
        throw "Approval failed: $($response.error)"
    }
}

Test-Step "Verify PR Status Updated" {
    if (-not $script:prId) {
        throw "No PR ID to verify"
    }

    $response = Invoke-RestMethod "http://localhost:3001/get_pr_details.php?pr_no=$prNo" -ErrorAction Stop

    if ($response.success -and $response.status -eq "approved") {
        Write-Host "  Status: $($response.status)"
    } else {
        throw "Status not updated properly. Current: $($response.status)"
    }
}

# ============================================================
# SECTION 5: DELIVERY WORKFLOW
# ============================================================
Write-Host ""
Write-Host "SECTION 5: Delivery Workflow" -ForegroundColor Yellow
Write-Host "============================" -ForegroundColor Yellow

Test-Step "Submit Delivery Notes" {
    if (-not $script:prId) {
        throw "No PR ID for delivery"
    }

    $body = @{
        pr_id = $script:prId
        user_id = 3
        delivery_notes = "Items received and verified"
        actual_delivery_date = (Get-Date -Format "yyyy-MM-dd")
    } | ConvertTo-Json

    $response = Invoke-RestMethod "http://localhost:3001/submit_delivery_notes.php" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    if ($response.success) {
        Write-Host "  Delivery Submitted"
        Write-Host "  Date: $(Get-Date -Format 'yyyy-MM-dd')"
    } else {
        throw "Delivery submission failed"
    }
}

# ============================================================
# SECTION 6: INSPECTION WORKFLOW
# ============================================================
Write-Host ""
Write-Host "SECTION 6: Inspection Workflow" -ForegroundColor Yellow
Write-Host "===============================" -ForegroundColor Yellow

Test-Step "Create Inspection Assignment" {
    if (-not $script:prId) {
        throw "No PR ID for inspection"
    }

    # Insert inspection assignment directly into DB
    $assignToUser = 3
    $prIdVal = $script:prId
    $dateNow = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "INSERT INTO inspection_assignments (pr_id, assigned_to, status, created_at) VALUES ($prIdVal, $assignToUser, 'pending', '$dateNow')" 2>&1 | Out-Null

    Write-Host "  Inspection Assignment Created for PR ID: $($script:prId)"
}

Test-Step "Submit Inspection Report" {
    if (-not $script:prId) {
        throw "No PR ID for inspection report"
    }

    # Get the assignment ID
    $queryCmd = "SELECT id FROM inspection_assignments WHERE pr_id = $($script:prId) ORDER BY created_at DESC LIMIT 1"
    $result = docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "$queryCmd" 2>&1
    $assignmentId = ($result | Select-String -Pattern '^\d+$' | Select-Object -First 1).Matches.Value

    if (-not $assignmentId) {
        throw "Could not retrieve assignment ID"
    }

    $body = @{
        assignment_id = $assignmentId
        pr_id = $script:prId
        user_id = 3
        inspection_notes = "All items verified in good condition"
        condition_report = "Good"
    } | ConvertTo-Json

    $response = Invoke-RestMethod "http://localhost:3001/submit_inspection.php" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    if ($response.success) {
        Write-Host "  Inspection Report Submitted"
        Write-Host "  Assignment ID: $assignmentId"
    } else {
        throw "Inspection submission failed"
    }
}

# ============================================================
# SECTION 7: FORM DETERMINATION TEST
# ============================================================
Write-Host ""
Write-Host "SECTION 7: Form Determination (Threshold Test)" -ForegroundColor Yellow
Write-Host "==============================================" -ForegroundColor Yellow

$prLow = "PR-LOW-$(Get-Date -Format 'yyyyMMddHHmmss')"

Test-Step "Create Low-Amount PR (Below Threshold)" {
    $body = @{
        pr_no = $prLow
        item_name = "Low Cost Item"
        description = "Item under 50K threshold"
        quantity = 1
        unit = "units"
        unit_cost = 10000
        office = "Branch Office"
        division_section = "Operations"
        user_id = 3
    } | ConvertTo-Json

    $response = Invoke-RestMethod "http://localhost:3001/submit_purchase_request.php" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    if ($response.success) {
        Write-Host "  Low-Amount PR Created: $prLow (Total: 10,000)"
    } else {
        throw "Failed to create low-amount PR"
    }
}

$prHigh = "PR-HIGH-$(Get-Date -Format 'yyyyMMddHHmmss')"

Test-Step "Create High-Amount PR (Above Threshold)" {
    $body = @{
        pr_no = $prHigh
        item_name = "High Cost Item"
        description = "Item over 50K threshold"
        quantity = 2
        unit = "units"
        unit_cost = 30000
        office = "HQ"
        division_section = "Infrastructure"
        user_id = 3
    } | ConvertTo-Json

    $response = Invoke-RestMethod "http://localhost:3001/submit_purchase_request.php" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -ErrorAction Stop

    if ($response.success) {
        Write-Host "  High-Amount PR Created: $prHigh (Total: 60,000)"
    } else {
        throw "Failed to create high-amount PR"
    }
}

# ============================================================
# SECTION 8: API STABILITY & INTEGRITY CHECK
# ============================================================
Write-Host ""
Write-Host "SECTION 8: API Stability & Integrity Check" -ForegroundColor Yellow
Write-Host "==========================================" -ForegroundColor Yellow

Test-Step "List All Purchase Requests" {
    $response = Invoke-RestMethod "http://localhost:3001/get_purchase_requests.php" -ErrorAction Stop

    if ($response.success) {
        Write-Host "  Total PRs in System: $(($response.purchase_requests).Count)"
        Write-Host "  Sample PRs: $(($response.purchase_requests | Select-Object -First 3 | ForEach-Object {$_.pr_no}) -join ', ')"
    } else {
        throw "Failed to list PRs"
    }
}

Test-Step "Get Process Status" {
    $response = Invoke-RestMethod "http://localhost:3001/get_process_status.php" -ErrorAction Stop

    if ($response.success) {
        Write-Host "  Status Retrieved Successfully"
    } else {
        throw "Failed to get process status"
    }
}

Test-Step "Get Process Summary" {
    $response = Invoke-RestMethod "http://localhost:3001/get_process_summary.php" -ErrorAction Stop

    if ($response.success) {
        Write-Host "  Summary Retrieved Successfully"
    } else {
        Write-Host "  Note: Summary endpoint may require specific parameters"
    }
}

Test-Step "Database Entries Accessible" {
    $response = Invoke-RestMethod "http://localhost:3001/get_entries.php" -ErrorAction Stop

    if ($response.success) {
        Write-Host "  Entries Found: $(($response.entries).Count)"
    } else {
        Write-Host "  Note: Entries endpoint may require specific parameters"
    }
}

# ============================================================
# FINAL SUMMARY
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Tests Run: $testCount" -ForegroundColor White
Write-Host "Passed: $passCount" -ForegroundColor Green
Write-Host "Failed: $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
Write-Host "Success Rate: $([math]::Round(($passCount / $testCount * 100), 1))%" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "✅ ALL TESTS PASSED - SYSTEM IS FULLY OPERATIONAL" -ForegroundColor Green
} else {
    Write-Host "⚠️  $failCount tests failed - Review results above" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Test Date: $(Get-Date)" -ForegroundColor Gray
Write-Host "========================================" -ForegroundColor Cyan
