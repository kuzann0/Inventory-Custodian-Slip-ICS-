<?php
require_once 'config/cors.php';
session_start();

use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Spreadsheet;

// Get PR data from POST (sent from frontend)
$prData = json_decode(file_get_contents('php://input'), true);
if (!$prData) {
    die('No data received');
}

// Load template
// $templatePath = __DIR__ . '/templates/pr_form_template.xlsx';
// $spreadsheet = IOFactory::load($templatePath);
// $sheet = $spreadsheet->getActiveSheet();

// // Insert data into specific cells 
// $sheet->setCellValue('B9', $prData['office'] ?? '');
// $sheet->setCellValue('C10', $prData['division_section'] ?? '');
// $sheet->setCellValue('C11', $prData['date_requested'] ?? '');
// $sheet->setCellValue('H9', $prData['pr_no'] ?? '');
// the rest if this works


// Might be useful for future reference
// explore more, maybe we can use the excel's micro data entry


// Output to browser
header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment; filename="PR_Form_' . $prData['pr_no'] . '.xlsx"');
$writer = IOFactory::createWriter($spreadsheet, 'Xlsx');
$writer->save('php://output');
exit;