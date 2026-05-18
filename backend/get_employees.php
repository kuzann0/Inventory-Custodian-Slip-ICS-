<?php
/**
 * get_employees.php
 * 
 * Returns list of all employees with basic information
 * Used by AdminCapabilityEditor to show employee list
 * 
 * Security: Only returns role_id=3 (Employees)
 */

// Enable CORS - Allow from any origin with credentials
$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
header('Access-Control-Allow-Credentials: true');
header('Content-Type: application/json');

// Handle preflight requests
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
    // Query all employees
    $query = "
        SELECT 
            id,
            username,
            email,
            role_id
        FROM users
        WHERE role_id = 3
        ORDER BY username ASC
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

    $employees = [];
    while ($row = $result->fetch_assoc()) {
        $employees[] = [
            'id' => (int)$row['id'],
            'username' => $row['username'],
            'email' => $row['email'],
            'role_id' => (int)$row['role_id']
        ];
    }

    echo json_encode([
        'success' => true,
        'employees' => $employees,
        'count' => count($employees)
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
