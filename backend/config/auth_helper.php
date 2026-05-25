<?php
/**
 * Authentication Helper Functions
 * 
 * Centralized authentication logic for resolving user ID from multiple sources
 * and validating user access across all endpoints.
 */

/**
 * Resolve user ID from multiple sources
 * 
 * Priority order:
 * 1. Request body (JSON)
 * 2. Session
 * 3. HTTP header (X-User-ID)
 * 4. Query parameter (user_id)
 * 
 * Returns user_id or null if not found
 */
function resolveUserId($rawBody = null) {
    $user_id = null;
    
    // Source 1: JSON body
    if ($rawBody) {
        $data = json_decode($rawBody, true);
        if (!empty($data['user_id'])) {
            $user_id = (int) $data['user_id'];
            if ($user_id > 0) return $user_id;
        }
    }
    
    // Source 2: Session
    if (empty($_SESSION)) {
        @session_start();
    }
    
    if (!empty($_SESSION['user_id'])) {
        $user_id = (int) $_SESSION['user_id'];
        if ($user_id > 0) return $user_id;
    }
    
    // Source 3: HTTP Header
    if (!empty($_SERVER['HTTP_X_USER_ID'])) {
        $user_id = (int) $_SERVER['HTTP_X_USER_ID'];
        if ($user_id > 0) return $user_id;
    }
    
    // Source 4: Query parameter
    if (!empty($_GET['user_id'])) {
        $user_id = (int) $_GET['user_id'];
        if ($user_id > 0) return $user_id;
    }
    
    return null;
}

/**
 * Validate user exists and is active in database
 * 
 * @param mysqli $conn Database connection
 * @param int $user_id User ID to validate
 * @return array|null User data if valid, null if not found
 */
function validateUserExists($conn, $user_id) {
    if (!is_numeric($user_id) || $user_id <= 0) {
        return null;
    }
    
    $stmt = $conn->prepare("SELECT id, username, email, role_id, is_active FROM users WHERE id = ?");
    if (!$stmt) {
        return null;
    }
    
    $stmt->bind_param('i', $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        $stmt->close();
        return null;
    }
    
    $user = $result->fetch_assoc();
    $stmt->close();
    
    // Check if user is active
    if ((int) $user['is_active'] !== 1) {
        return null;
    }
    
    return $user;
}

/**
 * Check if user has a specific role
 * 
 * @param int $role_id Current user's role_id
 * @param array $allowed_roles Array of allowed role IDs
 * @return bool
 */
function hasRole($role_id, $allowed_roles = []) {
    return in_array((int) $role_id, $allowed_roles, true);
}

/**
 * Require authentication helper - returns user_id or exits with JSON error
 * 
 * @param mysqli $conn Database connection
 * @param string $rawBody Request body for user_id resolution
 * @return int Authenticated user_id
 */
function requireAuthenticatedUser($conn, $rawBody = null) {
    $user_id = resolveUserId($rawBody);
    
    if (!$user_id) {
        http_response_code(401);
        exit(json_encode([
            'success' => false,
            'error' => 'Authentication required. Please provide user_id in request body, X-User-ID header, or log in.'
        ]));
    }
    
    // Validate user exists
    $user = validateUserExists($conn, $user_id);
    if (!$user) {
        http_response_code(403);
        exit(json_encode([
            'success' => false,
            'error' => 'User not found or inactive'
        ]));
    }
    
    return $user_id;
}

/**
 * Require specific role - exits with JSON error if user doesn't have role
 * 
 * @param mysqli $conn Database connection
 * @param int $user_id User ID to check
 * @param array $allowed_roles Array of allowed role IDs
 */
function requireRole($conn, $user_id, $allowed_roles = []) {
    $user = validateUserExists($conn, $user_id);
    if (!$user) {
        http_response_code(403);
        exit(json_encode([
            'success' => false,
            'error' => 'User not found or inactive'
        ]));
    }
    
    if (!hasRole($user['role_id'], $allowed_roles)) {
        http_response_code(403);
        exit(json_encode([
            'success' => false,
            'error' => 'Insufficient permissions for this action'
        ]));
    }
}
?>
