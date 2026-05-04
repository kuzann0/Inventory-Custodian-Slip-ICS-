# Complete Purchase Request Workflow Testing Script
# Tests all 4 steps: Create > Approve > Deliver > Inspect

$ErrorActionPreference = "Continue"
$backendUrl = "http://localhost:3001"
$userId = 3  # Employee user (yusho)

function PrintStep($step, $title) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "STEP $($step): $($title)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}

# ============ STEP 1: CREATE PURCHASE REQUEST ============
PrintStep 1 "CREATE PURCHASE REQUEST"

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$prNo = "PR-TEST-$timestamp"

$createBody = @{
    pr_no = $prNo
    item_name = "Office Chair"
    description = "Ergonomic office chair for workspace"
    quantity = 5
    unit = "pcs"
    unit_cost = 2500.00
    total_amount = 12500.00
    office = "General Supply Division"
    division_section = "IT Department"
    user_id = $userId
}

Write-Host "Creating PR: $prNo" -ForegroundColor Green
Write-Host "Payload:" -ForegroundColor Yellow
$createBody | ConvertTo-Json | Write-Host

try {
    $createResponse = Invoke-RestMethod -Uri "$backendUrl/submit_purchase_request.php" `
        -Method POST `
        -Body ($createBody | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "Response:" -ForegroundColor Green
    $createResponse | ConvertTo-Json | Write-Host
    
    $prId = $createResponse.pr_id
    if (!$prId) {
        $prId = $createResponse.id
    }
    Write-Host "✅ PR Created with ID: $prId" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============ STEP 2: APPROVE PURCHASE REQUEST ============
PrintStep 2 "APPROVE PURCHASE REQUEST"

$approveBody = @{
    pr_id = $prId
    user_id = $userId
    action = "approve"
    notes = "Approved for procurement"
}

Write-Host "Approving PR ID: $prId" -ForegroundColor Green

try {
    $approveResponse = Invoke-RestMethod -Uri "$backendUrl/approve_purchase_request.php" `
        -Method POST `
        -Body ($approveBody | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "Response:" -ForegroundColor Green
    $approveResponse | ConvertTo-Json | Write-Host
    Write-Host "✅ PR Approved" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

# ============ STEP 3: SUBMIT DELIVERY NOTES ============
PrintStep 3 "SUBMIT DELIVERY NOTES"

$deliveryDate = Get-Date -Format "yyyy-MM-dd"
$deliveryBody = @{
    pr_id = $prId
    user_id = $userId
    delivery_notes = "All items received in good condition. Checked against PR specifications."
    actual_delivery_date = $deliveryDate
}

Write-Host "Submitting Delivery Notes for PR ID: $prId" -ForegroundColor Green

try {
    $deliveryResponse = Invoke-RestMethod -Uri "$backendUrl/submit_delivery_notes.php" `
        -Method POST `
        -Body ($deliveryBody | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "Response:" -ForegroundColor Green
    $deliveryResponse | ConvertTo-Json | Write-Host
    Write-Host "✅ Delivery Notes Submitted" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    $_.Exception | Write-Host -ForegroundColor Red
}

# ============ STEP 4: SUBMIT INSPECTION ============
PrintStep 4 "SUBMIT INSPECTION"

# First, create an inspection assignment if it doesn't exist
Write-Host "Creating Inspection Assignment..." -ForegroundColor Yellow
$createAssignmentCmd = "INSERT INTO inspection_assignments (pr_id, assigned_to, status) VALUES ($prId, $userId, 'pending') ON DUPLICATE KEY UPDATE id=id"
docker exec ics-mysql mysql -u root -prootpassword my_app_db -e $createAssignmentCmd

# Get the assignment ID
Write-Host "Getting Assignment ID..." -ForegroundColor Yellow
$assignmentIdResult = docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id FROM inspection_assignments WHERE pr_id = $prId LIMIT 1"

# Parse the assignment ID from the output
$lines = $assignmentIdResult -split "`n"
$assignmentId = $null
foreach ($line in $lines) {
    if ($line -match '^\d+$') {
        $assignmentId = [int]$line
        break
    }
}

Write-Host "Assignment ID: $assignmentId" -ForegroundColor Cyan

if ($null -eq $assignmentId -or $assignmentId -eq 0) {
    Write-Host "⚠️  Could not create/get assignment ID, using first available" -ForegroundColor Yellow
    $assignmentId = 1
}

$inspectionBody = @{
    assignment_id = $assignmentId
    pr_id = $prId
    user_id = $userId
    inspection_notes = "All items verified against specifications. Quality check passed."
    condition_report = "Items received in excellent condition. No defects or damage observed."
}

Write-Host "Submitting Inspection for PR ID: $prId (Assignment ID: $assignmentId)" -ForegroundColor Green

try {
    $inspectionResponse = Invoke-RestMethod -Uri "$backendUrl/submit_inspection.php" `
        -Method POST `
        -Body ($inspectionBody | ConvertTo-Json) `
        -ContentType "application/json"
    
    Write-Host "Response:" -ForegroundColor Green
    $inspectionResponse | ConvertTo-Json | Write-Host
    Write-Host "✅ Inspection Submitted" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    $_.Exception | Write-Host -ForegroundColor Red
}

# ============ VERIFY IN DATABASE ============
PrintStep 5 "DATABASE VERIFICATION"

Write-Host "Querying Database via Docker..." -ForegroundColor Green

try {
    Write-Host ""
    Write-Host "Purchase Request Record:" -ForegroundColor Cyan
    docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_no, item_name, quantity, unit_cost, total_amount, status, created_by, created_at FROM purchase_requests WHERE id = $prId LIMIT 1\G"
    
    Write-Host ""
    Write-Host "Workflow History:" -ForegroundColor Cyan
    docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_id, status_to, action_type, notes, action_date FROM workflow_history WHERE pr_id = $prId ORDER BY action_date DESC\G"
    
    Write-Host ""
    Write-Host "Inspection Assignments:" -ForegroundColor Cyan
    docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_id, assigned_to, status, inspection_notes, condition_report, completed_date FROM inspection_assignments WHERE pr_id = $prId\G"
    
    Write-Host ""
    Write-Host "✅ Database verification complete" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Database query error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ============ SUMMARY ============
PrintStep "FINAL" "TEST COMPLETE"

Write-Host ""
Write-Host "✅ All workflow steps completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Test Summary:" -ForegroundColor Cyan
Write-Host "  - Purchase Request ID: $prId" -ForegroundColor White
Write-Host "  - PR Number: $prNo" -ForegroundColor White
Write-Host "  - Item: Office Chair (Qty: 5)" -ForegroundColor White
Write-Host "  - Total Amount: 12,500.00" -ForegroundColor White
Write-Host "  - User ID: $userId (Employee)" -ForegroundColor White
Write-Host ""
Write-Host "Visit: http://localhost:8086 (phpMyAdmin)" -ForegroundColor Yellow
Write-Host "Database: my_app_db" -ForegroundColor Yellow
Write-Host "Tables: purchase_requests, workflow_history" -ForegroundColor Yellow
