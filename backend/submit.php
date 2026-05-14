<?php
session_start();

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
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

// Collect POST data
$quantity            = $_POST['Quantity'] ?? '';
$unit                = $_POST['Unit'] ?? '';
$amount              = $_POST['Amount'] ?? '';
$unitCost            = $_POST['UnitCost'] ?? '';
$totalCost           = $_POST['TotalCost'] ?? '';
$description         = $_POST['Description'] ?? '';
$item                = $_POST['Item'] ?? '';
$serialNo            = $_POST['SerialNo'] ?? '';
$dateAcquired        = $_POST['DateAcquired'] ?? '';
$location            = $_POST['Location'] ?? '';
$inventoryItemNo     = $_POST['InventoryItemNo'] ?? '';
$estimatedUsefulLife = $_POST['EstimatedUsefulLife'] ?? '';

// Prepare insert
$stmt = $conn->prepare("INSERT INTO entries 
  (Quantity, Unit, Amount, UnitCost, TotalCost, Description, Item, SerialNo, DateAcquired, Location, InventoryItemNo, EstimatedUsefulLife) 
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");

$stmt->bind_param(
  "isddssssssss",
  $quantity, $unit, $amount, $unitCost, $totalCost,
  $description, $item, $serialNo, $dateAcquired,
  $location, $inventoryItemNo, $estimatedUsefulLife
);

if ($stmt->execute()) {
  echo json_encode(["status" => "success", "message" => "New record created successfully"]);
} else {
  if ($conn->errno === 1062) { // duplicate entry error
    echo json_encode([
      "status" => "error",
      "message" => "Duplicate entry – Serial No or Inventory Item No already exists"
    ]);
  } else {
    echo json_encode(["status" => "error", "message" => $stmt->error]);
  }
}

$stmt->close();
$conn->close();
?>