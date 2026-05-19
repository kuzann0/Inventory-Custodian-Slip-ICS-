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
    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get pending assignments from inspection_assignments table
    $query = "
        SELECT 
            ia.id as assignment_id,
            ia.pr_id,
            ia.assigned_to,
            ia.status,
            ia.inspection_notes,
            ia.condition_report,
            ia.assigned_date,
            ia.completed_date,
            pr.pr_no,
            pr.item_name,
            pr.quantity,
            pr.unit_cost,
            u.username as assigned_to_name,
            u.email as assigned_to_email
        FROM inspection_assignments ia
        JOIN purchase_requests pr ON ia.pr_id = pr.id
        LEFT JOIN users u ON ia.assigned_to = u.id
        WHERE ia.status IN ('pending', 'in_progress')
        ORDER BY ia.assigned_date DESC
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
