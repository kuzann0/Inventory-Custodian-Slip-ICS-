<?php
/**
 * Get process status
 */

header('Content-Type: application/json; charset=UTF-8');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $status = $_GET['status'] ?? null;
    
    $query = "
        SELECT 
            id,
            pr_no,
            description,
            status,
            total_amount,
            item_count,
            notes,
            created_at,
            updated_at
        FROM purchase_requests
    ";

    if ($status) {
        $query .= " WHERE status = ?";
    }

    $query .= " ORDER BY created_at DESC LIMIT 50";

    $stmt = $conn->prepare($query);
    
    if ($status) {
        $stmt->bind_param('s', $status);
    }
    
    if (!$stmt->execute()) {
        throw new Exception('Query failed');
    }

    $result = $stmt->get_result();
    
    $processes = [];
    while ($row = $result->fetch_assoc()) {
        $processes[] = $row;
    }

    echo json_encode([
        'success' => true,
        'processes' => $processes,
        'count' => count($processes)
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
