# Test the Property Inventory Tag endpoint
Write-Host '=== Testing Property Inventory Tag Feature ===' -ForegroundColor Cyan

# Step 1: Login
Write-Host 'Step 1: Authenticating superadmin...' -ForegroundColor Yellow
$loginBody = @{
    username = 'superadmin'
    password = 'SuperAdmin@2026'
} | ConvertTo-Json

$loginResp = Invoke-WebRequest -Uri 'http://localhost:3001/login.php' -Method POST -ContentType 'application/json' -Body $loginBody -UseBasicParsing
$loginData = $loginResp.Content | ConvertFrom-Json
$token = $loginData.token

Write-Host 'Logged in successfully' -ForegroundColor Green
Write-Host "  Token: $($token.Substring(0, 30))..."

# Step 2: Create PR with ABOVE PAR amount (>= 50,000)
Write-Host 'Step 2: Creating Purchase Request (Amount >= 50,000)...' -ForegroundColor Yellow
$timestamp = Get-Date -Format 'yyyyMMddHHmmss'
$prNumber = "PR-PROPERTY-TAG-$timestamp"

$prBody = @{
    pr_no = $prNumber
    item_name = 'Desktop Computer - ABOVE PAR'
    description = 'High-end workstation for design team'
    quantity = 2
    unit = 'units'
    unit_cost = 35000
    total_amount = 70000
    office = 'IT Department'
    division_section = 'Infrastructure'
    form_type = 'capital'
    notes = 'Above property threshold - needs fixed asset registration'
} | ConvertTo-Json

$prResp = Invoke-WebRequest -Uri 'http://localhost:3001/submit_purchase_request.php' -Method POST -ContentType 'application/json' -Headers @{ Authorization = "Bearer $token" } -Body $prBody -UseBasicParsing
$prData = $prResp.Content | ConvertFrom-Json

Write-Host "PR Created: $($prData.pr_no)" -ForegroundColor Green
Write-Host "  PR ID: $($prData.pr_id)"
Write-Host "  Amount: ₱70,000"

# Step 3: Submit property tag
Write-Host 'Step 3: Registering Property Inventory Tag (Fixed Asset Registration)...' -ForegroundColor Yellow
$propBody = @{
    pr_id = $prData.pr_id
    pr_no = $prData.pr_no
    property_number = 'PROP-2025-001'
    model_number = 'DELL-XPS15'
    description = 'DELL XPS 15 Laptop'
    unit_of_measure = 'units'
    acquisition_date = (Get-Date -Format 'yyyy-MM-dd')
    supplier = 'Dell Technologies'
    estimated_cost = 70000
    serial_number = 'SN12345678'
    location = 'Office 301'
    status = 'serviceable'
} | ConvertTo-Json

$propResp = Invoke-WebRequest -Uri 'http://localhost:3001/submit_property_tag.php' -Method POST -ContentType 'application/json' -Headers @{ 'X-User-ID' = '1' } -Body $propBody -UseBasicParsing
$propData = $propResp.Content | ConvertFrom-Json

if ($propData.success) {
    Write-Host 'SUCCESS! Property inventory tag registered as FIXED ASSET' -ForegroundColor Green
    Write-Host "  Property ID: $($propData.property_id)"
    Write-Host "  Property Number: $($propData.property_number)"
    Write-Host "  Status: $($propData.status)"
    Write-Host "  Classification: $($propData.threshold)"
} else {
    Write-Host "ERROR: $($propData.error)" -ForegroundColor Red
}

# Step 4: Verify in database
Write-Host ''
Write-Host 'Step 4: Verifying in database...' -ForegroundColor Yellow
$dbCheck = docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_no, property_number, description, estimated_cost, status FROM properties_inventory_tags ORDER BY id DESC LIMIT 1;"
Write-Host $dbCheck -ForegroundColor Cyan

Write-Host ''
Write-Host '=== Test Complete ===' -ForegroundColor Green
