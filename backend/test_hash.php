<?php
$password = "SuperAdmin@2026";
$hash = '$2y$10$yvNT0MlQPYuieqfVjOU56e6f7Uw8F1Gjtr3InkKL7TmoNIrjbyCVi';
echo password_verify($password, $hash) ? 'VALID' : 'INVALID';
?>
