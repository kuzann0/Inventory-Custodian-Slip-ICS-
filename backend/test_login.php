<?php
/**
 * Test login endpoint
 */

$loginUrl = 'http://ics-backend/login.php';

$testUsers = [
    ['username' => 'kuzano', 'password' => 'Kuzano@2026'],
    ['username' => 'superadmin', 'password' => 'SuperAdmin@2026'],
    ['username' => 'admin', 'password' => 'Admin@2026']
];

echo "Testing login endpoint at: $loginUrl\n\n";

foreach ($testUsers as $credentials) {
    $ch = curl_init($loginUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($credentials));
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    echo "Testing: {$credentials['username']} / {$credentials['password']}\n";
    echo "HTTP Status: $httpCode\n";
    echo "Response: $response\n";
    echo "---\n\n";
}
?>
