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

$userId = $_SESSION['user_id'];
$roleId = isset($_SESSION['role_id']) ? intval($_SESSION['role_id']) : null;

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

// Build query based on user role
// Role 1 = SuperAdmin, Role 2 = Admin, Role 3 = Employee
// Employees see only their own entries, Admins see all
$sql = "SELECT LPAD(order_id, 6, '0') AS order_id,
  Quantity, Unit, Amount, UnitCost, TotalCost,
  Description, Item, SerialNo, DateAcquired,
  Location, InventoryItemNo, EstimatedUsefulLife,
  'pending' AS status
  FROM entries";

// If user is employee (role_id = 3), filter by created_by
if ($roleId === 3) {
  $sql .= " WHERE created_by = " . intval($userId);
}

$result = $conn->query($sql);

$rows = [];
if ($result) {
  while($row = $result->fetch_assoc()) {
    $rows[] = $row;
  }
} else {
  http_response_code(500);
  echo json_encode(["status" => "error", "message" => $conn->error]);
  $conn->close();
  exit;
}

http_response_code(200);
echo json_encode(["status" => "success", "data" => $rows]);
$conn->close();
?>