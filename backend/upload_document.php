<?php
/**
 * Upload document
 */

header('Content-Type: application/json; charset=UTF-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

try {
    $pr_no = $_POST['pr_no'] ?? '';
    $document_type = $_POST['document_type'] ?? 'other';
    
    if (!$pr_no || !isset($_FILES['file'])) {
        throw new Exception('PR number and file are required');
    }

    // Create documents directory if it doesn't exist
    $upload_dir = '/var/www/html/documents/';
    if (!is_dir($upload_dir)) {
        mkdir($upload_dir, 0755, true);
    }

    $file = $_FILES['file'];
    $filename = basename($file['name']);
    $file_ext = pathinfo($filename, PATHINFO_EXTENSION);
    
    // Validate file type
    $allowed_extensions = ['pdf', 'doc', 'docx', 'xlsx', 'jpg', 'png'];
    if (!in_array(strtolower($file_ext), $allowed_extensions)) {
        throw new Exception('File type not allowed');
    }

    // Generate unique filename
    $unique_filename = $pr_no . '_' . time() . '.' . $file_ext;
    $upload_path = $upload_dir . $unique_filename;

    if (!move_uploaded_file($file['tmp_name'], $upload_path)) {
        throw new Exception('Failed to upload file');
    }

    // Store in database
    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    // Create documents table if it doesn't exist
    $create_table = "
    CREATE TABLE IF NOT EXISTS documents (
        id INT AUTO_INCREMENT PRIMARY KEY,
        pr_no VARCHAR(100),
        document_type VARCHAR(50),
        filename VARCHAR(255),
        file_path VARCHAR(255),
        uploaded_by VARCHAR(100),
        upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        verified BOOLEAN DEFAULT FALSE,
        verified_by VARCHAR(100),
        verified_at TIMESTAMP NULL
    )
    ";

    $conn->query($create_table);

    $user = $_POST['uploaded_by'] ?? 'system';
    
    $stmt = $conn->prepare("
        INSERT INTO documents 
        (pr_no, document_type, filename, file_path, uploaded_by)
        VALUES (?, ?, ?, ?, ?)
    ");

    $stmt->bind_param('sssss', $pr_no, $document_type, $filename, $unique_filename, $user);

    if (!$stmt->execute()) {
        throw new Exception('Failed to record document: ' . $stmt->error);
    }

    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => 'Document uploaded successfully',
        'filename' => $filename
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
