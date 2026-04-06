<?php
$conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
if ($conn->connect_error) {
    echo json_encode(['error' => 'DB connection failed']);
    exit;
}

// Check if user exists
$result = $conn->query('SELECT id, username, email, password_hash FROM users WHERE username="kuzano"');
if ($result && $row = $result->fetch_assoc()) {
    echo "✓ User found: " . $row['username'] . " (" . $row['email'] . ")\n";
    echo "Password hash: " . substr($row['password_hash'], 0, 20) . "...\n";
} else {
    echo "✗ User kuzano not found\n";
}

// Check all users
echo "\nAll users:\n";
$result = $conn->query('SELECT id, username, email FROM users');
while ($row = $result->fetch_assoc()) {
    echo "  - " . $row['username'] . " (" . $row['email'] . ")\n";
}

$conn->close();
?>
