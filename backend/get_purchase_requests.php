<?php
header('Content-Type: application/json');
session_start();

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get optional filters
    $status = isset($_GET['status']) ? $_GET['status'] : null;
    $office = isset($_GET['office']) ? $_GET['office'] : null;
    $user_id = isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null;

    $sql = "
        SELECT 
            id,
            pr_no,
            item_name,
            description,
            quantity,
            unit,
            unit_cost,
            total_amount,
            office,
            division_section,
            status,
            form_type,
            approval_date,
            delivery_notes,
            inspection_notes,
            created_at,
            updated_at,
            (SELECT COUNT(*) FROM documents WHERE pr_id = purchase_requests.id) as document_count,
            (SELECT COUNT(*) FROM inspection_assignments WHERE pr_id = purchase_requests.id) as inspection_count
        FROM purchase_requests
        WHERE 1=1
    ";

    $params = [];
    $types = '';

    if ($status) {
        $sql .= " AND status = ?";
        $params[] = $status;
        $types .= 's';
    }

    if ($office) {
        $sql .= " AND office = ?";
        $params[] = $office;
        $types .= 's';
    }

    // Get user's office if not superadmin
    $sql .= " ORDER BY created_at DESC LIMIT 100";

    $stmt = $conn->prepare($sql);
    
    if (!empty($params)) {
        $stmt->bind_param($types, ...$params);
    }

    $stmt->execute();
    $result = $stmt->get_result();

    $purchase_requests = [];
    while ($row = $result->fetch_assoc()) {
        $purchase_requests[] = $row;
    }

    $stmt->close();

    // Calculate summary stats
    $stats = [
        'total' => count($purchase_requests),
        'by_status' => [],
        'by_form_type' => [],
        'total_amount' => 0
    ];

    foreach ($purchase_requests as $pr) {
        $stats['total_amount'] += (float)$pr['total_amount'];
        
        $s = $pr['status'];
        $stats['by_status'][$s] = ($stats['by_status'][$s] ?? 0) + 1;
        
        $f = $pr['form_type'];
        $stats['by_form_type'][$f] = ($stats['by_form_type'][$f] ?? 0) + 1;
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $purchase_requests,
        'stats' => $stats,
        'count' => count($purchase_requests)
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
