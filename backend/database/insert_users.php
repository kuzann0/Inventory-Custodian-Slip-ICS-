w<?php
/**
 * Insert users back into database
 */

header('Content-Type: application/json');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');

    if ($conn->connect_error) {
        throw new Exception('Connection failed: ' . $conn->connect_error);
    }

    // Users data
    $usersSQL = "
    INSERT INTO users (id, username, email, password_hash, role_id, account_status, is_superadmin, created_at) VALUES
    (1, 'superadmin', 'superadmin@ics.local', '\$2y\$10\$JuzdwISa4W1yBM9gkP2fTe0lACKEm/q4YI.dAE.3v8uMYphygFw4S', 1, 'active', 1, NOW()),
    (2, 'admin', 'admin@ics.local', '\$2y\$10\$wPpm2WkaQ92iJ28lf6c2nuTXWUd3BN3KgxPa2kACwhqE0GvzOnE1O', 2, 'active', 0, NOW()),
    (3, 'employee', 'employee@ics.local', '\$2y\$10\$nDQ67/3wPXYkeiEs1J7e9uODqJEfMnZKQZY20BnNV1J.Rl/FKjBli', 3, 'active', 0, NOW()),
    (4, 'testemployee', 'testemployee@test.com', '\$2y\$10\$WasdJWDGmdxcmPQnloSAbOVLf.Cni6cqwq9F7.b1VmSLx095fWtoK', 3, 'active', 0, NOW()),
    (6, 'testuser', 'test@example.com', '\$2y\$10\$dIWqGw0MdtN5104LVx8rD.wwm95yd7S2oPl9p3oLNmRlIzw7kPo2i', 3, 'active', 0, NOW()),
    (7, 'kuzano', 'kuzano.1001@gmail.com', '\$2y\$10\$ASZqbZczrJGeBe9S8zoHYO0BqISIi.fxzM.s34yIfeow3H0HSFe1u', 3, 'active', 0, NOW());
    ";

    if ($conn->multi_query($usersSQL)) {
        do {
            if ($result = $conn->store_result()) {
                $result->free();
            }
        } while ($conn->next_result());
        echo "✓ Users inserted successfully\n";
    } else {
        throw new Exception('Failed to insert users: ' . $conn->error);
    }

    // Verify
    $result = $conn->query('SELECT COUNT(*) as cnt FROM users');
    $row = $result->fetch_assoc();
    echo "✓ Total users now: " . $row['cnt'] . "\n";

    http_response_code(200);
    echo json_encode(['success' => true, 'users_inserted' => $row['cnt']]);
    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
