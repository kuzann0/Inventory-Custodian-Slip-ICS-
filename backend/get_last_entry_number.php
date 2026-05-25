<?php
require_once 'config/cors.php';
header('Content-Type: application/json');

$conn = new mysqli(
    getenv('MYSQL_HOST') ?: 'db',
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: 'rootpassword',
    getenv('MYSQL_DATABASE') ?: 'my_app_db'
);

$account_code = $_GET['account_code'] ?? '';
$location_code = $_GET['location_code'] ?? '';
$year = $_GET['year'] ?? '';

if (!$account_code || !$location_code || !$year) {
    echo json_encode(['last_entry_number' => '0000']);
    exit;
}

// Account code is now sanitized (hyphens removed) by frontend
// Construct LIKE pattern: YYYY-CLEANCODE-ENTRY-LOC (e.g., 2026-40502-0001-01)
$like_pattern = "{$year}-{$account_code}-%-{$location_code}";

$stmt = $conn->prepare("
    SELECT property_number 
    FROM property_inventory_tags 
    WHERE property_number LIKE ? 
    ORDER BY id DESC LIMIT 1
");
$stmt->bind_param('s', $like_pattern);
$stmt->execute();
$result = $stmt->get_result();
$row = $result->fetch_assoc();

$last_entry = '0000';
if ($row && preg_match('/-(\d{4})-/', $row['property_number'], $matches)) {
    $last_entry = $matches[1];
}

echo json_encode(['last_entry_number' => $last_entry]);
?>