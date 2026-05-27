<?php
/**
 * CORS and Security Headers Configuration
 * 
 * Whitelist specific origins instead of allowing all
 * Adjust for your deployment environment
 */




// Define allowed origins - LOCAL DEVELOPMENT MODE
$allowed_origins = [
    // Localhost with any port (for local development)
    'http://localhost:3000',
    'http://localhost:3001',
    'http://localhost:5173',
    'http://localhost:8080',
    'http://127.0.0.1:3000',
    'http://127.0.0.1:3001',
    'http://127.0.0.1:5173',
    'http://127.0.0.1:8080',
];

// Get the request origin
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

// Check if origin is in whitelist
$isAllowed = false;
foreach ($allowed_origins as $allowed) {
    if ($origin === $allowed) {
        $isAllowed = true;
        break;
    }
}

// DEVELOPMENT: Allow any localhost/127.0.0.1 origin
// TODO: Restrict this in production
if (!$isAllowed && (strpos($origin, 'localhost') !== false || strpos($origin, '127.0.0.1') !== false)) {
    $isAllowed = true;
}

if ($isAllowed) {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-User-ID, X-User-Email');
    header('Access-Control-Max-Age: 86400');
}

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Security Headers
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');


?>
