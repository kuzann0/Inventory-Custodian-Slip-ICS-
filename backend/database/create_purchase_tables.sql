-- Create purchase_requests table
CREATE TABLE IF NOT EXISTS purchase_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pr_no VARCHAR(100) NOT NULL UNIQUE,
    item_name VARCHAR(100),
    description TEXT,
    quantity INT NOT NULL,
    unit VARCHAR(50),
    unit_cost DECIMAL(12, 2),
    total_amount DECIMAL(12, 2),
    office VARCHAR(100),
    division_section VARCHAR(100),
    date_requested DATE DEFAULT NULL,
    status VARCHAR(50) DEFAULT 'draft',
    form_type VARCHAR(50),
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- Create workflow_history table
CREATE TABLE IF NOT EXISTS workflow_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pr_id INT NOT NULL,
    status_to VARCHAR(50),
    action_by INT,
    action_type VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (pr_id) REFERENCES purchase_requests(id),
    FOREIGN KEY (action_by) REFERENCES users(id)
);
