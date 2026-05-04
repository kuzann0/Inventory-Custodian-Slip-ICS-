<?php
/**
 * get_all_users.php
 * 
 * Returns list of all users with their roles
 * Used by CapabilityManager (SuperAdmin only)
 * 
 * Security: Returns all users with role information
 */

// Enable CORS - Allow from any origin with credentials
$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

session_start();

// Database connection
$servername = getenv('MYSQL_HOST') ?? 'db';
$dbuser = getenv('MYSQL_USER') ?? 'root';
$dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
$dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

$conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Database connection failed'
    ]);
    exit;
}

try {
    // Query all users with role information
    $query = "
        SELECT 
            u.id,
            u.username,
            u.email,
            u.role_id,
            CASE 
                WHEN u.role_id = 1 THEN 'SuperAdmin'
                WHEN u.role_id = 2 THEN 'Admin'
                WHEN u.role_id = 3 THEN 'Employee'
                ELSE 'Unknown'
            END AS role_name
        FROM users u
        ORDER BY u.role_id ASC, u.username ASC
    ";
    
    $result = $conn->query($query);
    
    if (!$result) {
        http_response_code(500);
        echo json_encode([
            'success' => false,
            'error' => 'Database query failed: ' . $conn->error
        ]);
        exit;
    }

    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = [
            'id' => (int)$row['id'],
            'username' => $row['username'],
            'email' => $row['email'],
            'role_id' => (int)$row['role_id'],
            'role_name' => $row['role_name']
        ];
    }

    echo json_encode([
        'success' => true,
        'users' => $users,
        'count' => count($users)
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Server error: ' . $e->getMessage()
    ]);
} finally {
    $conn->close();
}
?>
