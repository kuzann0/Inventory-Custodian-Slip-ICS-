# Simple login test
$body = @{ username = 'superadmin'; password = 'SuperAdmin@123' } | ConvertTo-Json
$r = Invoke-WebRequest -Uri 'http://localhost:3001/login.php' -Method POST -ContentType 'application/json' -Body $body -UseBasicParsing
$data = $r.Content | ConvertFrom-Json
$data | Format-List
