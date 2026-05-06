<?php
/**
 * Create Capabilities Database Table
 */

header('Content-Type: application/json');

try {
    $servername = getenv('MYSQL_HOST') ?? 'db';
    $dbuser = getenv('MYSQL_USER') ?? 'root';
    $dbpass = getenv('MYSQL_PASSWORD') ?? 'rootpassword';
    $dbname = getenv('MYSQL_DATABASE') ?? 'my_app_db';

    $conn = new mysqli($servername, $dbuser, $dbpass, $dbname);

    if ($conn->connect_error) {
        throw new Exception('Database connection failed: ' . $conn->connect_error);
    }

    // Create capabilities table
    $sql = "
    CREATE TABLE IF NOT EXISTS capabilities (
        id INT AUTO_INCREMENT PRIMARY KEY,
        capability_key VARCHAR(100) UNIQUE NOT NULL,
        category VARCHAR(50),
        description TEXT,
        required_role_id INT,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($sql)) {
        throw new Exception('Failed to create capabilities table: ' . $conn->error);
    }
    echo "✓ capabilities table created\n";

    // Insert default capabilities
    $capabilities = [
        ['view_dashboard', 'Dashboard', 'Access to dashboard', 1],
        ['manage_users', 'Users', 'Create and manage users', 1],
        ['manage_roles', 'Roles', 'Manage user roles', 1],
        ['view_entries', 'Entries', 'View all entries', 2],
        ['create_entry', 'Entries', 'Create new entry', 2],
        ['edit_entry', 'Entries', 'Edit entries', 2],
    ];

    foreach ($capabilities as $cap) {
        $stmt = $conn->prepare('INSERT IGNORE INTO capabilities (capability_key, category, description, required_role_id, is_active) VALUES (?, ?, ?, ?, TRUE)');
        $stmt->bind_param('sssi', $cap[0], $cap[1], $cap[2], $cap[3]);
        if (!$stmt->execute()) {
            throw new Exception('Failed to insert capability: ' . $stmt->error);
        }
    }
    echo "✓ Default capabilities inserted\n";

    http_response_code(200);
    echo json_encode(['success' => true, 'message' => 'Capabilities table created and populated']);
    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
