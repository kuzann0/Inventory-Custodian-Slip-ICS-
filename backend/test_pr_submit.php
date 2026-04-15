<?php
/**
 * Test script for purchase request submission
 */

header('Content-Type: application/json');

$payload = [
    'pr_no' => 'PR-TEST-001',
    'item_name' => 'Test Item',
    'description' => 'Test Description',
    'quantity' => 10,
    'unit' => 'pieces',
    'unit_cost' => 1000,
    'office' => 'Office A',
    'division_section' => 'Section B',
    'user_id' => 1
];

echo json_encode([
    'test' => 'Checking what happens when we submit',
    'payload' => $payload,
    'json_encoded' => json_encode($payload),
    'timestamp' => date('Y-m-d H:i:s')
]);
?>
