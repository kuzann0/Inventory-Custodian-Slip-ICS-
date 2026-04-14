<?php
/**
 * Get PR details from purchase_requests table
 * Accepts either pr_no or id parameter
 */

header('Content-Type: application/json; charset=UTF-8');

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

    // Accept either pr_no or id parameter
    $pr_no = $_GET['pr_no'] ?? null;
    $pr_id = $_GET['id'] ?? null;

    if (!$pr_no && !$pr_id) {
        throw new Exception('PR number or ID required');
    }

    if ($pr_id) {
        // Query by ID
        $stmt = $conn->prepare("
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
                created_by
            FROM purchase_requests
            WHERE id = ?
            LIMIT 1
        ");
        
        $stmt->bind_param('i', $pr_id);
    } else {
        // Query by PR number
        $stmt = $conn->prepare("
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
                created_by
            FROM purchase_requests
            WHERE pr_no = ?
            LIMIT 1
        ");
        
        $stmt->bind_param('s', $pr_no);
    }
    
    if (!$stmt->execute()) {
        throw new Exception('Query failed: ' . $stmt->error);
    }

    $result = $stmt->get_result();
    $pr_data = $result->fetch_assoc();

    if (!$pr_data) {
        throw new Exception('Purchase Request not found');
    }

    // Get workflow history
    $history_stmt = $conn->prepare("
        SELECT id, pr_id, status_to, action_type, notes, action_date, action_by
        FROM workflow_history
        WHERE pr_id = ?
        ORDER BY action_date DESC
    ");
    $history_stmt->bind_param('i', $pr_data['id']);
    $history_stmt->execute();
    $history_result = $history_stmt->get_result();
    
    $workflow_history = [];
    while ($row = $history_result->fetch_assoc()) {
        $workflow_history[] = $row;
    }
    $history_stmt->close();

    // Get inspection data
    $inspection_stmt = $conn->prepare("
        SELECT id, assigned_to, status, inspection_notes, condition_report, completed_date
        FROM inspection_assignments
        WHERE pr_id = ?
    ");
    $inspection_stmt->bind_param('i', $pr_data['id']);
    $inspection_stmt->execute();
    $inspection_result = $inspection_stmt->get_result();
    
    $inspection_data = [];
    while ($row = $inspection_result->fetch_assoc()) {
        $inspection_data[] = $row;
    }
    $inspection_stmt->close();

    http_response_code(200);
    
    // Prepare response - include data at root level for backward compatibility
    $response = [
        'success' => true,
        'data' => $pr_data,
        'workflow_history' => $workflow_history,
        'inspection' => $inspection_data
    ];
    
    // Also add fields at root level for backward compatibility with frontend
    foreach ($pr_data as $key => $value) {
        $response[$key] = $value;
    }
    
    // Add alternate field names for compatibility
    $response['description'] = $response['description'] ?? '';
    $response['unit'] = $response['unit'] ?? '';
    $response['date_acquired'] = $response['created_at'] ?? '';
    $response['total_cost'] = $response['total_amount'] ?? 0;
    $response['supplier_name'] = $response['office'] ?? '';
    $response['item_description'] = $response['item_name'] ?? '';
    
    echo json_encode($response);

    $stmt->close();
    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
