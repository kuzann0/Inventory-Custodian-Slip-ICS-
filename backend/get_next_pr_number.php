<?php
require_once './config/cors.php';

ini_set('display_errors', '0');
ini_set('log_errors', '1');
error_reporting(E_ALL);

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

function jsonError(string $message, int $code = 500, array $debug = []): never {
    http_response_code($code);
    $payload = ['success' => false, 'error' => $message];
    if (!empty($debug)) {
        $payload['debug'] = $debug;
    }
    echo json_encode($payload);
    exit;
}

function jsonOk(array $payload): never {
    http_response_code(200);
    echo json_encode(array_merge(['success' => true], $payload));
    exit;
}

try {
    date_default_timezone_set(getenv('APP_TIMEZONE') ?: 'Asia/Manila');
    $yearMonth = date('Y-m');

    $conn = new mysqli(
        getenv('MYSQL_HOST')     ?: 'db',
        getenv('MYSQL_USER')     ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );

    if ($conn->connect_error) {
        error_log('[get_next_pr_number] DB connect error: ' . $conn->connect_error);
        jsonError('Database connection failed. Please try again later.', 503);
    }

    $conn->set_charset('utf8mb4');

    $createSeqSql = "CREATE TABLE IF NOT EXISTS pr_sequence (year_month VARCHAR(7) NOT NULL, last_seq INT NOT NULL DEFAULT 0, PRIMARY KEY (year_month)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci";

    if (!$conn->query($createSeqSql)) {
        error_log('[get_next_pr_number] create pr_sequence failed: ' . $conn->error);
        jsonError('Failed to initialize PR sequence generator.', 500);
    }

    $insertSql = "INSERT INTO pr_sequence (year_month, last_seq)
        VALUES (?, 1)
        ON DUPLICATE KEY UPDATE last_seq = LAST_INSERT_ID(last_seq + 1)";

    $stmt = $conn->prepare($insertSql);
    if (!$stmt) {
        error_log('[get_next_pr_number] prepare insert/update seq: ' . $conn->error);
        jsonError('Failed to prepare PR sequence request.', 500);
    }

    $stmt->bind_param('s', $yearMonth);
    if (!$stmt->execute()) {
        error_log('[get_next_pr_number] execute insert/update seq: ' . $stmt->error);
        jsonError('Failed to allocate next PR number.', 500);
    }

    $sequence = (int) $conn->insert_id;
    $stmt->close();

    if ($sequence <= 0) {
        $fallbackStmt = $conn->prepare('SELECT last_seq FROM pr_sequence WHERE year_month = ?');
        if ($fallbackStmt) {
            $fallbackStmt->bind_param('s', $yearMonth);
            $fallbackStmt->execute();
            $fallbackStmt->bind_result($sequence);
            $fallbackStmt->fetch();
            $fallbackStmt->close();
        }
    }

    if ($sequence <= 0) {
        error_log('[get_next_pr_number] sequence allocation returned invalid value: ' . $sequence);
        jsonError('Failed to allocate PR sequence number.', 500);
    }

    $prNo = sprintf('%s-%03d', $yearMonth, $sequence);
    jsonOk(['pr_no' => $prNo, 'year_month' => $yearMonth, 'sequence' => $sequence]);

} catch (Throwable $e) {
    error_log('[get_next_pr_number] exception: ' . $e->getMessage());
    jsonError('Unexpected server error while generating PR number.', 500);
}
