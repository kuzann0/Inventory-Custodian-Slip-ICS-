<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

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