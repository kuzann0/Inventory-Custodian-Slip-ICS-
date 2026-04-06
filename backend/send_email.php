<?php
/**
 * Mail Endpoint
 * 
 * Handles email sending through the system
 * Supports both online and offline modes
 * 
 * POST /send_email.php
 * {
 *   "to": "user@example.com",
 *   "subject": "Subject",
 *   "body": "HTML body",
 *   "altText": "Plain text alternative",
 *   "token": "authentication_token"
 * }
 */

require_once __DIR__ . '/vendor/autoload.php';

use ICS\MailService;
use ICS\AuthService;

session_start();

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    // Get request data
    $data = json_decode(file_get_contents("php://input"), true);

    // Validate required fields
    $required = ['to', 'subject', 'body', 'token'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            http_response_code(400);
            throw new Exception("Missing required field: $field");
        }
    }

    // Verify authentication token
    $tokenDir = __DIR__ . '/offline_tokens/';
    $tokenFile = $tokenDir . $data['token'] . '.session';

    if (!file_exists($tokenFile)) {
        http_response_code(401);
        throw new Exception("Invalid or expired token");
    }

    // Validate email format
    if (!filter_var($data['to'], FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        throw new Exception("Invalid email address");
    }

    // Initialize mail service
    $mailService = new MailService();

    // Send email
    $result = $mailService->send(
        $data['to'],
        $data['subject'],
        $data['body'],
        $data['altText'] ?? '',
        $data['attachments'] ?? []
    );

    http_response_code($result['success'] ? 200 : 500);
    echo json_encode($result);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
    error_log('Mail error: ' . $e->getMessage());
}
?>
