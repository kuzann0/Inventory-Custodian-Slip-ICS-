<?php
/**
 * Process Offline Emails Endpoint
 * 
 * Manually triggers offline email queue processing
 * Should be protected by authentication in production
 * 
 * Usage:
 * curl -X POST http://localhost:8080/process_offline_emails.php \
 *   -H "Content-Type: application/json" \
 *   -d '{"token": "admin_token"}'
 */

require_once __DIR__ . '/vendor/autoload.php';

use ICS\MailService;

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    $data = json_decode(file_get_contents("php://input"), true) ?? $_POST;

    // Optional: Verify admin token
    if (!empty($data['token'])) {
        $tokenFile = __DIR__ . '/offline_tokens/' . $data['token'] . '.session';
        if (!file_exists($tokenFile)) {
            http_response_code(401);
            throw new Exception("Unauthorized");
        }
    }

    // Initialize mail service
    $mailService = new MailService();

    // Get mode
    $mode = $mailService->getMode();

    if ($mode !== 'online') {
        http_response_code(503);
        echo json_encode([
            'success' => false,
            'message' => 'System is in offline mode. Cannot process emails.',
            'mode' => $mode
        ]);
        exit;
    }

    // Process offline emails
    $result = $mailService->processOfflineEmails();

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Offline email queue processed',
        'mode' => 'online',
        'summary' => $result
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
    error_log('Offline email processing error: ' . $e->getMessage());
}
?>
