<?php
/**
 * Create Purchase Request Workflow Tables
 * Includes: purchase_requests, documents, property_inventory, workflow_history
 */

header('Content-Type: application/json');

try {
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');

    if ($conn->connect_error) {
        throw new Exception('Database connection failed: ' . $conn->connect_error);
    }

    // =====================================
    // 1. Create purchase_requests table
    // =====================================
    $createPRSQL = "
    CREATE TABLE IF NOT EXISTS purchase_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pr_no VARCHAR(100) UNIQUE NOT NULL,
        description TEXT NOT NULL,
        item_name VARCHAR(255),
        office VARCHAR(100),
        division_section VARCHAR(100),
        quantity INT,
        unit VARCHAR(50),
        unit_cost DECIMAL(10,2),
        total_amount DECIMAL(10,2),
        
        -- Workflow Status
        status ENUM('draft','pending_approval','approved','rejected','in_delivery','delivered','inspected','completed') DEFAULT 'draft',
        
        -- Approval Info
        approval_date TIMESTAMP NULL,
        approved_by INT,
        approval_notes TEXT,
        rejected_by INT,
        rejection_reason TEXT,
        
        -- Delivery Info
        delivery_notes TEXT,
        expected_delivery_date DATE,
        actual_delivery_date DATE,
        
        -- Inspection Info
        inspection_notes TEXT,
        inspection_date TIMESTAMP NULL,
        inspected_by INT,
        
        -- Form Type (ICS < 50K or PPE >= 50K)
        form_type ENUM('ics','ppe','none'),
        
        -- Audit
        created_by INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        
        -- Foreign Keys
        FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (rejected_by) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (inspected_by) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
        
        -- Indexes
        INDEX idx_status (status),
        INDEX idx_pr_no (pr_no),
        INDEX idx_office (office),
        INDEX idx_created_at (created_at),
        INDEX idx_approved_by (approved_by)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createPRSQL)) {
        throw new Exception('Failed to create purchase_requests table: ' . $conn->error);
    }
    echo "✓ purchase_requests table created/verified\n";

    // =====================================
    // 2. Create workflow_history table
    // =====================================
    $createHistorySQL = "
    CREATE TABLE IF NOT EXISTS workflow_history (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pr_id INT NOT NULL,
        status_from VARCHAR(50),
        status_to VARCHAR(50) NOT NULL,
        action_by INT,
        action_type VARCHAR(100),
        notes TEXT,
        ip_address VARCHAR(45),
        action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
        FOREIGN KEY (action_by) REFERENCES users(id) ON DELETE SET NULL,
        
        INDEX idx_pr_id (pr_id),
        INDEX idx_status_to (status_to),
        INDEX idx_action_date (action_date)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createHistorySQL)) {
        throw new Exception('Failed to create workflow_history table: ' . $conn->error);
    }
    echo "✓ workflow_history table created/verified\n";

    // =====================================
    // 3. Create documents table
    // =====================================
    $createDocsSQL = "
    CREATE TABLE IF NOT EXISTS documents (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pr_id INT NOT NULL,
        pr_no VARCHAR(100),
        document_type VARCHAR(50),
        filename VARCHAR(255),
        file_path VARCHAR(255),
        file_size INT,
        uploaded_by INT,
        upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        verified BOOLEAN DEFAULT FALSE,
        verified_by INT,
        verified_at TIMESTAMP NULL,
        
        FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
        FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL,
        
        INDEX idx_pr_id (pr_id),
        INDEX idx_document_type (document_type),
        INDEX idx_upload_date (upload_date)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createDocsSQL)) {
        throw new Exception('Failed to create documents table: ' . $conn->error);
    }
    echo "✓ documents table created/verified\n";

    // =====================================
    // 4. Create property_inventory table
    // =====================================
    $createPropertySQL = "
    CREATE TABLE IF NOT EXISTS property_inventory (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pr_id INT,
        pr_no VARCHAR(100),
        property_number VARCHAR(100) UNIQUE NOT NULL,
        model_number VARCHAR(100),
        description TEXT,
        serial_number VARCHAR(100),
        unit_of_measure VARCHAR(50),
        acquisition_date DATE,
        supplier VARCHAR(255),
        estimated_cost DECIMAL(10,2),
        location VARCHAR(255),
        status ENUM('serviceable','under_repair','obsolete','for_disposal') DEFAULT 'serviceable',
        
        deprecated_value DECIMAL(10,2),
        depreciation_percentage DECIMAL(5,2),
        last_maintenance_date DATE,
        assigned_to INT,
        
        created_by INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        
        FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE SET NULL,
        FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
        
        INDEX idx_property_number (property_number),
        INDEX idx_pr_no (pr_no),
        INDEX idx_status (status),
        INDEX idx_location (location)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createPropertySQL)) {
        throw new Exception('Failed to create property_inventory table: ' . $conn->error);
    }
    echo "✓ property_inventory table created/verified\n";

    // =====================================
    // 5. Create approval_queue table (for multi-tier approvals)
    // =====================================
    $createApprovalSQL = "
    CREATE TABLE IF NOT EXISTS approval_queue (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pr_id INT NOT NULL,
        approval_level INT,
        required_role_id INT,
        assigned_to INT,
        is_required BOOLEAN DEFAULT TRUE,
        status ENUM('pending','approved','rejected','expired') DEFAULT 'pending',
        approved_by INT,
        approval_date TIMESTAMP NULL,
        rejection_reason TEXT,
        due_date DATE,
        
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        
        FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
        FOREIGN KEY (required_role_id) REFERENCES user_roles(id) ON DELETE SET NULL,
        FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL,
        
        INDEX idx_pr_id (pr_id),
        INDEX idx_status (status),
        INDEX idx_assigned_to (assigned_to)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createApprovalSQL)) {
        throw new Exception('Failed to create approval_queue table: ' . $conn->error);
    }
    echo "✓ approval_queue table created/verified\n";

    // =====================================
    // 6. Create inspection_assignments table
    // =====================================
    $createInspectionSQL = "
    CREATE TABLE IF NOT EXISTS inspection_assignments (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pr_id INT NOT NULL,
        assigned_to INT NOT NULL,
        status ENUM('pending','in_progress','completed','rejected') DEFAULT 'pending',
        inspection_notes TEXT,
        condition_report TEXT,
        findings JSON,
        
        assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        due_date DATE,
        completed_date TIMESTAMP NULL,
        
        attachment_count INT DEFAULT 0,
        
        FOREIGN KEY (pr_id) REFERENCES purchase_requests(id) ON DELETE CASCADE,
        FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE CASCADE,
        
        INDEX idx_pr_id (pr_id),
        INDEX idx_assigned_to (assigned_to),
        INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ";

    if (!$conn->query($createInspectionSQL)) {
        throw new Exception('Failed to create inspection_assignments table: ' . $conn->error);
    }
    echo "✓ inspection_assignments table created/verified\n";

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'All workflow tables created successfully!',
        'tables_created' => [
            'purchase_requests',
            'workflow_history',
            'documents',
            'property_inventory',
            'approval_queue',
            'inspection_assignments'
        ]
    ]);

    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
