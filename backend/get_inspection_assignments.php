<?php
/**
 * Get inspection assignments list
 */

session_start();

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get pending assignments
    $query = "
        SELECT 
            pr_no,
            item_name,
            quantity,
            unit_cost,
            assigned_to,
            status,
            created_at
        FROM purchase_requests
        WHERE status IN ('pending_inspection', 'assigned')
        ORDER BY created_at DESC
        LIMIT 50
    ";

    $result = $conn->query($query);
    
    if (!$result) {
        throw new Exception('Query failed: ' . $conn->error);
    }

    $assignments = [];
    while ($row = $result->fetch_assoc()) {
        $assignments[] = $row;
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'assignments' => $assignments,
        'count' => count($assignments)
    ]);

    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
