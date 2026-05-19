-- ============================================================================
-- MIGRATION 005: Capability System & Session Management Improvements
-- ============================================================================
-- Purpose: Enhance capability expiration enforcement and session security
-- 
-- Changes:
-- - Create session_store table for explicit session tracking
-- - Add session timeout tracking
-- - Add capability expiration enforcement table
-- - Enhance user_capabilities with expiration index
--
-- Risk Level: LOW - Additive changes, non-destructive
-- Rollback: Drop new tables, remove new columns
-- ============================================================================

USE my_app_db;

-- ============================================================================
-- Step 1: Create explicit session store for tracking active sessions
-- ============================================================================
-- Purpose: Better session management and logout tracking

CREATE TABLE IF NOT EXISTS active_sessions (
  session_id VARCHAR(255) PRIMARY KEY COMMENT 'PHP session ID',
  user_id INT NOT NULL COMMENT 'FK to users table',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ip_address VARCHAR(45),
  user_agent TEXT,
  session_data JSON COMMENT 'Session state snapshot',
  is_active TINYINT(1) DEFAULT 1 COMMENT '1=active, 0=logged out',
  
  KEY idx_user_id (user_id),
  KEY idx_is_active (is_active),
  KEY idx_last_activity (last_activity),
  KEY idx_created_at (created_at),
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Explicit session store for enhanced session management';

-- ============================================================================
-- Step 2: Create session timeout configuration table
-- ============================================================================
-- Purpose: Configurable session timeouts and security policies

CREATE TABLE IF NOT EXISTS session_config (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  config_key VARCHAR(100) NOT NULL UNIQUE COMMENT 'Config key name',
  config_value VARCHAR(255) NOT NULL COMMENT 'Config value',
  description VARCHAR(255),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  KEY idx_config_key (config_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Session and security configuration';

-- Insert default session config values
INSERT IGNORE INTO session_config (config_key, config_value, description) VALUES
('session_timeout_seconds', '3600', 'Session inactivity timeout in seconds (default 1 hour)'),
('session_regenerate_on_login', '1', 'Whether to regenerate session ID on login (1=yes, 0=no)'),
('login_rate_limit_attempts', '5', 'Max failed login attempts before lockout'),
('login_rate_limit_window_seconds', '900', 'Time window for login rate limiting (15 min)'),
('login_lockout_duration_seconds', '1800', 'Duration of lockout after max attempts (30 min)'),
('password_min_length', '8', 'Minimum password length'),
('password_require_uppercase', '1', 'Require uppercase in password (1=yes)'),
('password_require_digits', '1', 'Require digits in password (1=yes)'),
('capability_expiration_enabled', '1', 'Whether capability expiration is enforced (1=yes)'),
('capability_default_duration_days', '365', 'Default capability duration in days (null = permanent)');

-- ============================================================================
-- Step 3: Enhance user_capabilities table with expiration index
-- ============================================================================
-- Purpose: Improve query performance for checking active (non-expired) capabilities

ALTER TABLE user_capabilities
ADD INDEX idx_expires_at (expires_at),
ADD INDEX idx_user_expires (user_id, expires_at);

-- ============================================================================
-- Step 4: Create capability expiration enforcement table
-- ============================================================================
-- Purpose: Track automatic capability expirations and enforcement events

CREATE TABLE IF NOT EXISTS capability_expiration_log (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_capability_id INT COMMENT 'Reference to user_capabilities that expired',
  user_id INT NOT NULL COMMENT 'FK to users table',
  capability_id INT NOT NULL COMMENT 'FK to capabilities table',
  expiration_date DATE COMMENT 'Date capability expired',
  enforced_at TIMESTAMP COMMENT 'When expiration was enforced (when detected)',
  reason ENUM('auto_expire', 'manual_revoke', 'admin_revoke') DEFAULT 'auto_expire',
  
  KEY idx_user_id (user_id),
  KEY idx_capability_id (capability_id),
  KEY idx_enforced_at (enforced_at),
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (capability_id) REFERENCES capabilities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Log of capability expirations and enforcement';

-- ============================================================================
-- Step 5: Add capability renewal and extension tracking
-- ============================================================================
-- Purpose: Track capability renewals and extensions

CREATE TABLE IF NOT EXISTS capability_renewal_log (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_capability_id INT COMMENT 'Reference to user_capabilities',
  user_id INT NOT NULL,
  capability_id INT NOT NULL,
  old_expiration_date DATE COMMENT 'Previous expiration date',
  new_expiration_date DATE COMMENT 'New expiration date after renewal',
  renewed_by INT NOT NULL COMMENT 'FK to users - admin who renewed',
  renewal_reason VARCHAR(255),
  renewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  KEY idx_user_id (user_id),
  KEY idx_renewed_at (renewed_at),
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (capability_id) REFERENCES capabilities(id) ON DELETE CASCADE,
  FOREIGN KEY (renewed_by) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Log of capability renewals and extensions';

-- ============================================================================
-- Step 6: Add session regeneration tracking
-- ============================================================================
-- Purpose: Track when sessions are regenerated for security audit

CREATE TABLE IF NOT EXISTS session_regeneration_log (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  old_session_id VARCHAR(255),
  new_session_id VARCHAR(255),
  regenerated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reason ENUM('login', 'privilege_change', 'manual_refresh') DEFAULT 'login',
  ip_address VARCHAR(45),
  
  KEY idx_user_id (user_id),
  KEY idx_regenerated_at (regenerated_at),
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Track session ID regenerations for security';

-- ============================================================================
-- Step 7: Add password change audit
-- ============================================================================
-- Purpose: Track password changes for security audit trail

CREATE TABLE IF NOT EXISTS password_change_log (
  id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  changed_by INT COMMENT 'FK to users - who changed the password (admin or self)',
  change_reason ENUM('user_request', 'admin_reset', 'expired_password', 'security_incident') 
    DEFAULT 'user_request',
  password_hash_old VARCHAR(255) COMMENT 'Hash of previous password (for detecting reuse)',
  forced_change_at TIMESTAMP NULL COMMENT 'When user must change password',
  changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ip_address VARCHAR(45),
  
  KEY idx_user_id (user_id),
  KEY idx_changed_at (changed_at),
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Track password changes for security audit';

-- ============================================================================
-- Verification Queries
-- ============================================================================
-- SELECT COUNT(*) FROM session_config;
-- SHOW COLUMNS FROM user_capabilities LIKE 'expires%';
-- SHOW KEYS FROM user_capabilities WHERE Column_name = 'expires_at';

-- ============================================================================
-- End Migration 005
-- ============================================================================
