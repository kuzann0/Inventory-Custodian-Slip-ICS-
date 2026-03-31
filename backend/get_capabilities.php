<?php
/**
 * Get All Capabilities Endpoint
 * Returns list of all available capabilities
 * Filters based on requester's role level
 * 
 * File: backend/get_capabilities.php
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
    // Optional: filter_by_role to show only grantable capabilities
    $requestRoleId = intval($_GET['requester_role_id'] ?? 0);
    
    // Get all active capabilities
    $query = "SELECT id, capability_key, category, description, required_role_id, is_active
              FROM capabilities
              WHERE is_active = TRUE
              ORDER BY category, capability_key";
    
    $result = $conn->query($query);
    
    if (!$result) {
        throw new Exception('Query failed: ' . $conn->error);
    }
    
    $capabilities = [];
    $byCategory = [];
    
    while ($cap = $result->fetch_assoc()) {
        $capArray = [
            'id' => intval($cap['id']),
            'capability_key' => $cap['capability_key'],
            'category' => $cap['category'],
            'description' => $cap['description'],
            'required_role_id' => intval($cap['required_role_id']),
            'is_active' => (bool)$cap['is_active']
        ];
        
        // If requester_role_id provided, check if they can grant this
        if ($requestRoleId) {
            $capArray['can_grant'] = $requestRoleId <= $cap['required_role_id'];
        }
        
        $capabilities[] = $capArray;
        
        // Group by category
        if (!isset($byCategory[$cap['category']])) {
            $byCategory[$cap['category']] = [];
        }
        $byCategory[$cap['category']][] = $capArray;
    }
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'capabilities' => $capabilities,
        'by_category' => $byCategory,
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
