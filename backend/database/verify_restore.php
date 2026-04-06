<?php
$conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');

$result = $conn->query('SELECT COUNT(*) as cnt FROM capabilities');
$row = $result->fetch_assoc();
echo "✓ Capabilities: " . $row['cnt'] . "\n";

$result = $conn->query('SELECT COUNT(*) as cnt FROM users');
$row = $result->fetch_assoc();
echo "✓ Users: " . $row['cnt'] . "\n";

$result = $conn->query('SELECT COUNT(*) as cnt FROM user_capabilities');
$row = $result->fetch_assoc();
echo "✓ User Capabilities: " . $row['cnt'] . "\n";

$result = $conn->query('SHOW TABLES');
echo "✓ Tables: ";
while ($row = $result->fetch_row()) {
    echo $row[0] . ', ';
}
echo "\n";

$result = $conn->query("SELECT id, username, role_id FROM users LIMIT 10");
echo "✓ Users in database:\n";
while ($row = $result->fetch_assoc()) {
    echo "  - ID " . $row['id'] . ": " . $row['username'] . " (role " . $row['role_id'] . ")\n";
}
?>
