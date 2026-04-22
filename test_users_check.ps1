# Check Users Table

Write-Host "Checking users table..." -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, username, email FROM users LIMIT 10"

Write-Host ""
Write-Host "Checking purchase_requests table structure..." -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "DESCRIBE purchase_requests"

Write-Host ""
Write-Host "Checking user_id values in existing PRs..." -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, pr_no, user_id, created_by FROM purchase_requests"
