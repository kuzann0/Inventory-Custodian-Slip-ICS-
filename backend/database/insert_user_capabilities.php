<?php
/**
 * Insert user capabilities back into database
 */

header('Content-Type: application/json');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');

    if ($conn->connect_error) {
        throw new Exception('Connection failed: ' . $conn->connect_error);
    }

    // User capabilities data - SuperAdmin gets all 17, Admin gets most, Employee gets basic
    $capsSQL = "
    INSERT INTO user_capabilities (id, user_id, capability_id, granted_by_id, granted_at) VALUES
    -- SuperAdmin (user 1) gets all capabilities
    (1, 1, 1, NULL, NOW()),
    (2, 1, 2, NULL, NOW()),
    (3, 1, 3, NULL, NOW()),
    (4, 1, 4, NULL, NOW()),
    (5, 1, 5, NULL, NOW()),
    (6, 1, 6, NULL, NOW()),
    (7, 1, 7, NULL, NOW()),
    (8, 1, 8, NULL, NOW()),
    (9, 1, 9, NULL, NOW()),
    (10, 1, 10, NULL, NOW()),
    (11, 1, 11, NULL, NOW()),
    (12, 1, 12, NULL, NOW()),
    (13, 1, 13, NULL, NOW()),
    (14, 1, 14, NULL, NOW()),
    (15, 1, 15, NULL, NOW()),
    (16, 1, 16, NULL, NOW()),
    (17, 1, 17, NULL, NOW()),
    -- Admin (user 2) gets INVENTORY and USER capabilities
    (18, 2, 1, NULL, NOW()),
    (19, 2, 2, NULL, NOW()),
    (20, 2, 3, NULL, NOW()),
    (21, 2, 4, NULL, NOW()),
    (22, 2, 5, NULL, NOW()),
    (23, 2, 6, NULL, NOW()),
    (24, 2, 7, NULL, NOW()),
    (25, 2, 15, NULL, NOW()),
    (26, 2, 16, NULL, NOW()),
    (27, 2, 17, NULL, NOW()),
    -- Employee (user 3) gets basic USER capabilities
    (28, 3, 15, NULL, NOW()),
    (29, 3, 2, NULL, NOW()),
    (30, 3, 16, NULL, NOW()),
    (31, 3, 17, NULL, NOW()),
    -- TestEmployee (user 4) gets basic capabilities
    (32, 4, 15, NULL, NOW()),
    (33, 4, 2, NULL, NOW()),
    (34, 4, 16, NULL, NOW()),
    (35, 4, 17, NULL, NOW());
    ";

    if ($conn->multi_query($capsSQL)) {
        do {
            if ($result = $conn->store_result()) {
                $result->free();
            }
        } while ($conn->next_result());
        echo "✓ User capabilities inserted successfully\n";
    } else {
        throw new Exception('Failed to insert capabilities: ' . $conn->error);
    }

    // Verify
    $result = $conn->query('SELECT COUNT(*) as cnt FROM user_capabilities');
    $row = $result->fetch_assoc();
    echo "✓ Total user capabilities now: " . $row['cnt'] . "\n";

    http_response_code(200);
    echo json_encode(['success' => true, 'user_capabilities_inserted' => (int)$row['cnt']]);
    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
