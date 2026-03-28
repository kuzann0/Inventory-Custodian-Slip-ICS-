<?php
/**
 * Get User Capabilities Endpoint
 * Returns all capabilities for a specific user
 * 
 * File: backend/get_user_capabilities.php
 */

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(json_encode(['ok' => true]));
}

$servername = getenv('MYSQL_HOST') ?? 'db';
$dbuser = getenv('MYSQL_USER') ?? 'root';
$dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
$dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

$conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

if ($conn->connect_error) {
    http_response_code(500);
    exit(json_encode(['success' => false, 'error' => 'Database connection failed']));
}

try {
    // Get user_id from query parameter
    $userId = intval($_GET['user_id'] ?? 0);
    
    if (!$userId) {
        throw new Exception('Missing user_id parameter');
    }
    
    // Verify user exists
    $verifyStmt = $conn->prepare("SELECT id, username, role_id FROM users WHERE id = ?");
    $verifyStmt->bind_param('i', $userId);
    $verifyStmt->execute();
    $userResult = $verifyStmt->get_result();
    
    if ($userResult->num_rows === 0) {
        throw new Exception('User not found');
    }
    
    $userData = $userResult->fetch_assoc();
    $verifyStmt->close();
    
    // Get user's capabilities
    $stmt = $conn->prepare(
        "SELECT c.id, c.capability_key, c.category, c.description, c.required_role_id,
                uc.granted_by_id, uc.granted_at, uc.expires_at,
                u_granted.username as granted_by_username
         FROM user_capabilities uc
         JOIN capabilities c ON uc.capability_id = c.id
         LEFT JOIN users u_granted ON uc.granted_by_id = u_granted.id
         WHERE uc.user_id = ?
         ORDER BY c.category, c.capability_key"
    );
    $stmt->bind_param('i', $userId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $capabilities = [];
    while ($cap = $result->fetch_assoc()) {
        $capabilities[] = [
            'id' => intval($cap['id']),
            'capability_key' => $cap['capability_key'],
            'category' => $cap['category'],
            'description' => $cap['description'],
            'required_role_id' => $cap['required_role_id'],
            'granted_by_username' => $cap['granted_by_username'] ?? 'system',
            'granted_at' => $cap['granted_at'],
            'expires_at' => $cap['expires_at']
        ];
    }
    $stmt->close();
    
    // Group by category
    $groupedCapabilities = [];
    foreach ($capabilities as $cap) {
        if (!isset($groupedCapabilities[$cap['category']])) {
            $groupedCapabilities[$cap['category']] = [];
        }
        $groupedCapabilities[$cap['category']][] = $cap;
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'user' => [
            'id' => intval($userData['id']),
            'username' => $userData['username'],
            'role_id' => intval($userData['role_id'])
        ],
        'capabilities' => $capabilities,
        'grouped_by_category' => $groupedCapabilities,
        'total' => count($capabilities)
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}

$conn->close();
?>
