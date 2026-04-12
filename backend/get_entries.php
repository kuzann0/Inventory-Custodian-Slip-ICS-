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

// Get user ID from multiple sources
$userId = null;

// Priority 1: Try session (PHP session should work for same-domain)
if (isset($_SESSION['user_id'])) {
  $userId = intval($_SESSION['user_id']);
}

// Priority 2: Try request header (for cross-origin requests)
if (!$userId && isset($_SERVER['HTTP_X_USER_ID'])) {
  $userId = intval($_SERVER['HTTP_X_USER_ID']);
}

// Priority 3: Try query parameter (for testing)
if (!$userId && isset($_GET['user_id'])) {
  $userId = intval($_GET['user_id']);
}

// If still no user, try default (for development/testing)
if (!$userId) {
  // For now, default to user 3 for testing
  $userId = 3;
}

$roleId = isset($_SESSION['role_id']) ? intval($_SESSION['role_id']) : null;
if (!$roleId && isset($_SERVER['HTTP_X_ROLE_ID'])) {
  $roleId = intval($_SERVER['HTTP_X_ROLE_ID']);
}
if (!$roleId) {
  // Default to employee role for testing
  $roleId = 3;
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

// Build query based on user role
// Role 1 = SuperAdmin, Role 2 = Admin, Role 3 = Employee
// Employees see only their own entries, Admins see all
// Query purchase_requests table
$sql = "SELECT 
  id AS order_id,
  pr_no,
  item_name AS Item,
  description AS Description,
  quantity AS Quantity,
  unit AS Unit,
  unit_cost AS UnitCost,
  total_amount AS TotalCost,
  office AS Location,
  status,
  created_at AS DateAcquired,
  created_by,
  form_type
  FROM purchase_requests";

// If user is employee (role_id = 3), filter by created_by
if ($roleId === 3) {
  $sql .= " WHERE created_by = " . intval($userId);
} else {
  // Admins and SuperAdmins see all
  $sql .= " WHERE 1=1";
}

$sql .= " ORDER BY created_at DESC";

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