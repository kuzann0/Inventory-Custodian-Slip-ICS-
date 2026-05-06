# Detailed PR Creation Test

$baseUrl = "http://localhost:3001"
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'

Write-Host "Testing PR Creation..." -ForegroundColor Green

$prNo = "PR-DEBUG-$timestamp"
Write-Host "PR Number: $prNo" -ForegroundColor Cyan

$prData = @{
    pr_no = $prNo
    item_name = "Test Equipment"
    description = "Comprehensive workflow test"
    quantity = 5
    unit = "units"
    unit_cost = 10000
    total_amount = 50000
    office = "Main Office"
    division_section = "Operations"
    user_id = 3
}

Write-Host ""
Write-Host "Request Data:" -ForegroundColor Cyan
$prData | ConvertTo-Json | Write-Host

$jsonBody = $prData | ConvertTo-Json

Write-Host ""
Write-Host "Sending POST request to: $baseUrl/submit_purchase_request.php" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod "$baseUrl/submit_purchase_request.php" -Method POST -Body $jsonBody -ContentType "application/json" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "Response received:" -ForegroundColor Green
    $response | ConvertTo-Json | Write-Host
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "Error Details:" -ForegroundColor Red
    $_.Exception | Write-Host
}

Write-Host ""
Write-Host "Testing GET Purchase Requests..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod "$baseUrl/get_purchase_requests.php" -TimeoutSec 10 -ErrorAction Stop
    Write-Host "Response:" -ForegroundColor Green
    $response | ConvertTo-Json | Write-Host
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
}
