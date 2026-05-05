<?php
// Test endpoint to verify purchase requests exist (no auth required)
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

$servername = "db";
$username   = "root";
$password   = "rootpassword";
$dbname     = "my_app_db";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  http_response_code(500);
  echo json_encode(["error" => "Connection failed: " . $conn->connect_error]);
  exit;
}

$sql = "SELECT id, pr_no, item_name, quantity, unit_cost, total_amount, created_by FROM purchase_requests ORDER BY created_at DESC";
$result = $conn->query($sql);

$entries = [];
if ($result) {
  while($row = $result->fetch_assoc()) {
    $entries[] = $row;
  }
}

http_response_code(200);
echo json_encode([
  "status" => "success", 
  "count" => count($entries),
  "data" => $entries
]);
$conn->close();
?>
