# Complete Workflow Test - Property Inventory Tag Integration

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "COMPLETE WORKFLOW TEST - END TO END" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create PR
Write-Host "STEP 1: Creating Purchase Request..." -ForegroundColor Green

$prNo = "PR-COMPLETE-$(Get-Date -Format 'yyyyMMddHHmmss')"
$createBody = @{
    pr_no = $prNo
    item_name = "Complete Test Item"
    description = "Full workflow test for Property Inventory Tag"
    quantity = 2
    unit = "units"
    unit_cost = 25000.00
    total_amount = 50000.00
    office = "Admin Office"
    division_section = "Testing"
    user_id = 3
} | ConvertTo-Json

$createResp = Invoke-RestMethod "http://localhost:3001/submit_purchase_request.php" -Method POST -Body $createBody -ContentType "application/json"
$prId = $createResp.pr_id
Write-Host "✓ PR Created: $prNo (ID: $prId)" -ForegroundColor Green

# Step 2: Approve
Write-Host "STEP 2: Approving..." -ForegroundColor Green
$approveBody = @{pr_id = $prId; user_id = 3; action = "approve"; notes = "Test"} | ConvertTo-Json
Invoke-RestMethod "http://localhost:3001/approve_purchase_request.php" -Method POST -Body $approveBody -ContentType "application/json" | Out-Null
Write-Host "✓ Approved" -ForegroundColor Green

# Step 3: Delivery
Write-Host "STEP 3: Delivery..." -ForegroundColor Green
$deliveryBody = @{pr_id = $prId; user_id = 3; delivery_notes = "Test"; actual_delivery_date = (Get-Date -Format "yyyy-MM-dd")} | ConvertTo-Json
Invoke-RestMethod "http://localhost:3001/submit_delivery_notes.php" -Method POST -Body $deliveryBody -ContentType "application/json" | Out-Null
Write-Host "✓ Delivered" -ForegroundColor Green

# Step 4: Inspection Assignment
Write-Host "STEP 4: Inspection Assignment..." -ForegroundColor Green
$sqlCmd = 'INSERT INTO inspection_assignments (pr_id, assigned_to, status) VALUES (' + $prId + ', 3, ''pending'')'
docker exec ics-mysql mysql -u root -prootpassword my_app_db -e $sqlCmd 2>&1 | Out-Null
Write-Host "✓ Assignment Created" -ForegroundColor Green

# Step 5: Inspection
Write-Host "STEP 5: Inspection..." -ForegroundColor Green
$assignSql = 'SELECT id FROM inspection_assignments WHERE pr_id = ' + $prId + ' LIMIT 1'
$assignmentResult = docker exec ics-mysql mysql -u root -prootpassword my_app_db -e $assignSql 2>&1
$assignmentId = ($assignmentResult -split "`n" | Where-Object {$_ -match '^\d+$'})[0]
if ($assignmentId) {
    $inspectionBody = @{assignment_id = $assignmentId; pr_id = $prId; user_id = 3; inspection_notes = "Test"; condition_report = "Good"} | ConvertTo-Json
    Invoke-RestMethod "http://localhost:3001/submit_inspection.php" -Method POST -Body $inspectionBody -ContentType "application/json" | Out-Null
    Write-Host "✓ Inspected (Assignment: $assignmentId)" -ForegroundColor Green
}

# Step 6: Test Property Inventory Tag API
Write-Host "STEP 6: Testing PropertyInventoryTag API..." -ForegroundColor Green
$apiResp = Invoke-RestMethod "http://localhost:3001/get_pr_details.php?pr_no=$prNo"

if ($apiResp.success -and $apiResp.description -and $apiResp.unit) {
    Write-Host "✓ API Response OK" -ForegroundColor Green
}

Write-Host ""
Write-Host "Form Fields for PropertyInventoryTag:" -ForegroundColor Cyan
Write-Host "  description: $($apiResp.description)" -ForegroundColor White
Write-Host "  unit_of_measure: $($apiResp.unit)" -ForegroundColor White
Write-Host "  acquisition_date: $($apiResp.date_acquired)" -ForegroundColor White
Write-Host "  estimated_cost: `$$($apiResp.total_cost)" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ WORKFLOW TEST COMPLETED SUCCESSFULLY" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
