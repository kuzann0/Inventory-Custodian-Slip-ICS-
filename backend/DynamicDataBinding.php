<?php
/**
 * DYNAMIC DATA BINDING CONFIGURATION
 * 
 * This file provides the centralized data binding layer for the purchase request workflow.
 * It maps all workflow steps to the entries table, ensuring single source of truth.
 * 
 * Workflow Steps (1-5):
 * - Step 1: Purchase Request (entry_step_1) -> entries table
 * - Step 2: Approval (entry_step_2) -> entries + approval metadata
 * - Step 3: Notice of Delivery (entry_step_3) -> entries + delivery metadata
 * - Step 4: Inspection & Acceptance (entry_step_4) -> entries + inspection metadata
 * - Step 5: Conditional Form (entry_step_5) -> ICS (Total < 50k) or PPE (Total >= 50k)
 * 
 * All data is now centrally managed through the entries table with workflow status tracking
 * in the entry_workflow_status table.
 */

class DynamicDataBinding {
    
    private $conn;
    private $db_name;
    
    /**
     * Initialize binding with database connection
     */
    public function __construct($mysqli_connection) {
        $this->conn = $mysqli_connection;
        $this->db_name = getenv('MYSQL_DATABASE') ?: 'my_app_db';
    }
    
    /**
     * Create a new workflow entry (Step 1)
     * Central point for purchase request creation
     * 
     * @param array $data - PR data from form
     * @param int $user_id - Creating user ID
     * @return array - Entry with entry_id and pr_id reference
     */
    public function createWorkflowEntry($data, $user_id) {
        try {
            // Start transaction
            $this->conn->begin_transaction();
            
            // Step 1: Create entry in entries table (single source of truth)
            $entry_sql = "
                INSERT INTO entries (
                    Quantity,
                    Unit,
                    UnitCost,
                    TotalCost,
                    Description,
                    Item,
                    Location,
                    SerialNo,
                    InventoryItemNo,
                    EstimatedUsefulLife,
                    DateAcquired
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
            ";
            
            $stmt = $this->conn->prepare($entry_sql);
            if (!$stmt) {
                throw new Exception('Prepare failed: ' . $this->conn->error);
            }
            
            // Calculate total cost
            $quantity = (int)$data['quantity'];
            $unit_cost = (float)$data['unit_cost'];
            $total_cost = $quantity * $unit_cost;
            $unit = $data['unit'];
            $description = $data['description'] ?? '';
            $item_name = $data['item_name'];
            $office = $data['office'];
            $serial_no = $data['serial_no'] ?? null;
            $inventory_item_no = $data['inventory_item_no'] ?? null;
            $estimated_useful_life = $data['estimated_useful_life'] ?? null;
            
            $stmt->bind_param(
                'isddssssss',
                $quantity,
                $unit,
                $unit_cost,
                $total_cost,
                $description,
                $item_name,
                $office,
                $serial_no,
                $inventory_item_no,
                $estimated_useful_life
            );
            
            if (!$stmt->execute()) {
                throw new Exception('Failed to create entry: ' . $stmt->error);
            }
            
            $entry_id = $stmt->insert_id;
            $stmt->close();
            
            // Step 2: Create workflow tracking record
            $workflow_sql = "
                INSERT INTO entry_workflow_status (
                    entry_id,
                    pr_no,
                    step_1_completed,
                    step_1_data,
                    step_1_user_id,
                    current_step,
                    pr_id,
                    created_by
                ) VALUES (?, ?, 1, ?, ?, 1, NULL, ?)
            ";
            
            $stmt = $this->conn->prepare($workflow_sql);
            $step_1_data = json_encode($data);
            
            $stmt->bind_param(
                'issii',
                $entry_id,
                $data['pr_no'],
                $step_1_data,
                $user_id,
                $user_id
            );
            
            if (!$stmt->execute()) {
                throw new Exception('Failed to create workflow tracking: ' . $stmt->error);
            }
            
            $workflow_id = $stmt->insert_id;
            $stmt->close();
            
            // Step 3: Create purchase_requests record (for backward compatibility)
            $form_type = $total_cost >= 50000 ? 'ppe' : 'ics';
            
            $pr_sql = "
                INSERT INTO purchase_requests (
                    pr_no,
                    description,
                    item_name,
                    office,
                    division_section,
                    quantity,
                    unit,
                    unit_cost,
                    total_amount,
                    form_type,
                    created_by,
                    status
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'draft')
            ";
            
            $stmt = $this->conn->prepare($pr_sql);
            $stmt->bind_param(
                'sssssisdsi',
                $data['pr_no'],
                $description,
                $item_name,
                $office,
                $data['division_section'],
                $quantity,
                $unit,
                $unit_cost,
                $total_cost,
                $form_type,
                $user_id
            );
            
            if (!$stmt->execute()) {
                throw new Exception('Failed to create PR: ' . $stmt->error);
            }
            
            $pr_id = $stmt->insert_id;
            $stmt->close();
            
            // Update workflow tracking with pr_id
            $update_sql = "UPDATE entry_workflow_status SET pr_id = ? WHERE id = ?";
            $stmt = $this->conn->prepare($update_sql);
            $stmt->bind_param('ii', $pr_id, $workflow_id);
            $stmt->execute();
            $stmt->close();
            
            // Commit transaction
            $this->conn->commit();
            
            return [
                'success' => true,
                'entry_id' => $entry_id,
                'pr_id' => $pr_id,
                'pr_no' => $data['pr_no'],
                'workflow_id' => $workflow_id,
                'form_type' => $form_type,
                'total_cost' => $total_cost,
                'message' => 'Workflow entry created successfully'
            ];
            
        } catch (Exception $e) {
            $this->conn->rollback();
            throw $e;
        }
    }
    
    /**
     * Get complete workflow entry data (dynamic binding retrieval)
     * 
     * @param int $pr_id - Purchase Request ID
     * @return array - Complete entry with all workflow steps
     */
    public function getWorkflowEntry($pr_id) {
        try {
            // Fetch from entries table (single source of truth)
            $sql = "
                SELECT 
                    e.*,
                    ws.id as workflow_id,
                    ws.pr_no,
                    ws.current_step,
                    ws.step_1_completed,
                    ws.step_2_completed,
                    ws.step_3_completed,
                    ws.step_4_completed,
                    ws.step_5_completed,
                    ws.step_1_data,
                    ws.step_2_data,
                    ws.step_3_data,
                    ws.step_4_data,
                    ws.step_5_data,
                    pr.status,
                    pr.form_type,
                    pr.approval_date,
                    pr.approved_by,
                    pr.approval_notes,
                    pr.delivery_notes,
                    pr.actual_delivery_date,
                    pr.inspection_notes,
                    pr.inspection_date,
                    pr.inspected_by
                FROM entries e
                LEFT JOIN workflow_status ws ON e.order_id = ws.entry_id
                LEFT JOIN purchase_requests pr ON ws.pr_id = pr.id
                WHERE ws.pr_id = ? OR pr.id = ?
            ";
            
            $stmt = $this->conn->prepare($sql);
            if (!$stmt) {
                throw new Exception('SQL Prepare Error: ' . $this->conn->error);
            }
            $stmt->bind_param('ii', $pr_id, $pr_id);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows === 0) {
                throw new Exception('Workflow entry not found');
            }
            
            $entry = $result->fetch_assoc();
            $stmt->close();
            
            // Parse JSON fields
            if ($entry['step_1_data']) $entry['step_1_data'] = json_decode($entry['step_1_data'], true);
            if ($entry['step_2_data']) $entry['step_2_data'] = json_decode($entry['step_2_data'], true);
            if ($entry['step_3_data']) $entry['step_3_data'] = json_decode($entry['step_3_data'], true);
            if ($entry['step_4_data']) $entry['step_4_data'] = json_decode($entry['step_4_data'], true);
            if ($entry['step_5_data']) $entry['step_5_data'] = json_decode($entry['step_5_data'], true);
            
            return $entry;
            
        } catch (Exception $e) {
            throw $e;
        }
    }
    
    /**
     * Update workflow step (handles all steps 2-5)
     * Centralizes all step-specific updates
     * 
     * @param int $pr_id - Purchase Request ID
     * @param int $step - Step number (2-5)
     * @param array $data - Step data
     * @param int $user_id - User performing update
     * @return array - Update result
     */
    public function updateWorkflowStep($pr_id, $step, $data, $user_id) {
        try {
            $this->conn->begin_transaction();
            
            // Validate step
            if ($step < 2 || $step > 5) {
                throw new Exception('Invalid step number');
            }
            
            // Get current workflow status
            $workflow_sql = "SELECT * FROM entry_workflow_status WHERE pr_id = ?";
            $stmt = $this->conn->prepare($workflow_sql);
            $stmt->bind_param('i', $pr_id);
            $stmt->execute();
            $workflow = $stmt->get_result()->fetch_assoc();
            $stmt->close();
            
            if (!$workflow) {
                throw new Exception('Workflow not found');
            }
            
            // Update entries table with step data
            $entry_id = $workflow['entry_id'];
            $step_data = json_encode($data);
            
            // Determine which columns to update based on step
            switch ($step) {
                case 2: // Approval Step
                    $this->updateEntryApprovalData($entry_id, $data);
                    $step_col = 'step_2_completed';
                    $data_col = 'step_2_data';
                    break;
                case 3: // Notice of Delivery
                    $this->updateEntryDeliveryData($entry_id, $data);
                    $step_col = 'step_3_completed';
                    $data_col = 'step_3_data';
                    break;
                case 4: // Inspection & Acceptance
                    $this->updateEntryInspectionData($entry_id, $data);
                    $step_col = 'step_4_completed';
                    $data_col = 'step_4_data';
                    break;
                case 5: // Conditional Form (ICS/PPE)
                    $this->updateEntryFormData($entry_id, $data);
                    $step_col = 'step_5_completed';
                    $data_col = 'step_5_data';
                    break;
            }
            
            // Update workflow status
            $status_sql = "UPDATE entry_workflow_status SET $step_col = 1, $data_col = ?, current_step = ? WHERE pr_id = ?";
            $stmt = $this->conn->prepare($status_sql);
            $stmt->bind_param('sii', $step_data, $step, $pr_id);
            
            if (!$stmt->execute()) {
                throw new Exception('Failed to update workflow step: ' . $stmt->error);
            }
            $stmt->close();
            
            // Update purchase_requests for backward compatibility
            $this->updatePRStatus($pr_id, $step, $data, $user_id);
            
            $this->conn->commit();
            
            return [
                'success' => true,
                'pr_id' => $pr_id,
                'step' => $step,
                'message' => "Step $step completed successfully"
            ];
            
        } catch (Exception $e) {
            $this->conn->rollback();
            throw $e;
        }
    }
    
    /**
     * Helper: Update entry approval data (Step 2)
     */
    private function updateEntryApprovalData($entry_id, $data) {
        $sql = "
            UPDATE entries SET
                Amount = ?,
                ApprovalStatus = 'approved',
                ApprovedBy = ?,
                ApprovedDate = NOW()
            WHERE order_id = ?
        ";
        
        $stmt = $this->conn->prepare($sql);
        if (!$stmt) return;
        
        $amount = $data['amount'] ?? null;
        $approved_by = $data['approved_by'] ?? null;
        
        $stmt->bind_param('dii', $amount, $approved_by, $entry_id);
        $stmt->execute();
        $stmt->close();
    }
    
    /**
     * Helper: Update entry delivery data (Step 3)
     */
    private function updateEntryDeliveryData($entry_id, $data) {
        $sql = "
            UPDATE entries SET
                DeliveryNotes = ?,
                DeliveryDate = ?,
                DeliveryStatus = 'delivered'
            WHERE order_id = ?
        ";
        
        $stmt = $this->conn->prepare($sql);
        if (!$stmt) return;
        
        $notes = $data['delivery_notes'] ?? null;
        $date = $data['delivery_date'] ?? null;
        
        $stmt->bind_param('ssi', $notes, $date, $entry_id);
        $stmt->execute();
        $stmt->close();
    }
    
    /**
     * Helper: Update entry inspection data (Step 4)
     */
    private function updateEntryInspectionData($entry_id, $data) {
        $sql = "
            UPDATE entries SET
                InspectionNotes = ?,
                InspectionDate = NOW(),
                InspectionStatus = ?,
                InspectedBy = ?
            WHERE order_id = ?
        ";
        
        $stmt = $this->conn->prepare($sql);
        if (!$stmt) return;
        
        $notes = $data['inspection_notes'] ?? null;
        $status = $data['inspection_status'] ?? 'inspected';
        $inspected_by = $data['inspected_by'] ?? null;
        
        $stmt->bind_param('ssii', $notes, $status, $inspected_by, $entry_id);
        $stmt->execute();
        $stmt->close();
    }
    
    /**
     * Helper: Update entry form data (Step 5 - ICS/PPE)
     */
    private function updateEntryFormData($entry_id, $data) {
        $sql = "
            UPDATE entries SET
                FormType = ?,
                FormData = ?,
                FormSubmitDate = NOW(),
                FormStatus = 'completed'
            WHERE order_id = ?
        ";
        
        $stmt = $this->conn->prepare($sql);
        if (!$stmt) return;
        
        $form_type = $data['form_type'] ?? 'ics';
        $form_data = json_encode($data);
        
        $stmt->bind_param('ssi', $form_type, $form_data, $entry_id);
        $stmt->execute();
        $stmt->close();
    }
    
    /**
     * Helper: Update purchase_requests for backward compatibility
     */
    private function updatePRStatus($pr_id, $step, $data, $user_id) {
        switch ($step) {
            case 2: // Approval
                $status = 'approved';
                $sql = "UPDATE purchase_requests SET status = ?, approved_by = ?, approval_date = NOW(), approval_notes = ? WHERE id = ?";
                $stmt = $this->conn->prepare($sql);
                $notes = $data['approval_notes'] ?? '';
                $stmt->bind_param('sisi', $status, $user_id, $notes, $pr_id);
                break;
                
            case 3: // Delivery
                $status = 'in_delivery';
                $sql = "UPDATE purchase_requests SET status = ?, delivery_notes = ?, actual_delivery_date = ? WHERE id = ?";
                $stmt = $this->conn->prepare($sql);
                $notes = $data['delivery_notes'] ?? '';
                $date = $data['delivery_date'] ?? null;
                $stmt->bind_param('sssi', $status, $notes, $date, $pr_id);
                break;
                
            case 4: // Inspection
                $status = 'inspected';
                $sql = "UPDATE purchase_requests SET status = ?, inspection_notes = ?, inspection_date = NOW(), inspected_by = ? WHERE id = ?";
                $stmt = $this->conn->prepare($sql);
                $notes = $data['inspection_notes'] ?? '';
                $stmt->bind_param('ssii', $status, $notes, $user_id, $pr_id);
                break;
                
            case 5: // Conditional Form
                $status = 'completed';
                $sql = "UPDATE purchase_requests SET status = ?, form_type = ? WHERE id = ?";
                $stmt = $this->conn->prepare($sql);
                $form_type = $data['form_type'] ?? 'ics';
                $stmt->bind_param('ssi', $status, $form_type, $pr_id);
                break;
        }
        
        if (isset($stmt)) {
            $stmt->execute();
            $stmt->close();
        }
    }
    
    /**
     * Get all workflow entries with dynamic binding
     */
    public function getAllWorkflowEntries($filters = []) {
        try {
            $sql = "
                SELECT 
                    e.order_id,
                    e.Item,
                    e.Quantity,
                    e.Unit,
                    e.UnitCost,
                    e.TotalCost,
                    e.Location,
                    e.SerialNo,
                    e.InventoryItemNo,
                    e.EstimatedUsefulLife,
                    e.DateAcquired,
                    ews.pr_no,
                    ews.current_step,
                    pr.id as pr_id,
                    pr.status,
                    pr.form_type,
                    pr.created_at
                FROM entries e
                LEFT JOIN entry_workflow_status ews ON e.order_id = ews.entry_id
                LEFT JOIN purchase_requests pr ON ews.pr_id = pr.id
                WHERE 1=1
            ";
            
            // Apply filters
            if (isset($filters['status'])) {
                $sql .= " AND pr.status = ?";
            }
            if (isset($filters['form_type'])) {
                $sql .= " AND pr.form_type = ?";
            }
            
            $sql .= " ORDER BY e.order_id DESC";
            
            $stmt = $this->conn->prepare($sql);
            
            $bind_types = '';
            $bind_values = [];
            
            if (isset($filters['status'])) {
                $bind_types .= 's';
                $bind_values[] = $filters['status'];
            }
            if (isset($filters['form_type'])) {
                $bind_types .= 's';
                $bind_values[] = $filters['form_type'];
            }
            
            if ($bind_types) {
                $stmt->bind_param($bind_types, ...$bind_values);
            }
            
            $stmt->execute();
            $result = $stmt->get_result();
            $entries = [];
            
            while ($row = $result->fetch_assoc()) {
                $entries[] = $row;
            }
            
            $stmt->close();
            return $entries;
            
        } catch (Exception $e) {
            throw $e;
        }
    }
}

?>
