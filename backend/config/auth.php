<?php
/**
 * Authentication and Security Middleware
 * 
 * Provides helper functions for authentication, validation, and security checks
 */

/**
 * Check if user is authenticated
 * Returns user ID if authenticated, false otherwise
 */
function isAuthenticated() {
    if (!isset($_SESSION)) {
        session_start();
    }
    
    return isset($_SESSION['user_id']) ? $_SESSION['user_id'] : false;
}

/**
 * Get current user data from session
 */
function getCurrentUser() {
    if (!isset($_SESSION)) {
        session_start();
    }
    
    if (empty($_SESSION['user_id'])) {
        return null;
    }
    
    return [
        'id' => $_SESSION['user_id'],
        'username' => $_SESSION['username'] ?? null,
        'email' => $_SESSION['email'] ?? null,
        'role_id' => $_SESSION['role_id'] ?? null,
        'role_name' => $_SESSION['role_name'] ?? null,
        'permissions' => $_SESSION['permissions'] ?? []
    ];
}

/**
 * Check if user has a specific capability
 */
function hasCapability($capabilityKey) {
    require_once __DIR__ . '/db.php';
    
    $userId = isAuthenticated();
    if (!$userId) {
        return false;
    }
    
    $stmt = $conn->prepare("
        SELECT uc.id FROM user_capabilities uc
        JOIN capabilities c ON uc.capability_id = c.id
        WHERE uc.user_id = ? 
        AND c.capability_key = ?
        AND (uc.expires_at IS NULL OR uc.expires_at > NOW())
    ");
    
    if (!$stmt) {
        return false;
    }
    
    $stmt->bind_param('is', $userId, $capabilityKey);
    $result = $stmt->execute() ? $stmt->get_result() : null;
    $stmt->close();
    
    return $result && $result->num_rows > 0;
}

/**
 * Require authentication - die with error if not authenticated
 */
function requireAuth() {
    if (!isAuthenticated()) {
        http_response_code(401);
        header('Content-Type: application/json');
        die(json_encode([
            'success' => false,
            'error' => 'Authentication required'
        ]));
    }
}

/**
 * Require specific capability - die with error if not authorized
 */
function requireCapability($capabilityKey) {
    requireAuth();
    
    if (!hasCapability($capabilityKey)) {
        http_response_code(403);
        header('Content-Type: application/json');
        die(json_encode([
            'success' => false,
            'error' => 'Insufficient permissions'
        ]));
    }
}

/**
 * Sanitize input string to prevent XSS
 */
function sanitizeInput($input) {
    if (is_array($input)) {
        return array_map('sanitizeInput', $input);
    }
    return htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
}

/**
 * Validate email format
 */
function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

/**
 * Get client IP address (accounting for proxies)
 */
function getClientIP() {
    if (!empty($_SERVER['HTTP_CLIENT_IP'])) {
        $ip = $_SERVER['HTTP_CLIENT_IP'];
    } elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR'])) {
        $ips = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);
        $ip = trim($ips[0]);
    } else {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    }
    return filter_var($ip, FILTER_VALIDATE_IP) ? $ip : 'unknown';
}

/**
 * Log security event
 */
function logSecurityEvent($action, $details = []) {
    require_once __DIR__ . '/db.php';
    
    $userId = isAuthenticated();
    $ip = getClientIP();
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
    $detailsJson = json_encode($details);
    
    $stmt = $conn->prepare("
        INSERT INTO audit_logs (admin_id, action, action_details, ip_address, user_agent)
        VALUES (?, ?, ?, ?, ?)
    ");
    
    if ($stmt) {
        $stmt->bind_param('issss', $userId, $action, $detailsJson, $ip, $userAgent);
        $stmt->execute();
        $stmt->close();
    }
}

/**
 * Rate limit check (simple in-memory for single server)
 * For distributed systems, use Redis
 */
$RATE_LIMITS = [];

function checkRateLimit($identifier, $maxAttempts = 5, $windowSeconds = 60) {
    global $RATE_LIMITS;
    
    $now = time();
    $key = md5($identifier);
    
    if (!isset($RATE_LIMITS[$key])) {
        $RATE_LIMITS[$key] = [];
    }
    
    // Clean old attempts
    $RATE_LIMITS[$key] = array_filter(
        $RATE_LIMITS[$key],
        fn($timestamp) => $now - $timestamp < $windowSeconds
    );
    
    if (count($RATE_LIMITS[$key]) >= $maxAttempts) {
        return false; // Rate limited
    }
    
    $RATE_LIMITS[$key][] = $now;
    return true; // Allow
}

?>
