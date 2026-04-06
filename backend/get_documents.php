<?php
/**
 * Get documents list
 */

header('Content-Type: application/json; charset=UTF-8');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $query = "
        SELECT 
            id,
            pr_no,
            document_type,
            uploaded_by,
            upload_date,
            verified
        FROM documents
        ORDER BY upload_date DESC
        LIMIT 100
    ";

    $result = $conn->query($query);
    
    if (!$result) {
        // Table doesn't exist yet, return empty
        echo json_encode([
            'success' => true,
            'documents' => [],
            'count' => 0
        ]);
        exit;
    }

    $documents = [];
    while ($row = $result->fetch_assoc()) {
        $documents[] = $row;
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'documents' => $documents,
        'count' => count($documents)
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
