<?php
/**
 * Migration: Alter item_name to LONGTEXT
 * Purpose: Support storing complex item descriptions and JSON arrays
 * Date: 2026-05-26
 */

// Database connection
$conn = new mysqli(
    getenv('MYSQL_HOST') ?: 'db',
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: 'rootpassword',
    getenv('MYSQL_DATABASE') ?: 'my_app_db'
);

if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]));
}

try {
    // Step 1: Alter item_name from VARCHAR(255) to LONGTEXT
    $sql1 = "ALTER TABLE purchase_requests MODIFY COLUMN item_name LONGTEXT COLLATE utf8mb4_unicode_ci";
    if (!$conn->query($sql1)) {
        throw new Exception('Failed to alter item_name column: ' . $conn->error);
    }

    // Step 2: Alter description to ensure it's LONGTEXT
    $sql2 = "ALTER TABLE purchase_requests MODIFY COLUMN description LONGTEXT COLLATE utf8mb4_unicode_ci";
    if (!$conn->query($sql2)) {
        throw new Exception('Failed to alter description column: ' . $conn->error);
    }

    // Step 3: Verify the changes
    $verify_sql = "SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_NAME='purchase_requests' AND COLUMN_NAME IN ('item_name', 'description')";
    $result = $conn->query($verify_sql);
    $columns = [];
    while ($row = $result->fetch_assoc()) {
        $columns[$row['COLUMN_NAME']] = $row['COLUMN_TYPE'];
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Migration completed successfully',
        'columns_altered' => $columns
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

$conn->close();
?>
