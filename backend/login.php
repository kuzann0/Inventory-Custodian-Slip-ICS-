<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

$validUser = "admin";
$validPass = "password123";

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if ($username === $validUser && $password === $validPass) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error", "message" => "Invalid credentials"]);
}
?>