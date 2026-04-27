<?php
// CORS Configuration
require_once 'config/cors.php';

header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

session_start();

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Invalid request method');
    }

    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get POST data first (can only read php://input once)
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if (!$data) {
        throw new Exception('Invalid JSON input. Raw input: ' . substr($input, 0, 100), 400);
    }

    // Get user ID from multiple sources
    $user_id = null;
    
    // Priority 1: Request body (frontend sends this)
    if (isset($data['user_id']) && !empty($data['user_id'])) {
        $user_id = (int)$data['user_id'];
    }
    
    // Priority 2: Session (if PHP session is working)
    if (!$user_id && isset($_SESSION['user_id'])) {
        $user_id = (int)$_SESSION['user_id'];
    }
    
    // Priority 3: Request header
    if (!$user_id && isset($_SERVER['HTTP_X_USER_ID'])) {
        $user_id = (int)$_SERVER['HTTP_X_USER_ID'];
    }
    
    // Priority 4: Default to user 1 for testing (REMOVE IN PRODUCTION)
    if (!$user_id || $user_id <= 0) {
        $user_id = 1; // Default test user
    }

    // Note: $data is already decoded from php://input above (line 34)
    // Do NOT read php://input again - it can only be read once!

    // Validate required fields
    $required_fields = ['pr_no', 'item_name', 'quantity', 'unit', 'unit_cost', 'office', 'division_section'];
    foreach ($required_fields as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }

    // Calculate total amount
    $total_amount = (float)$data['quantity'] * (float)$data['unit_cost'];

    // Determine form type based on amount threshold (50,000)
    $form_type = $total_amount >= 50000 ? 'ppe' : 'ics';

    // Check if PR already exists
    $check_sql = "SELECT id FROM purchase_requests WHERE pr_no = ?";
    $stmt = $conn->prepare($check_sql);
    $stmt->bind_param('s', $data['pr_no']);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        throw new Exception('PR Number already exists');
    }
    $stmt->close();

    // Insert into purchase_requests table
    $insert_sql = "
        INSERT INTO purchase_requests (
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
            created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'draft', ?, ?)
    ";

    $stmt = $conn->prepare($insert_sql);
    if (!$stmt) {
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $description = $data['description'] ?? '';
    $stmt->bind_param(
        'ssissdssssi',
        $data['pr_no'],
        $data['item_name'],
        $description,
        $data['quantity'],
        $data['unit'],
        $data['unit_cost'],
        $total_amount,
        $data['office'],
        $data['division_section'],
        $form_type,
        $user_id
    );

    if (!$stmt->execute()) {
        throw new Exception('Failed to create PR: ' . $stmt->error);
    }

    $pr_id = $stmt->insert_id;
    $stmt->close();

    // Create corresponding entry in entries table (single source of truth)
    $entry_sql = "
        INSERT INTO entries (
            Quantity,
            Unit,
            UnitCost,
            TotalCost,
            Description,
            Item,
            Location,
            SerialNo,
            InventoryItemNo,
            EstimatedUsefulLife,
            DateAcquired
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ";

    $entry_stmt = $conn->prepare($entry_sql);
    if (!$entry_stmt) {
        throw new Exception('Failed to prepare entry insert: ' . $conn->error);
    }

    $serial_no = $data['serial_no'] ?? null;
    $inventory_item_no = $data['inventory_item_no'] ?? null;
    $estimated_useful_life = $data['estimated_useful_life'] ?? null;

    $entry_stmt->bind_param(
        'isddssssss',
        $data['quantity'],
        $data['unit'],
        $data['unit_cost'],
        $total_amount,
        $description,
        $data['item_name'],
        $data['office'],
        $serial_no,
        $inventory_item_no,
        $estimated_useful_life
    );

    if (!$entry_stmt->execute()) {
        throw new Exception('Failed to create entry: ' . $entry_stmt->error);
    }

    $entry_id = $entry_stmt->insert_id;
    $entry_stmt->close();

    // Create entry_workflow_status record to link entry to PR
    $workflow_status_sql = "
        INSERT INTO entry_workflow_status (
            entry_id,
            pr_id,
            pr_no,
            current_step,
            step_1_completed,
            step_1_data
        ) VALUES (?, ?, ?, 1, 1, ?)
    ";

    $workflow_stmt = $conn->prepare($workflow_status_sql);
    if (!$workflow_stmt) {
        throw new Exception('Failed to prepare workflow status insert: ' . $conn->error);
    }

    $step_1_data = json_encode([
        'item_name' => $data['item_name'],
        'quantity' => $data['quantity'],
        'unit' => $data['unit'],
        'unit_cost' => $data['unit_cost']
    ]);

    $workflow_stmt->bind_param(
        'iiss',
        $entry_id,
        $pr_id,
        $data['pr_no'],
        $step_1_data
    );

    if (!$workflow_stmt->execute()) {
        throw new Exception('Failed to create workflow status: ' . $workflow_stmt->error);
    }

    $workflow_stmt->close();

    // Log to workflow_history
    $history_sql = "
        INSERT INTO workflow_history (
            pr_id, 
            status_to, 
            action_by, 
            action_type, 
            notes
        ) VALUES (?, 'draft', ?, 'created', 'Purchase Request created')
    ";

    $stmt = $conn->prepare($history_sql);
    $stmt->bind_param('ii', $pr_id, $user_id);
    $stmt->execute();
    $stmt->close();

    http_response_code(201);
    echo json_encode([
        'success' => true,
        'message' => 'Purchase Request submitted successfully',
        'pr_id' => $pr_id,
        'pr_no' => $data['pr_no'],
        'total_amount' => $total_amount,
        'form_type' => $form_type,
        'status' => 'draft'
    ]);

    $conn->close();

} catch (Exception $e) {
    $error_code = $e->getCode() ?: 500;
    http_response_code($error_code);
    
    $error_response = [
        'success' => false,
        'error' => $e->getMessage(),
        'debug' => [
            'user_id_session' => isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null,
            'user_id_body' => isset($data['user_id']) ? $data['user_id'] : null,
            'user_id_header' => isset($_SERVER['HTTP_X_USER_ID']) ? $_SERVER['HTTP_X_USER_ID'] : null,
            'data_keys' => isset($data) ? array_keys($data) : [],
            'headers' => array_filter($_SERVER, function($k) { return strpos($k, 'HTTP_') === 0; }, ARRAY_FILTER_USE_KEY)
        ]
    ];
    
    echo json_encode($error_response);
}
?>
