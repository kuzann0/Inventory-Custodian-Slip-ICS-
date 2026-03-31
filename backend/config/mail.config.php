<?php
/**
 * Mail Configuration
 * 
 * Configuration for email settings in both online and offline modes.
 * Supports Gmail, Office365, custom SMTP, and offline fallback scenarios.
 */

// ============================================================================
// MAIL CONFIGURATION
// ============================================================================

// Email Mode: 'online' or 'offline'
define('MAIL_MODE', getenv('MAIL_MODE') ?? 'online');

// SMTP Configuration
define('MAIL_HOST', getenv('MAIL_HOST') ?? 'smtp.gmail.com');
define('MAIL_PORT', getenv('MAIL_PORT') ?? 587);
define('MAIL_USERNAME', getenv('MAIL_USERNAME') ?? 'your-email@gmail.com');
define('MAIL_PASSWORD', getenv('MAIL_PASSWORD') ?? 'your-app-password');
define('MAIL_FROM_ADDRESS', getenv('MAIL_FROM_ADDRESS') ?? 'noreply@ics-system.local');
define('MAIL_FROM_NAME', getenv('MAIL_FROM_NAME') ?? 'ICS System');

// Security Settings
define('MAIL_ENCRYPTION', getenv('MAIL_ENCRYPTION') ?? 'tls'); // 'tls' or 'ssl'
define('MAIL_VERIFY_SSL', getenv('MAIL_VERIFY_SSL') ?? false);

// Offline Mode Settings
define('OFFLINE_MAIL_DIR', __DIR__ . '/offline_emails/');
define('OFFLINE_TOKEN_DIR', __DIR__ . '/offline_tokens/');

// Email Retry Settings
define('MAIL_MAX_RETRIES', 3);
define('MAIL_RETRY_DELAY', 300); // 5 minutes in seconds

return [
    'smtp' => [
        'host' => MAIL_HOST,
        'port' => MAIL_PORT,
        'username' => MAIL_USERNAME,
        'password' => MAIL_PASSWORD,
        'encryption' => MAIL_ENCRYPTION,
        'verifySSL' => MAIL_VERIFY_SSL,
    ],
    'from' => [
        'address' => MAIL_FROM_ADDRESS,
        'name' => MAIL_FROM_NAME,
    ],
    'mode' => MAIL_MODE,
    'offline' => [
        'email_dir' => OFFLINE_MAIL_DIR,
        'token_dir' => OFFLINE_TOKEN_DIR,
        'max_retries' => MAIL_MAX_RETRIES,
        'retry_delay' => MAIL_RETRY_DELAY,
    ]
];
?>
