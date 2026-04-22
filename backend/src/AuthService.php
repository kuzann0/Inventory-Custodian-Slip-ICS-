<?php
/**
 * Authentication Service
 * 
 * Handles both online (database) and offline (token-based) authentication
 * Implements token caching for offline scenarios
 */

namespace ICS;

class AuthService {
    private $db;
    private $tokenDir;
    private $isOnline;
    private $tokenExpiry = 7 * 24 * 3600; // 7 days

    /**
     * Initialize Auth Service
     */
    public function __construct($db = null) {
        $this->db = $db;
        $this->tokenDir = __DIR__ . '/../offline_tokens/';
        @mkdir($this->tokenDir, 0755, true);

        // Check if we can connect to database
        $this->isOnline = $this->checkOnlineStatus();
    }

    /**
     * Check if system is online (database accessible)
     */
    private function checkOnlineStatus() {
        if ($this->db === null) {
            return false;
        }

        try {
            if ($this->db->connect_error) {
                return false;
            }
            // Simple ping test
            if (!$this->db->ping()) {
                return false;
            }
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }

    /**
     * Authenticate User
     * 
     * Attempts online authentication first, falls back to offline tokens
     * 
     * @param string $username Username
     * @param string $password Password
     * @return array ['success' => bool, 'message' => string, 'mode' => 'online'|'offline', 'token' => string, 'user' => array]
     */
    public function authenticate($username, $password) {
        // Try online authentication first
        if ($this->isOnline) {
            $onlineResult = $this->authenticateOnline($username, $password);
            if ($onlineResult['success']) {
                // Cache token for offline use
                $this->cacheToken($username, $onlineResult['token']);
                return $onlineResult;
            }
        }

        // Fall back to offline authentication
        return $this->authenticateOffline($username, $password);
    }

    /**
     * Online Authentication (Database)
     */
    private function authenticateOnline($username, $password) {
        try {
            // Check users table with role info - join with user_roles to get role name
            $query = "SELECT u.id, u.username, u.email, u.password_hash, u.role_id, u.is_superadmin, r.role_name FROM users u LEFT JOIN user_roles r ON u.role_id = r.id WHERE u.username = ?";
            $stmt = $this->db->prepare($query);
            
            if (!$stmt) {
                throw new \Exception("Database query prepare failed: " . $this->db->error);
            }

            $stmt->bind_param("s", $username);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows === 0) {
                return [
                    'success' => false,
                    'message' => 'User not found',
                    'mode' => 'online'
                ];
            }

            $user = $result->fetch_assoc();
            $stmt->close();

            // Verify password
            if (!password_verify($password, $user['password_hash'])) {
                return [
                    'success' => false,
                    'message' => 'Invalid password',
                    'mode' => 'online'
                ];
            }

            // Generate token
            $token = $this->generateToken($username);

            // Determine role from is_superadmin flag or role_name
            $role = $user['is_superadmin'] ? 'SuperAdmin' : ($user['role_name'] ?? 'Admin');

            return [
                'success' => true,
                'message' => 'Authenticated online',
                'mode' => 'online',
                'token' => $token,
                'user' => [
                    'id' => $user['id'],
                    'username' => $user['username'],
                    'email' => $user['email'],
                    'role' => $role,
                    'is_superadmin' => (bool)$user['is_superadmin']
                ]
            ];
        } catch (\Exception $e) {
            error_log('Online auth error: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Authentication failed: ' . $e->getMessage(),
                'mode' => 'online'
            ];
        }
    }

    /**
     * Offline Authentication (Cached Tokens)
     */
    private function authenticateOffline($username, $password) {
        $tokenFile = $this->tokenDir . $username . '.token';

        if (!file_exists($tokenFile)) {
            // Try hardcoded fallback credentials (for emergency access)
            if ($username === 'admin' && $password === 'password123') {
                $token = $this->generateToken($username);
                return [
                    'success' => true,
                    'message' => 'Authenticated offline (fallback)',
                    'mode' => 'offline',
                    'token' => $token,
                    'user' => [
                        'id' => 0,
                        'username' => 'admin',
                        'email' => 'admin@ics-system.local',
                        'role' => 'admin'
                    ]
                ];
            }

            return [
                'success' => false,
                'message' => 'No offline credentials available. System is offline.',
                'mode' => 'offline'
            ];
        }

        // Load cached token
        $tokenData = json_decode(file_get_contents($tokenFile), true);

        // Check token expiry
        if (time() > $tokenData['expiry']) {
            unlink($tokenFile);
            return [
                'success' => false,
                'message' => 'Cached credentials expired',
                'mode' => 'offline'
            ];
        }

        // Verify password matches cached hash
        if (!password_verify($password, $tokenData['password_hash'])) {
            return [
                'success' => false,
                'message' => 'Invalid password',
                'mode' => 'offline'
            ];
        }

        return [
            'success' => true,
            'message' => 'Authenticated offline (cached)',
            'mode' => 'offline',
            'token' => $tokenData['token'],
            'user' => $tokenData['user']
        ];
    }

    /**
     * Cache User Token for Offline Use
     */
    private function cacheToken($username, $token) {
        $tokenData = [
            'username' => $username,
            'token' => $token,
            'password_hash' => password_hash($_POST['password'] ?? 'cached', PASSWORD_BCRYPT),
            'created' => time(),
            'expiry' => time() + $this->tokenExpiry,
            'user' => [
                'username' => $username,
                'role' => 'user'
            ]
        ];

        $tokenFile = $this->tokenDir . $username . '.token';
        file_put_contents($tokenFile, json_encode($tokenData, JSON_PRETTY_PRINT));
    }

    /**
     * Generate Authentication Token
     */
    private function generateToken($username) {
        $token = bin2hex(random_bytes(32));
        $sessionData = [
            'username' => $username,
            'token' => $token,
            'issued' => time(),
            'expiry' => time() + (24 * 3600) // 24 hour session
        ];

        file_put_contents(
            $this->tokenDir . $token . '.session',
            json_encode($sessionData)
        );

        return $token;
    }

    /**
     * Verify Token
     */
    public function verifyToken($token) {
        $sessionFile = $this->tokenDir . $token . '.session';

        if (!file_exists($sessionFile)) {
            return false;
        }

        $sessionData = json_decode(file_get_contents($sessionFile), true);

        if (time() > $sessionData['expiry']) {
            unlink($sessionFile);
            return false;
        }

        return $sessionData;
    }

    /**
     * Destroy Token (Logout)
     */
    public function logout($token) {
        $sessionFile = $this->tokenDir . $token . '.session';
        if (file_exists($sessionFile)) {
            unlink($sessionFile);
        }
        return true;
    }

    /**
     * Get System Status
     */
    public function getStatus() {
        return [
            'online' => $this->isOnline,
            'mode' => $this->isOnline ? 'online' : 'offline',
            'cached_users' => count(glob($this->tokenDir . '*.token')),
            'active_sessions' => count(glob($this->tokenDir . '*.session'))
        ];
    }

    /**
     * Create User (requires database)
     */
    public function createUser($username, $email, $password, $role = 'user') {
        if (!$this->isOnline || $this->db === null) {
            return [
                'success' => false,
                'message' => 'System offline. Cannot create new users.'
            ];
        }

        try {
            $passwordHash = password_hash($password, PASSWORD_BCRYPT);
            
            $query = "INSERT INTO users (username, email, password_hash, role, created_at) VALUES (?, ?, ?, ?, NOW())";
            $stmt = $this->db->prepare($query);
            
            if (!$stmt) {
                throw new \Exception("Database query prepare failed: " . $this->db->error);
            }

            $stmt->bind_param("ssss", $username, $email, $passwordHash, $role);
            $stmt->execute();

            $stmt->close();

            return [
                'success' => true,
                'message' => 'User created successfully'
            ];
        } catch (\Exception $e) {
            return [
                'success' => false,
                'message' => 'Failed to create user: ' . $e->getMessage()
            ];
        }
    }
}
?>
