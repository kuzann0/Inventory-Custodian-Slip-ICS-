<?php
/**
 * Centralized Database Connection Configuration
 * 
 * All database connections should use this config to ensure
 * proper credential management and security
 */

// Get database credentials from environment variables
$db_host = getenv('MYSQL_HOST') ?: 'db';
$db_user = getenv('MYSQL_USER') ?: 'root';
$db_pass = getenv('MYSQL_PASSWORD') ?: 'rootpassword';
$db_name = getenv('MYSQL_DATABASE') ?: 'my_app_db';

// Create database connection
$conn = new mysqli($db_host, $db_user, $db_pass, $db_name);

// Check connection
if ($conn->connect_error) {
    http_response_code(500);
    header('Content-Type: application/json');
    die(json_encode([
        'success' => false,
        'error' => 'Database connection failed',
        'details' => ($conn->connect_error || 'Unknown error')
    ]));
}

// Set charset to utf8mb4
$conn->set_charset("utf8mb4");

// Return connection for use in other files
?>
