<?php
/**
 * Download document
 */

session_start();

$origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
header('Access-Control-Allow-Origin: ' . $origin);
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

try {
    $document_id = $_GET['document_id'] ?? 0;

    if (!$document_id) {
        throw new Exception('Document ID required');
    }

    $conn = new mysqli('db', 'root', 'rootpassword', 'my_app_db');
    
    if ($conn->connect_error) {
        throw new Exception('Database connection failed');
    }

    $stmt = $conn->prepare("SELECT filename, file_path FROM documents WHERE id = ?");
    $stmt->bind_param('i', $document_id);
    
    if (!$stmt->execute()) {
        throw new Exception('Query failed');
    }

    $result = $stmt->get_result();
    $document = $result->fetch_assoc();

    if (!$document) {
       throw new Exception('Document not found');
    }

    $file_path = '/var/www/html/documents/' . $document['file_path'];

    if (!file_exists($file_path)) {
        throw new Exception('File not found on server');
    }

    // Set headers for download
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="' . $document['filename'] . '"');
    header('Content-Length: ' . filesize($file_path));

    // Stream the file
    readfile($file_path);

    $conn->close();

} catch (Exception $e) {
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
