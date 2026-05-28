<?php
/**
 * Add date_requested column to purchase_requests table if it doesn't exist
 * This is a migration script to fix the database schema without losing data
 */

require_once __DIR__ . '/../config/db.php';

// Check if date_requested column already exists
$result = $conn->query("DESCRIBE purchase_requests");

if (!$result) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Could not query table: ' . $conn->error
    ], JSON_PRETTY_PRINT);
    exit;
}

$columns = [];
$has_date_requested = false;

while ($col = $result->fetch_assoc()) {
    $columns[] = $col['Field'];
    if ($col['Field'] === 'date_requested') {
        $has_date_requested = true;
    }
}

if ($has_date_requested) {
    echo json_encode([
        'success' => true,
        'message' => 'date_requested column already exists',
        'action' => 'none'
    ], JSON_PRETTY_PRINT);
    exit;
}

// Column doesn't exist, add it
$alter_sql = "ALTER TABLE purchase_requests ADD COLUMN `date_requested` DATE DEFAULT NULL AFTER `division_section`";

if ($conn->query($alter_sql)) {
    echo json_encode([
        'success' => true,
        'message' => 'Successfully added date_requested column',
        'action' => 'added',
        'sql' => $alter_sql
    ], JSON_PRETTY_PRINT);
} else {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Failed to add column: ' . $conn->error,
        'sql' => $alter_sql
    ], JSON_PRETTY_PRINT);
}

$conn->close();
?>
