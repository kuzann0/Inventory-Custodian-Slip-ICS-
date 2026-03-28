<?php
/**
 * Delete Admin Account Endpoint
 * 
 * Only SuperAdmin can delete admin accounts
 * DELETE /delete_admin.php
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Get input
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    $adminId = $input['admin_id'] ?? null;

    if (empty($adminId)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Admin ID is required']);
        exit;
    }

    // Database connection
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Verify SuperAdmin exists
    $superAdminCheck = "SELECT id FROM users WHERE is_superadmin = TRUE AND account_status = 'active' LIMIT 1";
    $result = $conn->query($superAdminCheck);

    if ($result->num_rows === 0) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'No active SuperAdmin found']);
        $conn->close();
        exit;
    }

    $superAdmin = $result->fetch_assoc();
    $superAdminId = $superAdmin['id'];

    // Verify admin exists
    $checkAdmin = $conn->prepare("SELECT admin_user_id, username FROM admin_accounts WHERE id = ?");
    $checkAdmin->bind_param("i", $adminId);
    $checkAdmin->execute();
    $adminResult = $checkAdmin->get_result();

    if ($adminResult->num_rows === 0) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Admin account not found']);
        $conn->close();
        exit;
    }

    $admin = $adminResult->fetch_assoc();
    $adminUserId = $admin['admin_user_id'];
    $adminUsername = $admin['username'];

    // Start transaction
    $conn->begin_transaction();

    try {
        // Delete admin account record
        $deleteAdmin = $conn->prepare("DELETE FROM admin_accounts WHERE id = ?");
        $deleteAdmin->bind_param("i", $adminId);
        $deleteAdmin->execute();

        // Delete user record
        $deleteUser = $conn->prepare("DELETE FROM users WHERE id = ?");
        $deleteUser->bind_param("i", $adminUserId);
        $deleteUser->execute();

        // Log action
        $action = 'DELETE_ADMIN';
        $actionDetails = json_encode(['deleted_username' => $adminUsername]);
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';

        $logAudit = $conn->prepare("
            INSERT INTO audit_logs (admin_id, action, action_details, ip_address, user_agent) 
            VALUES (?, ?, ?, ?, ?)
        ");
        $logAudit->bind_param("issss", $superAdminId, $action, $actionDetails, $ipAddress, $userAgent);
        $logAudit->execute();

        $conn->commit();

        http_response_code(200);
        echo json_encode([
            'success' => true,
            'message' => 'Admin account deleted successfully',
            'deleted_username' => $adminUsername
        ]);

    } catch (Exception $e) {
        $conn->rollback();
        throw $e;
    }

    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
