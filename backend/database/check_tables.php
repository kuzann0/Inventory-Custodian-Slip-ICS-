<?php
$conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');

if ($conn->connect_error) {
    echo "Connection failed: " . $conn->connect_error;
    exit;
}

echo "Tables in my_app_db:\n";
echo "==================\n\n";

$result = $conn->query('SHOW TABLES');
$tableCount = 0;

while ($row = $result->fetch_row()) {
    $tableCount++;
    $table = $row[0];
    echo "$tableCount. $table\n";
    
    // Get table structure
    $structure = $conn->query("DESCRIBE $table");
    if ($structure) {
        $colCount = 0;
        while ($col = $structure->fetch_assoc()) {
            $colCount++;
            if ($colCount <= 3) {
                echo "   - " . $col['Field'] . " (" . $col['Type'] . ")\n";
            }
        }
        if ($colCount > 3) {
            echo "   ... and " . ($colCount - 3) . " more columns\n";
        }
    }
    echo "\n";
}

echo "\n✓ Total tables: $tableCount\n";

// Check if purchase_requests table exists
$check = $conn->query("SELECT 1 FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'my_app_db' AND TABLE_NAME = 'purchase_requests'");

if ($check->num_rows > 0) {
    echo "✓ purchase_requests table EXISTS\n";
    
    // Get column count
    $cols = $conn->query("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'purchase_requests' AND TABLE_SCHEMA = 'my_app_db'");
    echo "  Columns: " . $cols->num_rows . "\n";
} else {
    echo "✗ purchase_requests table DOES NOT EXIST\n";
    echo "  → Need to create it for the workflow\n";
}

$conn->close();
?>
