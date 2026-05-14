<?php
/**
 * Admin Bypass Endpoint
 * 
 * Secure endpoint allowing admin to bypass OTP in case of emergency
 * Can only be accessed with correct admin key
 * All bypass attempts are logged for security
 * 
 * POST /admin_bypass.php
 * {
 *   "admin_key": "secure_key_from_environment",
 *   "email": "user@example.com",
 *   "reason": "Emergency access"
 * }
 */

require_once __DIR__ . '/vendor/autoload.php';

header("Access-Control-Allow-Origin: " . ($_SERVER['HTTP_ORIGIN'] ?? '*'));
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, X-Requested-With");
header("Access-Control-Allow-Credentials: true");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;

    // Get admin bypass key from environment
    $validAdminKey = getenv('ADMIN_BYPASS_KEY');
    if (!$validAdminKey) {
        http_response_code(503);
        throw new Exception("Admin bypass not configured");
    }

    // Validate admin key
    if (empty($data['admin_key']) || !hash_equals($validAdminKey, $data['admin_key'])) {
        http_response_code(401);
        
        // Log failed attempt
        error_log("Failed admin bypass attempt from IP: " . ($_SERVER['REMOTE_ADDR'] ?? 'unknown'));
        
        throw new Exception("Invalid admin key");
    }

    // Validate email
    if (empty($data['email']) || !filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        throw new Exception("Valid email required");
    }

    // Create bypass session
    $sessionToken = bin2hex(random_bytes(32));
    $sessionDir = __DIR__ . '/otp_sessions/';
    @mkdir($sessionDir, 0755, true);

    $sessionData = [
        'email' => $data['email'],
        'verified_at' => time(),
        'token' => $sessionToken,
        'bypass_mode' => true,
        'bypass_reason' => $data['reason'] ?? 'Admin bypass',
        'admin_ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
    ];

    file_put_contents(
        $sessionDir . $sessionToken . '.json',
        json_encode($sessionData)
    );

    // Log to database for audit trail
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser     = getenv('MYSQL_USER') ?? 'root';
    $dbpass     = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname     = getenv('MYSQL_DATABASE') ?? 'my_app_db';

    $db = @new mysqli($servername, $dbuser, $dbpass, $dbname);

    if ($db && !$db->connect_error) {
        try {
            $logQuery = "INSERT INTO admin_bypass_log (bypassed_user_email, bypass_key, ip_address, user_agent) 
                        VALUES (?, ?, ?, ?)";
            $logStmt = $db->prepare($logQuery);
            $keyHash = hash('sha256', $data['admin_key']);
            $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
            $ipAddress = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
            
            $logStmt->bind_param("ssss", $data['email'], $keyHash, $ipAddress, $userAgent);
            $logStmt->execute();
            $logStmt->close();
            
            error_log("Admin bypass used for email: {$data['email']} from IP: $ipAddress");
        } catch (Exception $e) {
            error_log('Failed to log admin bypass: ' . $e->getMessage());
        }
        $db->close();
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Admin bypass granted',
        'session_token' => $sessionToken,
        'email' => $data['email'],
        'bypass_mode' => true
    ], JSON_UNESCAPED_SLASHES);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
    error_log('Admin bypass error: ' . $e->getMessage());
}
?>
