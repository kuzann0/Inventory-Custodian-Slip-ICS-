<?php
/**
 * Get process summary
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
            SerialNo as pr_no,
            TotalCost as total_amount,
            Description as description,
            CASE 
                WHEN TotalCost >= 50000 THEN 'ABOVE PAR (PPE)'
                ELSE 'LESS: ICS'
            END as category,
            Item as item_name
        FROM entries
        WHERE SerialNo = ?
        LIMIT 1
    ");

    $stmt->bind_param('s', $pr_no);
    
    if (!$stmt->execute()) {
        throw new Exception('Query failed');
    }

    $result = $stmt->get_result();
    $summary = $result->fetch_assoc();

    if (!$summary) {
        $summary = [
            'pr_no' => $pr_no,
            'total_amount' => 0,
            'category' => 'UNKNOWN',
            'description' => ''
        ];
    }

    echo json_encode([
        'success' => true,
        ...($summary ?? [])
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
