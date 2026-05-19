<?php
// INTEGRATION: CORS + JSON error handling
require_once './config/cors.php';

// INTEGRATION: Ensure ALL output is JSON – suppress PHP notices/warnings that
// would corrupt the JSON body and trigger "Unexpected end of JSON input" on
// the frontend. Turn them off in production; log to file instead.
ini_set('display_errors', '0');
ini_set('log_errors',     '1');
// ini_set('error_log', '/var/log/php_errors.log'); // uncomment to set a custom log path
error_reporting(E_ALL);

header('Content-Type: application/json');

// ── Preflight ──────────────────────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// ── Helper: always exit with valid JSON ───────────────────────────────────────
// INTEGRATION: every error path calls this so the frontend never sees an empty
// or HTML body, which was the root cause of "Unexpected end of JSON input".
function jsonError(string $message, int $code = 500, array $debug = []): never {
    http_response_code($code);
    $payload = ['success' => false, 'error' => $message];
    if (!empty($debug)) {
        $payload['debug'] = $debug;
    }
    echo json_encode($payload);
    exit;
}

function jsonOk(array $payload): never {
    http_response_code(isset($payload['pr_id']) ? 201 : 200);
    echo json_encode(array_merge(['success' => true], $payload));
    exit;
}

// ── Session ───────────────────────────────────────────────────────────────────
session_start();

try {

    // ── Method guard ──────────────────────────────────────────────────────────
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        jsonError('Invalid request method. Only POST is accepted.', 405);
    }

    // ── Database connection ───────────────────────────────────────────────────
    // INTEGRATION: wrap mysqli in try-catch and return JSON on failure
    $conn = new mysqli(
        getenv('MYSQL_HOST')     ?: 'db',
        getenv('MYSQL_USER')     ?: 'root',
        getenv('MYSQL_PASSWORD') ?: 'rootpassword',
        getenv('MYSQL_DATABASE') ?: 'my_app_db'
    );

    if ($conn->connect_error) {
        // INTEGRATION: never expose raw DB credentials or internal error to client
        error_log('[submit_purchase_request] DB connect error: ' . $conn->connect_error);
        jsonError('Database connection failed. Please try again later.', 503);
    }

    $conn->set_charset('utf8mb4');

    // ── Parse body ───────────────────────────────────────────────────────────
    // php://input can only be read once – read it here and nowhere else.
    $rawBody = file_get_contents('php://input');

    if (empty(trim($rawBody))) {
        jsonError('Request body is empty.', 400);
    }

    $data = json_decode($rawBody, true);

    if (json_last_error() !== JSON_ERROR_NONE) {
        jsonError('Invalid JSON in request body: ' . json_last_error_msg(), 400);
    }

    // ── Resolve user ID ───────────────────────────────────────────────────────
    // Priority: body → session → header → default (test only, remove in production)
    $user_id = null;

    if (!empty($data['user_id'])) {
        $user_id = (int) $data['user_id'];
    } elseif (!empty($_SESSION['user_id'])) {
        $user_id = (int) $_SESSION['user_id'];
    } elseif (!empty($_SERVER['HTTP_X_USER_ID'])) {
        $user_id = (int) $_SERVER['HTTP_X_USER_ID'];
    }

    if (!$user_id || $user_id <= 0) {
        // INTEGRATION: comment out the line below and uncomment jsonError in production
        $user_id = 1; // Default test user – REMOVE IN PRODUCTION
        // jsonError('Unauthorized: user not identified.', 401);
    }

    // ── Required field validation ─────────────────────────────────────────────
    // INTEGRATION: collect all missing fields and return them in one response
    $required = ['pr_no', 'item_name', 'quantity', 'unit', 'unit_cost', 'office', 'division_section'];
    $missing  = [];
    foreach ($required as $field) {
        if (!isset($data[$field]) || $data[$field] === '' || $data[$field] === null) {
            $missing[] = $field;
        }
    }
    if ($missing) {
        jsonError('Missing required fields: ' . implode(', ', $missing), 422);
    }

    // ── Sanitize & compute ────────────────────────────────────────────────────
    $pr_no           = trim((string) $data['pr_no']);
    $description     = trim((string) ($data['description'] ?? ''));
    $quantity        = (float) $data['quantity'];
    $unit            = trim((string) $data['unit']);
    $unit_cost       = (float) $data['unit_cost'];
    $office          = trim((string) $data['office']);
    $division_section = trim((string) $data['division_section']);

    $total_amount = $quantity * $unit_cost;
    $form_type    = $total_amount >= 50000 ? 'ppe' : 'ics';

    // ── Duplicate PR check + auto-generate unique suffix if needed ────────────
    // INTEGRATION: Instead of rejecting, auto-append suffix to ensure persistence
    $original_pr_no = $pr_no;
    $attempt = 0;
    $max_attempts = 100;
    
    while ($attempt < $max_attempts) {
        $stmt = $conn->prepare('SELECT id FROM purchase_requests WHERE pr_no = ?');
        if (!$stmt) {
            error_log('[submit_purchase_request] prepare(dup-check): ' . $conn->error);
            jsonError('Database error during duplicate check.', 500);
        }
        $stmt->bind_param('s', $pr_no);
        $stmt->execute();
        $stmt->store_result();
        
        if ($stmt->num_rows === 0) {
            // No duplicate found, use this PR number
            $stmt->close();
            break;
        }
        
        $stmt->close();
        
        // Generate a new PR number with suffix
        $attempt++;
        $pr_no = $original_pr_no . '-' . str_pad($attempt, 2, '0', STR_PAD_LEFT);
    }
    
    if ($attempt >= $max_attempts) {
        jsonError('Could not generate a unique PR Number after 100 attempts. Please try a different base PR Number.', 500);
    }

    // ── Insert purchase_requests ──────────────────────────────────────────────
    $insert_sql = '
        INSERT INTO purchase_requests (
            pr_no, item_name, description, quantity, unit,
            unit_cost, total_amount, office, division_section,
            status, form_type, created_by
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, \'draft\', ?, ?)
    ';

    $stmt = $conn->prepare($insert_sql);
    if (!$stmt) {
        error_log('[submit_purchase_request] prepare(insert PR): ' . $conn->error);
        jsonError('Failed to prepare purchase request insert.', 500);
    }

    // item_name may be an array (JSON) – store as JSON string if so
    $item_name_value = is_array($data['item_name'])
        ? json_encode($data['item_name'])
        : (string) $data['item_name'];

    $stmt->bind_param(
        'sssdsdssssi',
        $pr_no,
        $item_name_value,
        $description,
        $quantity,
        $unit,
        $unit_cost,
        $total_amount,
        $office,
        $division_section,
        $form_type,
        $user_id
    );

    if (!$stmt->execute()) {
        error_log('[submit_purchase_request] execute(insert PR): ' . $stmt->error);
        jsonError('Failed to create purchase request. Please try again.', 500);
    }

    $pr_id = $stmt->insert_id;
    $stmt->close();

    // ── Insert entries ────────────────────────────────────────────────────────
    // INTEGRATION: Handle array of items – insert each item separately or use description
    $serial_no            = isset($data['serial_no'])            ? (string) $data['serial_no']            : null;
    $inventory_item_no    = isset($data['inventory_item_no'])    ? (string) $data['inventory_item_no']    : null;
    $estimated_useful_life = isset($data['estimated_useful_life']) ? (string) $data['estimated_useful_life'] : null;

    // If items is an array, use description field; otherwise use item_name_value
    $item_for_entries = is_array($data['item_name']) ? $description : ((string) $data['item_name']);
    // Truncate to fit in database column (typically VARCHAR(255) or similar)
    $item_for_entries = substr($item_for_entries, 0, 255);

    $entry_sql = '
        INSERT INTO entries (
            Quantity, Unit, UnitCost, TotalCost, Description,
            Item, Location, SerialNo, InventoryItemNo, EstimatedUsefulLife, DateAcquired
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
    ';

    $entry_stmt = $conn->prepare($entry_sql);
    if (!$entry_stmt) {
        error_log('[submit_purchase_request] prepare(insert entry): ' . $conn->error);
        jsonError('Failed to prepare entry insert.', 500);
    }

    $entry_stmt->bind_param(
        'dsddssssss',
        $quantity,
        $unit,
        $unit_cost,
        $total_amount,
        $description,
        $item_for_entries,
        $office,
        $serial_no,
        $inventory_item_no,
        $estimated_useful_life
    );

    if (!$entry_stmt->execute()) {
        error_log('[submit_purchase_request] execute(insert entry): ' . $entry_stmt->error);
        // INTEGRATION: return more detailed error info for debugging
        $debug = ['sql_error' => $entry_stmt->error, 'errno' => $entry_stmt->errno, 'item_length' => strlen($item_for_entries)];
        jsonError('Failed to create inventory entry.', 500, $debug);
    }

    $entry_id = $entry_stmt->insert_id;
    $entry_stmt->close();

    // ── Insert entry_workflow_status ──────────────────────────────────────────
    $step_1_data = json_encode([
        'item_name' => $data['item_name'],
        'quantity'  => $quantity,
        'unit'      => $unit,
        'unit_cost' => $unit_cost,
    ]);

    $wf_sql = '
        INSERT INTO entry_workflow_status (entry_id, pr_id, current_step, created_by) 
        VALUES (?, ?, ?, ?)
    ';
    $wf_stmt = $conn->prepare($wf_sql);
    if (!$wf_stmt) {
        error_log('[submit_purchase_request] Failed to prepare workflow_status insert: ' . $conn->error);
    } else {
        $current_step = 1;
        $wf_stmt->bind_param('iiii', $entry_id, $pr_id, $current_step, $user_id);
        $wf_stmt->execute();
        $wf_stmt->close();
    }

    // ── Audit log ─────────────────────────────────────────────────────────────
    $hist_sql = '
        INSERT INTO workflow_history (pr_id, status_to, action_by, action_type, notes)
        VALUES (?, \'draft\', ?, \'created\', \'Purchase Request created\')
    ';

    $hist_stmt = $conn->prepare($hist_sql);
    if ($hist_stmt) { // non-fatal if this fails – PR is already saved
        $hist_stmt->bind_param('ii', $pr_id, $user_id);
        $hist_stmt->execute();
        $hist_stmt->close();
    } else {
        error_log('[submit_purchase_request] prepare(history): ' . $conn->error);
    }

    $conn->close();

    // ── Success response ──────────────────────────────────────────────────────
    jsonOk([
        'message'      => 'Purchase Request submitted successfully',
        'pr_id'        => $pr_id,
        'pr_no'        => $pr_no,
        'total_amount' => $total_amount,
        'form_type'    => $form_type,
        'status'       => 'draft',
    ]);

} catch (Throwable $e) {
    // INTEGRATION: catch-all – unexpected errors still return valid JSON
    error_log('[submit_purchase_request] Uncaught error: ' . $e->getMessage() . ' in ' . $e->getFile() . ':' . $e->getLine());
    jsonError('An unexpected server error occurred. Please try again later.', 500);
}
