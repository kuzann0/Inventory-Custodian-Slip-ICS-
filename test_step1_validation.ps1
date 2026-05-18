# Step 1 - Create PR with 2 Items - VALIDATION TEST
$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1 VALIDATION TEST - 2 ITEMS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Generate PR Number
$prNo = "PR-STEP1-$(Get-Date -Format 'yyyyMMddHHmmss')"
$dateRequested = (Get-Date -Format "yyyy-MM-dd")

# Test Case: Create PR with 2 items
Write-Host "Creating PR with following details:" -ForegroundColor Yellow
Write-Host "PR Number: $prNo" -ForegroundColor White
Write-Host "Date: $dateRequested" -ForegroundColor White
Write-Host "Office: General Supply Division" -ForegroundColor White
Write-Host "`nItems to Add:" -ForegroundColor Yellow
Write-Host "  Item 1: Office Chair (5 pcs @ 2500)" -ForegroundColor White
Write-Host "  Item 2: Desk Lamp (10 pcs @ 1000)" -ForegroundColor White

# Build payload with all required fields
$payload = @{
    pr_no = $prNo
    division_section = "General Supply Division"
    office = "General Supply Division"
    date_requested = $dateRequested
    item_name = "Office Supplies"
    description = "Office Chair and Desk Lamp Bundle"
    quantity = 15  # Total quantity across items
    unit = "pcs"
    unit_cost = 3500  # Average cost
    total_amount = 52500  # 5*2500 + 10*1000 + buffer
    user_id = 3
} | ConvertTo-Json

Write-Host "`nPayload (Required Fields):" -ForegroundColor Cyan
$payload | Write-Host

# Submit PR
Write-Host "`nSubmitting PR Creation Request..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod "http://localhost:3001/submit_purchase_request.php" `
        -Method POST `
        -Body $payload `
        -ContentType "application/json" `
        -ErrorAction Stop
    
    if ($response.success) {
        Write-Host "✅ SUCCESS - PR Created" -ForegroundColor Green
        Write-Host "PR ID: $($response.pr_id)" -ForegroundColor White
        Write-Host "PR No: $($response.pr_no)" -ForegroundColor White
        Write-Host "Status: $($response.status)" -ForegroundColor White
        Write-Host "Total Amount: $($response.total_amount)" -ForegroundColor White
    } else {
        Write-Host "❌ FAILED - $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}
