# Create users with correct columns

Write-Host "Creating test users..." -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "INSERT INTO users (username, password_hash, email, account_status, role_id, is_superadmin) VALUES ('admin', SHA2('Admin@2026', 256), 'admin@ics.local', 'active', 1, 0)"

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "INSERT INTO users (username, password_hash, email, account_status, role_id, is_superadmin) VALUES ('kuzano', SHA2('Password@2026', 256), 'kuzano@ics.local', 'active', 2, 0)"

Write-Host ""
Write-Host "Current users:" -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, username, email, account_status FROM users"

Write-Host ""
Write-Host "Users are now ready for testing." -ForegroundColor Green
