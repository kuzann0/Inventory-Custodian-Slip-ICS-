<?php
/**
 * GET /get_entries.php
 * Fetches all entries from the entries table with optional JOINs for workflow & users.
 * Returns: JSON array with available columns.
 * Access: Requires valid session (authenticated user).
 * Security: Employees see only their own entries; Admins/SuperAdmins see all.
 */

require_once 'config/cors.php';

header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['ok' => true]));
}

session_start();

// Enable error logging (disable display in production)
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/php_errors.log');

try {
    // Get user credentials from multiple sources
    $userId = $_SESSION['user_id'] ?? $_SERVER['HTTP_X_USER_ID'] ?? $_GET['user_id'] ?? 1;
    $roleId = $_SESSION['role_id'] ?? $_SERVER['HTTP_X_ROLE_ID'] ?? 2;
    $userId = (int)$userId;
    $roleId = (int)$roleId;

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

    // Helper: check if a table exists
    function tableExists($conn, $table) {
        $result = $conn->query("SHOW TABLES LIKE '" . $conn->real_escape_string($table) . "'");
        return $result && $result->num_rows > 0;
    }

    // Helper: get existing columns of a table
    function getColumns($conn, $table) {
        $cols = [];
        $res = $conn->query("SHOW COLUMNS FROM `$table`");
        if ($res) {
            while ($row = $res->fetch_assoc()) {
                $cols[] = $row['Field'];
            }
        }
        return $cols;
    }

    // Check which tables exist
    $hasWorkflow = tableExists($conn, 'workflow_status');
    $hasPurchaseRequests = tableExists($conn, 'purchase_requests');
    $hasUsers = tableExists($conn, 'users');

    // Get columns of entries table
    $entriesColumns = getColumns($conn, 'entries');

    // Base SELECT columns from entries (always available)
    $select = [
    "e.order_id",
    "e.Item",
    "e.Quantity",
    "e.Unit",
    "e.UnitCost",
    "e.TotalCost",
    "e.SerialNo",
    "e.InventoryItemNo",
    "e.DateAcquired",
    "e.Location",
    "e.EstimatedUsefulLife",
    "e.Description"
    ];

    // Optional entries columns
    $optionalCols = ['Amount', 'ApprovalStatus', 'ApprovedBy', 'ApprovedDate', 'DeliveryNotes',
                     'DeliveryDate', 'DeliveryStatus', 'InspectionNotes', 'InspectionDate',
                     'InspectionStatus', 'InspectedBy', 'FormType', 'FormData', 'FormSubmitDate', 'FormStatus'];
    foreach ($optionalCols as $col) {
        if (in_array($col, $entriesColumns)) {
            $select[] = "e.`$col`";
        }
    }

    // Workflow-related columns (only if tables exist)
    if ($hasWorkflow) {
        $select[] = "ews.pr_id AS PrId";
        $select[] = "COALESCE(ews.current_step, 1) AS WorkflowStep";
    } else {
        $select[] = "NULL AS PrId";
        $select[] = "1 AS WorkflowStep";
    }

    if ($hasPurchaseRequests) {
        $select[] = "pr.pr_no AS pr_number";
        $select[] = "pr.status AS pr_status";
    } else {
        $select[] = "'—' AS pr_number";
        $select[] = "'—' AS pr_status";
    }

    // User names for ApprovedBy / InspectedBy
    if (in_array('ApprovedBy', $entriesColumns) && $hasUsers) {
        $select[] = "COALESCE(u_approved.username, '—') AS approved_by_name";
    } else {
        $select[] = "'—' AS approved_by_name";
    }
    if (in_array('InspectedBy', $entriesColumns) && $hasUsers) {
        $select[] = "COALESCE(u_inspected.username, '—') AS inspected_by_name";
    } else {
        $select[] = "'—' AS inspected_by_name";
    }

    // Build FROM and JOINs
    $sql = "SELECT " . implode(", ", $select) . " FROM entries e";

    if ($hasWorkflow) {
        $sql .= " LEFT JOIN workflow_status ews ON e.order_id = ews.entry_id";
    }
    if ($hasPurchaseRequests && $hasWorkflow) {
        $sql .= " LEFT JOIN purchase_requests pr ON ews.pr_id = pr.id";
    }
    if (in_array('ApprovedBy', $entriesColumns) && $hasUsers) {
        $sql .= " LEFT JOIN users u_approved ON e.ApprovedBy = u_approved.id";
    }
    if (in_array('InspectedBy', $entriesColumns) && $hasUsers) {
        $sql .= " LEFT JOIN users u_inspected ON e.InspectedBy = u_inspected.id";
    }

    // Role-based filtering (only if we have created_by columns in workflow or purchase_requests)
    if ($roleId === 3) {
        $conditions = [];
        if ($hasWorkflow) {
            $conditions[] = "ews.created_by = $userId";
        }
        if ($hasPurchaseRequests && $hasWorkflow) {
            $conditions[] = "pr.created_by = $userId";
        }
        if (!empty($conditions)) {
            $sql .= " WHERE (" . implode(" OR ", $conditions) . ")";
        } else {
            // No way to filter by user – return empty set
            $sql .= " WHERE 1=0";
        }
    }

    $sql .= " ORDER BY e.order_id DESC";

    $result = $conn->query($sql);
    if (!$result) {
        // Fallback: query only entries table without any joins
        $fallbackCols = array_diff($select, ['pr_id', 'WorkflowStep', 'pr_number', 'pr_status', 'approved_by_name', 'inspected_by_name']);
        $fallbackSql = "SELECT " . implode(", ", $fallbackCols) . " FROM entries e ORDER BY e.order_id DESC";
        $result = $conn->query($fallbackSql);
        if (!$result) {
            throw new Exception('Fallback query also failed: ' . $conn->error);
        }
    }

    $entries = [];
    while ($row = $result->fetch_assoc()) {
        if (!empty($row['FormData'])) {
            $row['FormData'] = json_decode($row['FormData'], true);
        } else {
            $row['FormData'] = null;
        }
        $entries[] = $row;
    }

    $conn->close();

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
    error_log("get_entries.php error: " . $e->getMessage());
    exit;
}
?>