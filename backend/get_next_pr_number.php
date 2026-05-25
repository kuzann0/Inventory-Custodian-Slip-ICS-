<?php
/**
 * GET /get_next_pr_number.php?prefix=YYYY-MM
 * Returns the next available PR number for the given year-month prefix.
 * Example: prefix=2026-05 -> returns "2026-05-003" if 001 and 002 already exist.
 */

require_once 'config/cors.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$prefix = isset($_GET['prefix']) ? trim($_GET['prefix']) : '';

if (!preg_match('/^\d{4}-\d{2}$/', $prefix)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid prefix format. Use YYYY-MM']);
    exit;
}

$conn = new mysqli(
    getenv('MYSQL_HOST') ?: 'db',
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: 'rootpassword',
    getenv('MYSQL_DATABASE') ?: 'my_app_db'
);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit;
}

// Find the highest existing PR number with the same prefix
$pattern = $prefix . '-%';
$stmt = $conn->prepare("SELECT pr_no FROM purchase_requests WHERE pr_no LIKE ? ORDER BY pr_no DESC LIMIT 1");
$stmt->bind_param('s', $pattern);
$stmt->execute();
$result = $stmt->get_result();

$nextNumber = 1;
if ($row = $result->fetch_assoc()) {
    $last = $row['pr_no'];
    // Extract the numeric part after the last hyphen
    if (preg_match('/-(\d+)$/', $last, $matches)) {
        $nextNumber = intval($matches[1]) + 1;
    }
}
$stmt->close();
$conn->close();

$nextPrNo = sprintf("%s-%03d", $prefix, $nextNumber);

http_response_code(200);
echo json_encode(['pr_no' => $nextPrNo]);
?>