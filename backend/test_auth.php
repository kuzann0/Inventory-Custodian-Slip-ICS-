<?php
header('Content-Type: application/json');
session_start();

// Get POST data
$input = file_get_contents('php://input');
$data = json_decode($input, true);

$response = [
    'received_body' => $data,
    'received_headers' => [],
    'session' => $_SESSION,
    'user_id_sources' => [
        'in_body' => isset($data['user_id']) ? $data['user_id'] : null,
        'in_session' => isset($_SESSION['user_id']) ? $_SESSION['user_id'] : null,
        'in_header_http_x_user_id' => isset($_SERVER['HTTP_X_USER_ID']) ? $_SERVER['HTTP_X_USER_ID'] : null,
    ]
];

// Add all HTTP headers
foreach ($_SERVER as $key => $value) {
    if (strpos($key, 'HTTP_') === 0) {
        $response['received_headers'][$key] = $value;
    }
}

echo json_encode($response, JSON_PRETTY_PRINT);
?>
