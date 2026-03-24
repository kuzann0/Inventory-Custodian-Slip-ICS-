<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  exit(0);
}

$validUser = "admin";
$validPass = "password123";

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if ($username === $validUser && $password === $validPass) {
    echo json_encode(["status" => "success"]);
    console.log("connected");
}

else if($username != $validUser && $password != $validPass) {

     echo error_log("test-log");
}


else {
    echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
    
}
?>