# Create test users and populate database

Write-Host "Creating test users..." -ForegroundColor Green

$users = @"
INSERT INTO users (username, password_hash, email, role, status, created_at) VALUES 
('superadmin', SHA2('SuperAdmin@2026', 256), 'superadmin@ics.local', 'admin', 'active', NOW()),
('admin', SHA2('Admin@2026', 256), 'admin@ics.local', 'admin', 'active', NOW()),
('kuzano', SHA2('Password@2026', 256), 'kuzano@ics.local', 'user', 'active', NOW());
"@

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "DELETE FROM users WHERE username != 'superadmin'"
echo "Reset users table"

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "INSERT INTO users (username, password_hash, email, role, status, created_at) VALUES ('admin', SHA2('Admin@2026', 256), 'admin@ics.local', 'admin', 'active', NOW())"

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "INSERT INTO users (username, password_hash, email, role, status, created_at) VALUES ('kuzano', SHA2('Password@2026', 256), 'kuzano@ics.local', 'user', 'active', NOW())"

Write-Host ""
Write-Host "Current users:" -ForegroundColor Green

docker exec ics-mysql mysql -u root -prootpassword my_app_db -e "SELECT id, username, email FROM users"

Write-Host ""
Write-Host "Done." -ForegroundColor Green
