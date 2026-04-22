<?php
/**
 * Permission Validator Class
 * 
 * Centralized validation for all capability-based operations
 * Ensures strict hierarchy and permission checks
 * 
 * File: backend/lib/PermissionValidator.php
 */

class PermissionValidator {
    private $conn;
    private $userId;
    private $userRoleId;
    private $userCapabilities = [];
    private $userCapabilityIds = [];
    
    public function __construct($conn, $userId) {
        $this->conn = $conn;
        $this->userId = $userId;
        $this->loadUserInfo();
    }
    
    /**
     * Load user's role and capabilities from database
     */
    private function loadUserInfo() {
        try {
            $stmt = $this->conn->prepare(
                "SELECT u.role_id FROM users u WHERE u.id = ?"
            );
            $stmt->bind_param('i', $this->userId);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows === 0) {
                throw new Exception('User not found');
            }
            
            $userRow = $result->fetch_assoc();
            $this->userRoleId = $userRow['role_id'];
            $stmt->close();
            
            // Load user's capabilities
            $capStmt = $this->conn->prepare(
                "SELECT c.id, c.capability_key FROM user_capabilities uc
                 JOIN capabilities c ON uc.capability_id = c.id
                 WHERE uc.user_id = ? AND uc.expires_at IS NULL
                 AND (uc.expires_at IS NULL OR uc.expires_at > NOW())"
            );
            $capStmt->bind_param('i', $this->userId);
            $capStmt->execute();
            $capResult = $capStmt->get_result();
            
            while ($cap = $capResult->fetch_assoc()) {
                $this->userCapabilities[] = $cap['capability_key'];
                $this->userCapabilityIds[$cap['capability_key']] = $cap['id'];
            }
            $capStmt->close();
            
        } catch (Exception $e) {
            throw new Exception('Failed to load user info: ' . $e->getMessage());
        }
    }
    
    /**
     * Check if user has specific capability
     * 
     * @param string $capabilityKey e.g., 'edit_admin_caps'
     * @return bool
     */
    public function hasCapability($capabilityKey) {
        return in_array($capabilityKey, $this->userCapabilities);
    }
    
    /**
     * Require specific capability or throw exception
     * 
     * @param string $capabilityKey
     * @throws Exception
     */
    public function requireCapability($capabilityKey) {
        if (!$this->hasCapability($capabilityKey)) {
            throw new Exception("Missing required capability: $capabilityKey");
        }
        return $this;
    }
    
    /**
     * Check if user's role level meets minimum
     * 
     * @param int $minRoleId 1=SuperAdmin, 2=Admin, 3=Employee
     * @return bool
     */
    public function hasMinimumRole($minRoleId) {
        // Lower role_id = higher privilege
        // SuperAdmin(1) >= Admin(2) >= Employee(3)
        return $this->userRoleId <= $minRoleId;
    }
    
    /**
     * Require minimum role or throw exception
     * 
     * @param int $minRoleId
     * @throws Exception
     */
    public function requireMinimumRole($minRoleId) {
        if (!$this->hasMinimumRole($minRoleId)) {
            throw new Exception("Insufficient role level (requires role_id <= $minRoleId)");
        }
        return $this;
    }
    
    /**
     * Get user's role level
     * 
     * @return int role_id
     */
    public function getRoleId() {
        return $this->userRoleId;
    }
    
    /**
     * Get user's capabilities list
     * 
     * @return array capability keys
     */
    public function getCapabilities() {
        return $this->userCapabilities;
    }
    
    /**
     * Validate hierarchy: Can actor manage target?
     * 
     * Hierarchy rules:
     * - SuperAdmin (1) can manage: Admin (2), Employee (3)
     * - Admin (2) can manage: Employee (3) only
     * - Employee (3) cannot manage anyone
     * 
     * @param int $targetRoleId
     * @return bool
     */
    public function canManageRole($targetRoleId) {
        if ($this->userRoleId === 1) {
            // SuperAdmin can manage Admin and Employee
            return $targetRoleId >= 2;
        }
        if ($this->userRoleId === 2) {
            // Admin can manage Employee only
            return $targetRoleId === 3;
        }
        // Employee cannot manage anyone
        return false;
    }
    
    /**
     * Get target user's info with validation
     * 
     * @param int $targetUserId
     * @param string $action What action is being attempted
     * @return array target user info
     * @throws Exception if validation fails
     */
    public function validateTarget($targetUserId, $action = 'edit') {
        // Cannot manage yourself
        if ($targetUserId === $this->userId) {
            throw new Exception('Cannot ' . $action . ' your own capabilities');
        }
        
        // Check target exists
        $stmt = $this->conn->prepare(
            "SELECT id, username, role_id FROM users WHERE id = ?"
        );
        $stmt->bind_param('i', $targetUserId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            throw new Exception('Target user not found');
        }
        
        $target = $result->fetch_assoc();
        $stmt->close();
        
        // Check hierarchy
        if (!$this->canManageRole($target['role_id'])) {
            throw new Exception(
                'Insufficient privilege to manage this user (target role_id: ' . 
                $target['role_id'] . ')'
            );
        }
        
        return $target;
    }
    
    /**
     * Check if capability can be granted to specific role
     * 
     * @param int $capabilityId
     * @param int $targetRoleId
     * @return bool
     */
    public function canGrantCapability($capabilityId, $targetRoleId) {
        // Get capability's required role level
        $stmt = $this->conn->prepare(
            "SELECT required_role_id FROM capabilities WHERE id = ?"
        );
        $stmt->bind_param('i', $capabilityId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            throw new Exception('Capability not found');
        }
        
        $requiredRoleId = $result->fetch_assoc()['required_role_id'];
        $stmt->close();
        
        // Target role must be at same level or higher privilege (lower role_id)
        return $targetRoleId <= $requiredRoleId;
    }
    
    /**
     * Get capability info by ID
     * 
     * @param int $capabilityId
     * @return array capability info
     */
    public function getCapabilityInfo($capabilityId) {
        $stmt = $this->conn->prepare(
            "SELECT id, capability_key, category, description, required_role_id 
             FROM capabilities WHERE id = ?"
        );
        $stmt->bind_param('i', $capabilityId);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows === 0) {
            return null;
        }
        
        return $result->fetch_assoc();
    }
    
    /**
     * Check if admin can grant this specific capability
     * (combines role hierarchy + capability requirements)
     * 
     * @param int $capabilityId
     * @param int $targetRoleId
     * @throws Exception
     */
    public function validateCapabilityGrant($capabilityId, $targetRoleId) {
        $capInfo = $this->getCapabilityInfo($capabilityId);
        
        if (!$capInfo) {
            throw new Exception('Capability not found');
        }
        
        // Can user grant capabilities at this level?
        if ($this->userRoleId === 2) {  // Admin
            // Admin cannot grant SuperAdmin-only capabilities
            if ($capInfo['required_role_id'] < 2) {
                throw new Exception(
                    'You cannot grant SuperAdmin-level capabilities ' .
                    '(capability requires role_id <= ' . $capInfo['required_role_id'] . ')'
                );
            }
        }
        
        // Can target role receive this capability?
        if (!$this->canGrantCapability($capabilityId, $targetRoleId)) {
            throw new Exception(
                'Target role ' . $targetRoleId . ' cannot have capability ' .
                $capInfo['capability_key'] . ' (requires role_id <= ' . 
                $capInfo['required_role_id'] . ')'
            );
        }
    }
    
    /**
     * Validate = Run all common checks
     * Shorthand for most operations
     * 
     * @param string|array $requiredCapabilities
     * @param int $minRoleId Optional minimum role
     * @return bool
     * @throws Exception
     */
    public function validate($requiredCapabilities = [], $minRoleId = null) {
        if (is_string($requiredCapabilities)) {
            $requiredCapabilities = [$requiredCapabilities];
        }
        
        // Check each required capability
        foreach ($requiredCapabilities as $cap) {
            $this->requireCapability($cap);
        }
        
        // Check minimum role if specified
        if ($minRoleId !== null) {
            $this->requireMinimumRole($minRoleId);
        }
        
        return true;
    }
}
?>
