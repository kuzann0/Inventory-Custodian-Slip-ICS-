# Check users table structure

Write-Host "Checking users table structure..." -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "DESCRIBE users"

Write-Host ""
Write-Host "Creating users with correct columns..." -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "INSERT INTO users (username, password_hash, email, status, created_at) VALUES ('admin', SHA2('Admin@2026', 256), 'admin@ics.local', 'active', NOW())"

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "INSERT INTO users (username, password_hash, email, status, created_at) VALUES ('kuzano', SHA2('Password@2026', 256), 'kuzano@ics.local', 'active', NOW())"

Write-Host ""
Write-Host "Current users:" -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, username, email FROM users"
