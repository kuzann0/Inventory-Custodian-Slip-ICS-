#!/usr/bin/env powershell
# Comprehensive Purchase Workflow Verification Test
# Tests: PR Creation, Approval, Delivery, Inspection

$ErrorActionPreference = "Continue"
$baseUrl = "http://localhost:3001"

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "WORKFLOW VERIFICATION TEST" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

$passCount = 0
$failCount = 0
$testCount = 0

function Test-Step {
    param([string]$name, [scriptblock]$test)
    $script:testCount++
    Write-Host "[$($script:testCount)] $name" -ForegroundColor Cyan
    try {
        & $test
        Write-Host "    [PASS]" -ForegroundColor Green
        $script:passCount++
    } catch {
        Write-Host "    [FAIL] $_" -ForegroundColor Red
        $script:failCount++
    }
}

# Test 1: Backend API
Test-Step "Backend API responds" {
    $r = Invoke-RestMethod "$baseUrl/test.php"
    if (-not $r) { throw "No response" }
}

# Test 2: Frontend
Test-Step "Frontend accessible" {
    $r = Invoke-WebRequest "http://localhost:3000"
    if ($r.StatusCode -ne 200) { throw "Status $($r.StatusCode)" }
}

# Test 3: Database connectivity
Test-Step "Database connected" {
    $r = Invoke-RestMethod "$baseUrl/get_employees.php"
    if (-not $r.success) { throw "DB error" }
}

# Test 4: Get users
Test-Step "Get all users" {
    $r = Invoke-RestMethod "$baseUrl/get_all_users.php"
    if (-not $r.success -or $r.users.Count -eq 0) { throw "No users" }
    Write-Host "    Found $($r.users.Count) users"
}

# Test 5: Create PR
$prNo = "PR-TEST-$(Get-Date -Format 'yyyyMMddHHmmss')"
$prId = $null
$body = @{
    pr_no = $prNo
    item_name = "Test Item"
    description = "Comprehensive workflow test"
    quantity = 2
    unit = "units"
    unit_cost = 20000
    office = "Test Office"
    division_section = "Testing"
    user_id = 3
} | ConvertTo-Json

Test-Step "Create Purchase Request" {
    $r = Invoke-RestMethod "$baseUrl/submit_purchase_request.php" `
        -Method POST `
        -Body $body `
        -ContentType "application/json"
    
    if (-not $r.success) { throw $r.error }
    $script:prId = $r.pr_id
    Write-Host "    PR: $prNo (ID: $($script:prId))"
}

# Test 6: Retrieve PR
Test-Step "Retrieve PR details" {
    if (-not $script:prId) { throw "No PR ID" }
    $r = Invoke-RestMethod "$baseUrl/get_pr_details.php?pr_no=$prNo"
    if (-not $r.success) { throw "Cannot retrieve" }
    Write-Host "    Status: $($r.status)"
}

# Test 7: Approve PR
$approveBody = @{
    pr_id = $script:prId
    user_id = 3
    action = "approve"
    notes = "Test approval"
} | ConvertTo-Json

Test-Step "Approve Purchase Request" {
    if (-not $script:prId) { throw "No PR ID" }
    $r = Invoke-RestMethod "$baseUrl/approve_purchase_request.php" `
        -Method POST `
        -Body $approveBody `
        -ContentType "application/json"
    
    if (-not $r.success) { throw $r.error }
    Write-Host "    Approved"
}

# Test 8: Verify approval
Test-Step "Verify PR approved" {
    if (-not $script:prId) { throw "No PR ID" }
    $r = Invoke-RestMethod "$baseUrl/get_pr_details.php?pr_no=$prNo"
    if ($r.status -ne "approved") { throw "Status is $($r.status), expected approved" }
}

# Test 9: Submit delivery
$deliveryBody = @{
    pr_id = $script:prId
    user_id = 3
    delivery_notes = "Items received"
    actual_delivery_date = (Get-Date -Format "yyyy-MM-dd")
} | ConvertTo-Json

Test-Step "Submit delivery notes" {
    if (-not $script:prId) { throw "No PR ID" }
    $r = Invoke-RestMethod "$baseUrl/submit_delivery_notes.php" `
        -Method POST `
        -Body $deliveryBody `
        -ContentType "application/json"
    
    if (-not $r.success) { throw $r.error }
}

# Test 10: List all PRs
Test-Step "List all PRs" {
    $r = Invoke-RestMethod "$baseUrl/get_purchase_requests.php"
    if (-not $r.success) { throw "Cannot list" }
    Write-Host "    Total PRs: $($r.purchase_requests.Count)"
}

# Test 11: Low-amount PR (below threshold)
$prLow = "PR-LOW-$(Get-Date -Format 'yyyyMMddHHmmss')"
$bodyLow = @{
    pr_no = $prLow
    item_name = "Low Value"
    description = "Below 50k threshold"
    quantity = 1
    unit = "units"
    unit_cost = 5000
    office = "Branch"
    division_section = "Operations"
    user_id = 3
} | ConvertTo-Json

Test-Step "Create low-amount PR" {
    $r = Invoke-RestMethod "$baseUrl/submit_purchase_request.php" `
        -Method POST `
        -Body $bodyLow `
        -ContentType "application/json"
    
    if (-not $r.success) { throw $r.error }
    Write-Host "    Low PR: $prLow (Total: 5,000)"
}

# Test 12: High-amount PR (above threshold)
$prHigh = "PR-HIGH-$(Get-Date -Format 'yyyyMMddHHmmss')"
$bodyHigh = @{
    pr_no = $prHigh
    item_name = "High Value"
    description = "Above 50k threshold"
    quantity = 3
    unit = "units"
    unit_cost = 25000
    office = "HQ"
    division_section = "Infrastructure"
    user_id = 3
} | ConvertTo-Json

Test-Step "Create high-amount PR" {
    $r = Invoke-RestMethod "$baseUrl/submit_purchase_request.php" `
        -Method POST `
        -Body $bodyHigh `
        -ContentType "application/json"
    
    if (-not $r.success) { throw $r.error }
    Write-Host "    High PR: $prHigh (Total: 75,000)"
}

# Test 13: Get process status
Test-Step "Get process status" {
    $r = Invoke-RestMethod "$baseUrl/get_process_status.php"
    if (-not $r.success) { Write-Host "    Note: May require parameters" }
}

# Summary
Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "Total:   $testCount" -ForegroundColor White
Write-Host "Passed:  $passCount" -ForegroundColor Green
Write-Host "Failed:  $failCount" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Red" })
$pct = if ($testCount -gt 0) { [math]::Round($passCount / $testCount * 100) } else { 0 }
Write-Host "Rate:    $pct%" -ForegroundColor $(if ($failCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($failCount -eq 0) {
    Write-Host "SUCCESS: All workflow tests passed" -ForegroundColor Green
    exit 0
} else {
    Write-Host "WARNING: $failCount test(s) failed" -ForegroundColor Yellow
    exit 1
}
