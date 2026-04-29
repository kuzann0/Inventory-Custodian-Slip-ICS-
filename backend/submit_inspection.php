<?php
/**
 * Submit inspection notes - Updated for workflow_history tracking
 */

// CORS Configuration
require_once 'config/cors.php';

header('Content-Type: application/json; charset=UTF-8');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

session_start();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    // Get user ID from multiple sources
    $user_id = null;
    
    // Priority 1: Request body
    if (isset($data['user_id']) && !empty($data['user_id'])) {
        $user_id = (int)$data['user_id'];
    }
    
    // Priority 2: Session
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
    
    $conn = new mysqli(
        getenv('MYSQL_HOST') ?: 'db',
        getenv('MYSQL_USER') ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $assignment_id = $data['assignment_id'] ?? 0;
    $pr_id = $data['pr_id'] ?? 0;
    $inspection_notes = $data['inspection_notes'] ?? '';
    $condition_report = $data['condition_report'] ?? '';

    if (!$pr_id || !$inspection_notes) {
        throw new Exception('Missing required fields: pr_id and inspection_notes are required');
    }

    // Check if inspection_assignments record exists for this PR
    $stmt = $conn->prepare("SELECT id FROM inspection_assignments WHERE pr_id = ?");
    $stmt->bind_param('i', $pr_id);
    $stmt->execute();
    $result = $stmt->get_result();
    $assignment_exists = $result->num_rows > 0;
    $stmt->close();

    if ($assignment_exists) {
        // Update existing inspection_assignments record
        $stmt = $conn->prepare("UPDATE inspection_assignments SET status = 'completed', inspection_notes = ?, condition_report = ?, completed_date = NOW() WHERE pr_id = ?");
        $stmt->bind_param('ssi', $inspection_notes, $condition_report, $pr_id);

        if (!$stmt->execute()) {
            throw new Exception('Failed to update assignment: ' . $stmt->error);
        }
        $stmt->close();
    } else {
        // Create new inspection_assignments record
        $stmt = $conn->prepare("INSERT INTO inspection_assignments (pr_id, assigned_to, status, inspection_notes, condition_report, completed_date) VALUES (?, ?, 'completed', ?, ?, NOW())");
        $stmt->bind_param('iiss', $pr_id, $user_id, $inspection_notes, $condition_report);

        if (!$stmt->execute()) {
            throw new Exception('Failed to create assignment: ' . $stmt->error);
        }
        $stmt->close();
    }

    // Update purchase_requests table
    $stmt = $conn->prepare("UPDATE purchase_requests SET status = 'inspected', inspection_notes = ?, inspection_date = NOW(), inspected_by = ? WHERE id = ?");
    $stmt->bind_param('sii', $inspection_notes, $user_id, $pr_id);
    $stmt->execute();
    $stmt->close();

    // Log to workflow_history
    if ($user_id) {
        $stmt = $conn->prepare("INSERT INTO workflow_history (pr_id, status_from, status_to, action_by, action_type, notes) VALUES (?, 'in_delivery', 'inspected', ?, 'inspection_completed', ?)");
        $stmt->bind_param('iis', $pr_id, $user_id, $inspection_notes);
        $stmt->execute();
        $stmt->close();
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Inspection submitted successfully'
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
