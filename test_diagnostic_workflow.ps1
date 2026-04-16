# COMPREHENSIVE PURCHASE REQUEST WORKFLOW - DIAGNOSTIC TEST

$ErrorActionPreference = "Continue"
$backendUrl = "http://localhost:3001"
$userId = 3
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$prNo = "PR-DIAG-$timestamp"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "HEALTH CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Verify services
docker compose -f "c:\YUSH\ICS\Version Control\v14_ics_sys\docker-compose.yml" ps

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1: CREATE PURCHASE REQUEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$createBody = @{
    pr_no = $prNo
    item_name = "Diagnostic Test Equipment"
    description = "Testing workflow system"
    quantity = 3
    unit = "units"
    unit_cost = 5000.00
    total_amount = 15000.00
    office = "General Supply Division"
    division_section = "Quality Assurance"
    user_id = $userId
} | ConvertTo-Json

Write-Host "Creating PR: $prNo" -ForegroundColor Green

try {
    $response = Invoke-RestMethod -Uri "$backendUrl/submit_purchase_request.php" `
        -Method POST `
        -Body $createBody `
        -ContentType "application/json" `
        -TimeoutSec 10
    
    Write-Host "[SUCCESS] PR Created" -ForegroundColor Green
    Write-Host $response | ConvertTo-Json | Write-Host
    $prId = $response.pr_id
    if (!$prId) { $prId = $response.id }
    
    Write-Host "PR ID: $prId" -ForegroundColor Cyan
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 2: APPROVE PURCHASE REQUEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$approveBody = @{
    pr_id = $prId
    user_id = $userId
    action = "approve"
    notes = "Approved by diagnostic test"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$backendUrl/approve_purchase_request.php" `
        -Method POST `
        -Body $approveBody `
        -ContentType "application/json" `
        -TimeoutSec 10
    
    Write-Host "[SUCCESS] PR Approved" -ForegroundColor Green
    Write-Host $response | ConvertTo-Json | Write-Host
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 3: SUBMIT DELIVERY NOTES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$deliveryBody = @{
    pr_id = $prId
    user_id = $userId
    delivery_notes = "All diagnostic equipment received and verified."
    actual_delivery_date = (Get-Date -Format "yyyy-MM-dd")
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$backendUrl/submit_delivery_notes.php" `
        -Method POST `
        -Body $deliveryBody `
        -ContentType "application/json" `
        -TimeoutSec 10
    
    Write-Host "[SUCCESS] Delivery Notes Submitted" -ForegroundColor Green
    Write-Host $response | ConvertTo-Json | Write-Host
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 4: CREATE INSPECTION ASSIGNMENT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$assignCmd = "INSERT INTO inspection_assignments (pr_id, assigned_to, status) VALUES ($prId, $userId, 'pending')"
docker exec ics-mysql mysql -u root -prootpassword my_app_db -e $assignCmd 2>&1 | Out-Null

$assignmentIdResult = docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id FROM inspection_assignments WHERE pr_id = $prId LIMIT 1" 2>&1
$lines = $assignmentIdResult -split "`n"
$assignmentId = 1

foreach ($line in $lines) {
    if ($line -match '^\d+$' -and [int]$line -gt 0) {
        $assignmentId = [int]$line
        break
    }
}

Write-Host "Assignment ID: $assignmentId" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 5: SUBMIT INSPECTION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$inspectionBody = @{
    assignment_id = $assignmentId
    pr_id = $prId
    user_id = $userId
    inspection_notes = "Diagnostic inspection completed successfully."
    condition_report = "Equipment received in excellent condition."
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$backendUrl/submit_inspection.php" `
        -Method POST `
        -Body $inspectionBody `
        -ContentType "application/json" `
        -TimeoutSec 10
    
    Write-Host "[SUCCESS] Inspection Submitted" -ForegroundColor Green
    Write-Host $response | ConvertTo-Json | Write-Host
} catch {
    Write-Host "[ERROR] Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DATABASE VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Purchase Request Record:" -ForegroundColor Cyan
docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_no, item_name, quantity, total_amount, status, created_by FROM purchase_requests WHERE id = $prId\G"

Write-Host ""
Write-Host "Workflow History:" -ForegroundColor Cyan
docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_id, status_to, action_type, action_date FROM workflow_history WHERE pr_id = $prId ORDER BY action_date DESC\G"

Write-Host ""
Write-Host "Inspection Assignment:" -ForegroundColor Cyan
docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_id, assigned_to, status, completed_date FROM inspection_assignments WHERE pr_id = $prId\G"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TEST COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Summary:" -ForegroundColor Green
Write-Host "  PR Number: $prNo" -ForegroundColor White
Write-Host "  PR ID: $prId" -ForegroundColor White
Write-Host "  Status: WORKFLOW EXECUTED" -ForegroundColor Green
Write-Host ""
Write-Host "Database: http://localhost:8086" -ForegroundColor Cyan
Write-Host "Frontend: http://localhost:3000" -ForegroundColor Cyan
