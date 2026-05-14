write-host "=== STEP 1: Create Purchase Request ==="
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$pr_no = "PR-TEST-$timestamp"
$createJson = "{`"pr_no`":`"$pr_no`",`"item_name`":`"Test Item`",`"description`":`"Full Workflow Test`",`"quantity`":5,`"unit`":`"pcs`",`"unit_cost`":8000,`"office`":`"IT`",`"division_section`":`"Procurement`",`"user_id`":`"1`"}"
$createResponse = Invoke-WebRequest -Uri "http://localhost:3001/submit_purchase_request.php" -Method POST -Headers @{"X-User-ID"="1"} -Body $createJson -ContentType "application/json" -UseBasicParsing
$createResult = $createResponse.Content | ConvertFrom-Json
Write-Host $createResponse.Content
$pr_id = $createResult.pr_id

write-host ""
write-host "=== STEP 2: Approve Purchase Request ==="
$approveJson = "{`"pr_id`":$pr_id,`"action`":`"approve`",`"notes`":`"Approved for processing`",`"user_id`":`"1`"}"
$approveResponse = Invoke-WebRequest -Uri "http://localhost:3001/approve_purchase_request.php" -Method POST -Headers @{"X-User-ID"="1"} -Body $approveJson -ContentType "application/json" -UseBasicParsing
Write-Host $approveResponse.Content

write-host ""
write-host "=== STEP 3: Submit Delivery Notes ==="
$deliveryJson = "{`"pr_id`":$pr_id,`"delivery_notes`":`"Delivered to IT Department`",`"actual_delivery_date`":`"2026-04-11`",`"user_id`":`"1`"}"
$deliveryResponse = Invoke-WebRequest -Uri "http://localhost:3001/submit_delivery_notes.php" -Method POST -Headers @{"X-User-ID"="1"} -Body $deliveryJson -ContentType "application/json" -UseBasicParsing
Write-Host $deliveryResponse.Content

write-host ""
write-host "=== STEP 4: Submit Inspection ==="
$inspectionJson = "{`"assignment_id`":1,`"pr_id`":$pr_id,`"inspection_notes`":`"All items received and verified`",`"condition_report`":`"Good condition`",`"user_id`":`"1`"}"
$inspectionResponse = Invoke-WebRequest -Uri "http://localhost:3001/submit_inspection.php" -Method POST -Headers @{"X-User-ID"="1"} -Body $inspectionJson -ContentType "application/json" -UseBasicParsing
Write-Host $inspectionResponse.Content

write-host ""
write-host "=== WORKFLOW COMPLETE ==="
