<?php
/**
 * CORS and Security Headers Configuration
 * 
 * Whitelist specific origins instead of allowing all
 * Adjust for your deployment environment
 */

// Define allowed origins
$allowed_origins = [
    'http://localhost:3000',      // Frontend dev
    'http://localhost:5173',      // Vite dev
    'http://127.0.0.1:3000',
    'http://127.0.0.1:5173',
    // Add production origins here when deployed
    // 'https://yourdomain.com'
];

// Get the request origin
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

// Check if origin is allowed
if (in_array($origin, $allowed_origins)) {
    header('Access-Control-Allow-Origin: ' . $origin);
    header('Access-Control-Allow-Credentials: true');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    header('Access-Control-Max-Age: 86400');
}

// Security Headers
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('X-XSS-Protection: 1; mode=block');
header('Strict-Transport-Security: max-age=31536000; includeSubDomains');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
