<?php
// Generate bcrypt hash for any password passed as argument
$password = $argv[1] ?? 'yusho123';  // Default to yusho123 if no argument given
$hash = password_hash($password, PASSWORD_BCRYPT);
echo $hash;
?>
