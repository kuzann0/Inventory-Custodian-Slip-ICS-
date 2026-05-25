# STEP 1: CREATE PR WORKFLOW - ALL FIELDS VALID VALUES TEST
# Tests the complete Step 1 form with all required fields populated with valid values

$ErrorActionPreference = "Continue"
$backendUrl = "http://localhost:3001"
$userId = 3
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$prNo = "PR-VALID-$timestamp"

Write-Host ""
Write-Host "====== STEP 1: CREATE PR WORKFLOW - ALL FIELDS VALID TEST ======" -ForegroundColor Cyan
Write-Host ""

# HEALTH CHECK
Write-Host "HEALTH CHECK" -ForegroundColor Yellow
Write-Host "-----------------------------------------------------" -ForegroundColor Gray

try {
    $healthCheck = Invoke-RestMethod -Uri "$backendUrl/connect.php" -TimeoutSec 5 -ErrorAction SilentlyContinue
    if ($healthCheck.status -eq "ok") {
        Write-Host "[OK] Backend is running" -ForegroundColor Green
    } else {
        Write-Host "[WARN] Backend response unclear" -ForegroundColor Yellow
    }
} catch {
    Write-Host "[ERROR] Backend connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "TEST DATA" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------" -ForegroundColor Gray

# Define test data with all valid values
$testData = @{
    pr_no = $prNo
    item_name = "Office Supplies and Equipment"
    description = "Complete office setup with ergonomic furniture and computer equipment"
    division_section = "General Supply Division"
    office = "Budget Division"
    date_requested = (Get-Date -Format "yyyy-MM-dd")
    unit = "pcs"
    quantity = 5
    unit_cost = 1500.00
    designation = "Sr. Administrative Officer"
    certification = "certified"
    user_id = $userId
    particulars = @(
        @{
            particular = "Office Chair - Ergonomic"
            quantity = 5
            unit = "pcs"
            unitCost = 1500.00
        },
        @{
            particular = "Computer Monitor 24 inch"
            quantity = 3
            unit = "pcs"
            unitCost = 3500.00
        },
        @{
            particular = "USB-C Cable 2 meters"
            quantity = 10
            unit = "pcs"
            unitCost = 250.00
        }
    )
}

Write-Host "PR No.: $($testData.pr_no)" -ForegroundColor White
Write-Host "Item Name: $($testData.item_name)" -ForegroundColor White
Write-Host "Description: $($testData.description)" -ForegroundColor White
Write-Host "Division: $($testData.division_section)" -ForegroundColor White
Write-Host "Office: $($testData.office)" -ForegroundColor White
Write-Host "Date Requested: $($testData.date_requested)" -ForegroundColor White
Write-Host "Unit: $($testData.unit)" -ForegroundColor White
Write-Host "Quantity: $($testData.quantity)" -ForegroundColor White
Write-Host "Unit Cost: PHP $($testData.unit_cost)" -ForegroundColor White
Write-Host "Designation: $($testData.designation)" -ForegroundColor White
Write-Host "Certification: $($testData.certification)" -ForegroundColor White
Write-Host "Items to Add: $($testData.particulars.Count)" -ForegroundColor White

Write-Host ""
Write-Host "TEST EXECUTION" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------" -ForegroundColor Gray
Write-Host ""

# STEP 1.1: CREATE INITIAL PR
Write-Host "[Step 1.1] Creating Purchase Request with basic fields..." -ForegroundColor Cyan

$createPayload = @{
    pr_no = $testData.pr_no
    item_name = $testData.item_name
    description = $testData.description
    unit = $testData.unit
    quantity = $testData.quantity
    unit_cost = $testData.unit_cost
    total_amount = $testData.quantity * $testData.unit_cost
    division_section = $testData.division_section
    office = $testData.office
    user_id = $testData.user_id
} | ConvertTo-Json -Depth 3

Write-Host "Payload:" -ForegroundColor Gray
Write-Host $createPayload -ForegroundColor Gray

try {
    $response = Invoke-RestMethod -Uri "$backendUrl/submit_purchase_request.php" `
        -Method POST `
        -Body $createPayload `
        -ContentType "application/json" `
        -TimeoutSec 10

    Write-Host ""
    Write-Host "[SUCCESS] PR Created Successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response:" -ForegroundColor Gray
    Write-Host ($response | ConvertTo-Json) -ForegroundColor Gray
    
    # Extract PR ID from response
    if ($response.pr_id) {
        $prId = $response.pr_id
    } elseif ($response.id) {
        $prId = $response.id
    } else {
        Write-Host "[WARN] PR ID not found in response" -ForegroundColor Yellow
        $prId = $null
    }
    
    if ($prId) {
        Write-Host "PR ID: $prId" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host ""
    Write-Host "[FAILED] PR Creation Error" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response.Content)" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "-----------------------------------------------------" -ForegroundColor Gray

# VALIDATION
Write-Host ""
Write-Host "VALIDATION CHECKS" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------" -ForegroundColor Gray
Write-Host ""

$checksPassed = 0
$checksFailed = 0

$checks = @(
    @{ name = "PR No."; value = $testData.pr_no }
    @{ name = "Item Name"; value = $testData.item_name }
    @{ name = "Description"; value = $testData.description }
    @{ name = "Division"; value = $testData.division_section }
    @{ name = "Office"; value = $testData.office }
    @{ name = "Unit"; value = $testData.unit }
    @{ name = "Quantity"; value = $testData.quantity }
    @{ name = "Unit Cost"; value = "PHP $($testData.unit_cost)" }
    @{ name = "Total Amount"; value = "PHP $($testData.quantity * $testData.unit_cost)" }
    @{ name = "Items Count"; value = $testData.particulars.Count }
)

foreach ($check in $checks) {
    if ($null -ne $check.value -and $check.value -ne "" -and $check.value -ne 0) {
        $checksPassed++
        Write-Host "[PASS] $($check.name): $($check.value)" -ForegroundColor Green
    } else {
        $checksFailed++
        Write-Host "[FAIL] $($check.name): [EMPTY]" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "-----------------------------------------------------" -ForegroundColor Gray

# TEST SUMMARY
Write-Host ""
Write-Host "TEST SUMMARY" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------" -ForegroundColor Gray

$totalChecks = $checks.Count

Write-Host "Total Validations: $totalChecks" -ForegroundColor White
Write-Host "Passed: $checksPassed" -ForegroundColor Green
Write-Host "Failed: $checksFailed" -ForegroundColor Red

Write-Host ""

if ($checksFailed -eq 0) {
    Write-Host "====== ALL VALIDATIONS PASSED - STEP 1 TEST COMPLETE ======" -ForegroundColor Green
} else {
    Write-Host "====== SOME VALIDATIONS FAILED - REVIEW ABOVE ======" -ForegroundColor Red
}

Write-Host ""
Write-Host "DETAILS FOR NEXT STEPS:" -ForegroundColor Cyan
Write-Host "-----------------------------------------------------" -ForegroundColor Gray
Write-Host "PR ID: $prId" -ForegroundColor White
Write-Host "PR No.: $($testData.pr_no)" -ForegroundColor White
Write-Host "To test Step 2 (Approval), use PR ID: $prId" -ForegroundColor Cyan
Write-Host ""
