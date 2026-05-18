<?php

require_once 'config/cors.php';

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  exit(0);
}

$servername = "db";
$username   = "root";
$password   = "rootpassword";
$dbname     = "my_app_db";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  echo json_encode(["status" => "error", "message" => "Connection failed: " . $conn->connect_error]);
  exit;
}

echo json_encode(["status" => "success", "message" => "Connected to database successfully"]);
$conn->close();
?>