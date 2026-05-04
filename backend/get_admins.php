<?php
/**
 * Get All Admin Accounts Endpoint
 * 
 * Returns list of all admin accounts (SuperAdmin only)
 * GET /get_admins.php
 */

session_start();

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    // Database connection
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Get all admin accounts
    $query = "
        SELECT 
            aa.id,
            aa.admin_user_id,
            aa.username,
            aa.email,
            aa.permissions,
            aa.is_active,
            aa.last_login,
            aa.created_at,
            aa.updated_at,
            u.account_status,
            ur.role_name
        FROM admin_accounts aa
        JOIN users u ON aa.admin_user_id = u.id
        JOIN user_roles ur ON u.role_id = ur.id
        ORDER BY aa.created_at DESC
    ";

    $result = $conn->query($query);

    if (!$result) {
        throw new Exception('Query failed: ' . $conn->error);
    }

    $admins = [];
    while ($row = $result->fetch_assoc()) {
        $row['permissions'] = json_decode($row['permissions'], true) ?? [];
        $admins[] = $row;
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Admins retrieved successfully',
        'total' => count($admins),
        'admins' => $admins
    ]);

    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
