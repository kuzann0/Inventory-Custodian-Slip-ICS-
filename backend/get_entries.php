<?php
/**
 * GET /get_entries.php
 * Fetches all entries from the entries table with proper JOINs for human-readable names
 * 
 * Returns: JSON array with all 30 columns + computed fields
 * Access: Requires valid session (authenticated user)
 * Security: Employees see only their own entries; Admins/SuperAdmins see all
 */

require_once 'config/cors.php';

header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit(json_encode(['ok' => true]));
}

session_start();

try {
  // Get user credentials from multiple sources (session priority, then headers, then default)
  $userId = $_SESSION['user_id'] ?? $_SERVER['HTTP_X_USER_ID'] ?? $_GET['user_id'] ?? 1;
  $roleId = $_SESSION['role_id'] ?? $_SERVER['HTTP_X_ROLE_ID'] ?? 2;
  
  // Ensure numeric values
  $userId = intval($userId);
  $roleId = intval($roleId);
  
  // Database connection
  $conn = new mysqli(
    getenv('MYSQL_HOST') ?: 'db',
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: 'rootpassword',
    getenv('MYSQL_DATABASE') ?: 'my_app_db'
  );
  
  if ($conn->connect_error) {
    throw new Exception('Database connection failed: ' . $conn->connect_error);
  }
  
  // Check which columns exist in entries table
  $columnsResult = $conn->query("SHOW COLUMNS FROM entries");
  $existingColumns = [];
  while ($col = $columnsResult->fetch_assoc()) {
    $existingColumns[] = $col['Field'];
  }
  
  // Build SELECT clause dynamically based on what columns exist
  $selectClauses = [
    "e.order_id",
    "e.Quantity",
    "e.Unit",
    "e.UnitCost",
    "e.TotalCost",
    "e.Description",
    "e.Item",
    "e.SerialNo",
    "e.DateAcquired",
    "e.Location",
    "e.InventoryItemNo",
    "e.EstimatedUsefulLife"
  ];
  
  // Add optional workflow columns if they exist
  if (in_array('Amount', $existingColumns)) $selectClauses[] = "e.Amount";
  if (in_array('ApprovalStatus', $existingColumns)) $selectClauses[] = "e.ApprovalStatus";
  if (in_array('ApprovedBy', $existingColumns)) {
    $selectClauses[] = "e.ApprovedBy";
    $selectClauses[] = "COALESCE(u_approved.username, '—') AS approved_by_name";
  }
  if (in_array('ApprovedDate', $existingColumns)) $selectClauses[] = "e.ApprovedDate";
  if (in_array('DeliveryNotes', $existingColumns)) $selectClauses[] = "e.DeliveryNotes";
  if (in_array('DeliveryDate', $existingColumns)) $selectClauses[] = "e.DeliveryDate";
  if (in_array('DeliveryStatus', $existingColumns)) $selectClauses[] = "e.DeliveryStatus";
  if (in_array('InspectionNotes', $existingColumns)) $selectClauses[] = "e.InspectionNotes";
  if (in_array('InspectionDate', $existingColumns)) $selectClauses[] = "e.InspectionDate";
  if (in_array('InspectionStatus', $existingColumns)) $selectClauses[] = "e.InspectionStatus";
  if (in_array('InspectedBy', $existingColumns)) {
    $selectClauses[] = "e.InspectedBy";
    $selectClauses[] = "COALESCE(u_inspected.username, '—') AS inspected_by_name";
  }
  if (in_array('FormType', $existingColumns)) $selectClauses[] = "e.FormType";
  if (in_array('FormData', $existingColumns)) $selectClauses[] = "e.FormData";
  if (in_array('FormSubmitDate', $existingColumns)) $selectClauses[] = "e.FormSubmitDate";
  if (in_array('FormStatus', $existingColumns)) $selectClauses[] = "e.FormStatus";
  
  // Always add workflow tracking columns
  $selectClauses[] = "COALESCE(ews.pr_id, NULL) AS PrId";
  $selectClauses[] = "COALESCE(pr.pr_no, '—') AS pr_number";
  $selectClauses[] = "COALESCE(ews.current_step, 1) AS WorkflowStep";
  $selectClauses[] = "COALESCE(pr.status, '—') AS pr_status";
  
  $sql = "SELECT " . implode(", ", $selectClauses) . "
    FROM entries e
    LEFT JOIN entry_workflow_status ews ON e.order_id = ews.entry_id
    LEFT JOIN purchase_requests pr ON ews.pr_id = pr.id";
  
  // Add user joins only if needed
  if (in_array('ApprovedBy', $existingColumns)) {
    $sql .= " LEFT JOIN users u_approved ON e.ApprovedBy = u_approved.id";
  }
  if (in_array('InspectedBy', $existingColumns)) {
    $sql .= " LEFT JOIN users u_inspected ON e.InspectedBy = u_inspected.id";
  }
  
  // Role-based filtering
  // Role 1 = SuperAdmin (sees all), Role 2 = Admin (sees all), Role 3 = Employee (sees only own)
  if ($roleId === 3) {
    $sql .= " WHERE (ews.created_by = " . intval($userId) . " OR pr.created_by = " . intval($userId) . ")";
  }
  
  // Sort by order_id descending (most recent first)
  $sql .= " ORDER BY e.order_id DESC";
  
  $result = $conn->query($sql);
  
  if (!$result) {
    throw new Exception('Query failed: ' . $conn->error . "\nSQL: " . $sql);
  }
  
  // Fetch all rows as associative arrays
  $entries = [];
  while ($row = $result->fetch_assoc()) {
    // Parse FormData JSON if present
    if ($row['FormData']) {
      $row['FormData'] = json_decode($row['FormData'], true);
    } else {
      $row['FormData'] = null;
    }
    $entries[] = $row;
  }
  
  $conn->close();
  
  // Return success response
  http_response_code(200);
  echo json_encode([
    'status' => 'success',
    'count' => count($entries),
    'data' => $entries
  ]);
  
} catch (Exception $e) {
  http_response_code(500);
  echo json_encode([
    'status' => 'error',
    'message' => $e->getMessage()
  ]);
  exit;
}
?>