<?php
/**
 * Get PR details
 */

header('Content-Type: application/json; charset=UTF-8');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $pr_no = $_GET['pr_no'] ?? '';

    if (!$pr_no) {
        throw new Exception('PR number required');
    }

    $stmt = $conn->prepare("
        SELECT 
            pr_no,
            description,
            unit,
            date_acquired,
            total_cost,
            quantity,
            office,
            division_section
        FROM entries
        WHERE SerialNo = ?
        LIMIT 1
    ");

    $stmt->bind_param('s', $pr_no);
    
    if (!$stmt->execute()) {
        throw new Exception('Query failed');
    }

    $result = $stmt->get_result();
    $pr_data = $result->fetch_assoc();

    if (!$pr_data) {
        // Return default structure
        $pr_data = [
            'pr_no' => $pr_no,
            'description' => '',
            'unit' => '',
            'date_acquired' => date('Y-m-d'),
            'total_cost' => 0,
            'quantity' => 0
        ];
    }

    echo json_encode([
        'success' => true,
        ...($pr_data ?? [])
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
