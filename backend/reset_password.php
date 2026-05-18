<?php

$username = $_GET['username'] ?? 'admin';
$password = $_GET['password'] ?? 'password';

// Connect to database
$conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');

if ($conn->connect_error) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

$passwordHash = password_hash($password, PASSWORD_BCRYPT);

$sql = "UPDATE users SET password_hash = ? WHERE username = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param('ss', $passwordHash, $username);

if ($stmt->execute()) {
    echo json_encode([
        'status' => 'success',
        'message' => "Password for '$username' reset to '$password'",
        'hash' => $passwordHash
    ]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update password']);
}

$stmt->close();
$conn->close();
?>
