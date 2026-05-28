<?php
$conn = new mysqli(
    getenv('MYSQL_HOST') ?: 'db',
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: 'rootpassword',
    getenv('MYSQL_DATABASE') ?: 'my_app_db'
);

if ($conn->connect_error) {
    echo json_encode([
        'error' => 'Connection failed: ' . $conn->connect_error
    ], JSON_PRETTY_PRINT);
    exit;
}

echo "=== PURCHASE_REQUESTS TABLE SCHEMA ===\n\n";

// Get all columns from purchase_requests table
$result = $conn->query("DESCRIBE purchase_requests");

if (!$result) {
    echo json_encode([
        'error' => 'Table not found: ' . $conn->error
    ], JSON_PRETTY_PRINT);
    exit;
}

$columns = [];
while ($col = $result->fetch_assoc()) {
    $columns[] = $col;
}

// Check for date_requested column
$has_date_requested = false;
foreach ($columns as $col) {
    if ($col['Field'] === 'date_requested') {
        $has_date_requested = true;
        break;
    }
}

echo "Total columns: " . count($columns) . "\n\n";
echo "Columns:\n";
foreach ($columns as $col) {
    $marker = ($col['Field'] === 'date_requested') ? " ✓" : "";
    echo "  - {$col['Field']} ({$col['Type']}, Null={$col['Null']}, Default={$col['Default']})$marker\n";
}

echo "\n=== RESULT ===\n";
if ($has_date_requested) {
    echo "✓ date_requested column EXISTS in database\n";
} else {
    echo "✗ date_requested column MISSING from database\n";
    echo "\nThis is the problem! The schema files were updated but the database was not.\n";
}

$conn->close();
?>
