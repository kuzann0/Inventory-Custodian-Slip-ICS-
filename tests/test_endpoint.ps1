$json = '{"pr_no":"PR-TEST-001","item_name":"Test","description":"Desc","quantity":10,"unit":"pcs","unit_cost":1000,"office":"Office","division_section":"Section","user_id":"1"}'

$response = Invoke-WebRequest -Uri "http://localhost:3001/submit_purchase_request.php" -Method POST -Headers @{"X-User-ID"="1"} -Body $json -ContentType "application/json" -UseBasicParsing

Write-Host $response.Content
