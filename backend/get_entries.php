<?php
// Enable CORS - Allow from any origin with credentials
$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Requested-With");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit(0);
}

session_start();

// Check if user is authenticated
if (!isset($_SESSION['user_id'])) {
  http_response_code(401);
  echo json_encode(["status" => "error", "message" => "User not authenticated"]);
  exit;
}

$servername = "db";
$username   = "root";
$password   = "rootpassword";
$dbname     = "my_app_db";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
  http_response_code(500);
  echo json_encode(["status" => "error", "message" => "Connection failed"]);
  exit;
}

$sql = "SELECT LPAD(order_id, 6, '0') AS order_id,
  Quantity, Unit, Amount, UnitCost, TotalCost,
  Description, Item, SerialNo, DateAcquired,
  Location, InventoryItemNo, EstimatedUsefulLife
  FROM entries";

$result = $conn->query($sql);

$rows = [];
if ($result) {
  while($row = $result->fetch_assoc()) {
    $rows[] = $row;
  }
} else {
  echo json_encode(["error" => $conn->error]);
  $conn->close();
  exit;
}

echo json_encode($rows);
$conn->close();
?>