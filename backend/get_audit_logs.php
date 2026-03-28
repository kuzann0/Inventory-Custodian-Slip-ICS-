<?php
/**
 * Get Audit Logs Endpoint
 * 
 * Only SuperAdmin can view audit logs
 * Returns all capability_audit_log entries with actor and target usernames
 * 
 * GET /get_audit_logs.php?actor_id=1&limit=50&offset=0
 */

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['ok' => true]));
}

try {
    // Get parameters
    $actorId = intval($_GET['actor_id'] ?? $_POST['actor_id'] ?? 0);
    $limit = intval($_GET['limit'] ?? $_POST['limit'] ?? 50);
    $offset = intval($_GET['offset'] ?? $_POST['offset'] ?? 0);
    
    // Validate limit range
    if ($limit < 1 || $limit > 500) {
        $limit = 50;
    }
    
    if ($offset < 0) {
        $offset = 0;
    }
    
    // Database connection
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';
    
    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);
    
    if ($conn->connect_error) {
        http_response_code(500);
        exit(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
    }
    
    // Validate actor is SuperAdmin
    $actorStmt = $conn->prepare("SELECT role_id FROM users WHERE id = ?");
    $actorStmt->bind_param('i', $actorId);
    $actorStmt->execute();
    $actorResult = $actorStmt->get_result();
    
    if ($actorResult->num_rows === 0) {
        http_response_code(403);
        exit(json_encode(['status' => 'error', 'message' => 'Actor not found']));
    }
    
    $actor = $actorResult->fetch_assoc();
    $actorStmt->close();
    
    if ($actor['role_id'] !== 1) {
        http_response_code(403);
        exit(json_encode(['status' => 'error', 'message' => 'Only SuperAdmin can view audit logs']));
    }
    
    // Get total count first
    $countQuery = "SELECT COUNT(*) as total FROM capability_audit_log";
    $countResult = $conn->query($countQuery);
    $countRow = $countResult->fetch_assoc();
    $totalCount = intval($countRow['total']);
    
    // Get audit logs with user details
    $query = "
        SELECT 
            cal.id,
            cal.actor_id,
            COALESCE(actor.username, 'System') as actor_username,
            actor.email as actor_email,
            cal.target_id,
            COALESCE(target.username, 'Deleted User') as target_username,
            target.email as target_email,
            cal.action,
            cal.capability_id,
            COALESCE(cap.name, 'N/A') as capability_name,
            cal.ip_address,
            cal.created_at
        FROM capability_audit_log cal
        LEFT JOIN users actor ON cal.actor_id = actor.id
        LEFT JOIN users target ON cal.target_id = target.id
        LEFT JOIN capabilities cap ON cal.capability_id = cap.id
        ORDER BY cal.created_at DESC
        LIMIT ? OFFSET ?
    ";
    
    $stmt = $conn->prepare($query);
    
    if (!$stmt) {
        http_response_code(500);
        exit(json_encode(['status' => 'error', 'message' => 'Query preparation failed']));
    }
    
    $stmt->bind_param('ii', $limit, $offset);
    
    if (!$stmt->execute()) {
        http_response_code(500);
        exit(json_encode(['status' => 'error', 'message' => 'Query execution failed']));
    }
    
    $result = $stmt->get_result();
    $logs = [];
    
    while ($row = $result->fetch_assoc()) {
        // Format the log entry
        $logs[] = [
            'id' => intval($row['id']),
            'actor_id' => intval($row['actor_id']),
            'actor_username' => $row['actor_username'],
            'actor_email' => $row['actor_email'],
            'target_id' => intval($row['target_id']),
            'target_username' => $row['target_username'],
            'target_email' => $row['target_email'],
            'action' => $row['action'],
            'capability_id' => intval($row['capability_id']) ?: null,
            'capability_name' => $row['capability_name'],
            'ip_address' => $row['ip_address'],
            'timestamp' => $row['created_at']
        ];
    }
    
    $stmt->close();
    
    http_response_code(200);
    echo json_encode([
        'status' => 'success',
        'total' => $totalCount,
        'limit' => $limit,
        'offset' => $offset,
        'count' => count($logs),
        'logs' => $logs
    ]);
    
    $conn->close();
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Server error: ' . $e->getMessage()]);
}
?>
