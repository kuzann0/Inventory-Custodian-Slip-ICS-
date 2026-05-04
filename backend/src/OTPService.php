<?php
/**
 * OTP Service Class
 * 
 * Handles OTP generation, sending via Gmail, and verification
 * Integrates with PHPMailer for Gmail SMTP
 */

namespace ICS;

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class OTPService {
    private $db;
    private $mailer;
    private $config;
    private $otpLength = 6;
    private $otpExpiry = 300; // 5 minutes in seconds
    private $maxAttempts = 5;

    /**
     * Initialize OTP Service
     */
    public function __construct($db = null) {
        $this->db = $db;
        $this->initializePHPMailer();
    }

    /**
     * Initialize PHPMailer for Gmail
     */
    private function initializePHPMailer() {
        try {
            $this->mailer = new PHPMailer(true);
            
            // Gmail SMTP Configuration
            $this->mailer->isSMTP();
            $this->mailer->Host = getenv('MAIL_HOST') ?? 'smtp.gmail.com';
            $this->mailer->SMTPAuth = true;
            $this->mailer->Username = getenv('MAIL_USERNAME') ?? 'your-email@gmail.com';
            $this->mailer->Password = getenv('MAIL_PASSWORD') ?? 'your-app-password';
            $this->mailer->SMTPSecure = getenv('MAIL_ENCRYPTION') ?? 'tls';
            $this->mailer->Port = getenv('MAIL_PORT') ?? 587;
            
            // SSL Settings for Gmail
            $this->mailer->SMTPOptions = [
                'ssl' => [
                    'verify_peer' => false,
                    'verify_peer_name' => false,
                    'allow_self_signed' => true
                ]
            ];

            // Set From
            $this->mailer->setFrom(
                getenv('MAIL_FROM_ADDRESS') ?? 'noreply@ics-system.local',
                getenv('MAIL_FROM_NAME') ?? 'ICS System'
            );

            return true;
        } catch (Exception $e) {
            error_log('PHPMailer initialization failed: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Generate and Send OTP via Email
     * 
     * @param string $email User email address
     * @param string $username Username for personalization
     * @return array ['success' => bool, 'message' => string, 'otp_id' => string]
     */
    public function generateAndSendOTP($email, $username = '') {
        // Validate email
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return [
                'success' => false,
                'message' => 'Invalid email format'
            ];
        }

        try {
            // Generate random OTP
            $otp = $this->generateRandomOTP();
            $otp_id = bin2hex(random_bytes(16));
            $created_at = time();
            $expires_at = $created_at + $this->otpExpiry;

            // Store OTP in database
            if ($this->db) {
                $query = "INSERT INTO otp_codes (otp_id, email, otp_code, created_at, expires_at, attempts, status) 
                         VALUES (?, ?, ?, ?, ?, 0, 'pending')";
                $stmt = $this->db->prepare($query);
                
                if (!$stmt) {
                    throw new Exception("Database prepare failed: " . $this->db->error);
                }

                $stmt->bind_param("ssiii", $otp_id, $email, $otp, $created_at, $expires_at);
                $stmt->execute();
                $stmt->close();
            }

            // Send OTP via Gmail
            $emailSent = $this->sendOTPEmail($email, $otp, $username);

            if (!$emailSent) {
                throw new Exception("Failed to send email");
            }

            return [
                'success' => true,
                'message' => 'OTP sent to your email',
                'otp_id' => $otp_id,
                'expires_in' => $this->otpExpiry
            ];
        } catch (Exception $e) {
            error_log('OTP generation error: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to generate OTP: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Send OTP Email via Gmail
     */
    private function sendOTPEmail($email, $otp, $username = '') {
        try {
            $this->mailer->clearAddresses();
            $this->mailer->addAddress($email);
            $this->mailer->Subject = 'Your OTP Code for ICS System';
            $this->mailer->isHTML(true);

            // HTML Email Template
            $htmlBody = $this->generateOTPEmailTemplate($otp, $username);
            $this->mailer->Body = $htmlBody;
            $this->mailer->AltBody = "Your OTP is: $otp\nValid for 5 minutes.";

            $this->mailer->send();
            return true;
        } catch (Exception $e) {
            error_log('Email sending failed: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Generate HTML Email Template
     */
    private function generateOTPEmailTemplate($otp, $username = '') {
        $user_info = $username ? "Hello $username," : "Hello,";
        
        return "
        <html>
        <head>
            <style>
                body { font-family: 'Segoe UI', Arial, sans-serif; background-color: #f5f5f5; }
                .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                .header { color: #1c1f71; font-size: 24px; font-weight: bold; margin-bottom: 20px; }
                .message { color: #333; line-height: 1.6; margin-bottom: 20px; }
                .otp-box { background: #1c1f71; color: white; padding: 20px; border-radius: 5px; text-align: center; margin: 20px 0; }
                .otp-code { font-size: 32px; font-weight: bold; letter-spacing: 5px; }
                .expiry { color: #666; font-size: 12px; margin-top: 10px; }
                .footer { color: #999; font-size: 12px; border-top: 1px solid #eee; padding-top: 10px; margin-top: 20px; }
            </style>
        </head>
        <body>
            <div class='container'>
                <div class='header'>ICS System - Authentication</div>
                <div class='message'>
                    $user_info<br><br>
                    Thank you for logging in. Please use the code below to complete your authentication:
                </div>
                <div class='otp-box'>
                    <div class='otp-code'>$otp</div>
                    <div class='expiry'>Valid for 5 minutes. Do not share this code.</div>
                </div>
                <div class='footer'>
                    If you did not request this code, please ignore this email and your account will remain secure.
                </div>
            </div>
        </body>
        </html>";
    }

    /**
     * Generate Random OTP
     */
    private function generateRandomOTP() {
        $otp = '';
        for ($i = 0; $i < $this->otpLength; $i++) {
            $otp .= mt_rand(0, 9);
        }
        return $otp;
    }

    /**
     * Verify OTP
     * 
     * @param string $otp_id OTP session ID
     * @param string $otp_code OTP code entered by user
     * @return array ['success' => bool, 'message' => string, 'email' => string]
     */
    public function verifyOTP($otp_id, $otp_code) {
        if (!$this->db) {
            return [
                'success' => false,
                'message' => 'Database not available'
            ];
        }

        try {
            // Validate format
            if (empty($otp_id) || empty($otp_code)) {
                return [
                    'success' => false,
                    'message' => 'Invalid input'
                ];
            }

            // Fetch OTP record
            $query = "SELECT * FROM otp_codes WHERE otp_id = ? AND status = 'pending'";
            $stmt = $this->db->prepare($query);
            
            if (!$stmt) {
                throw new Exception("Database query failed: " . $this->db->error);
            }

            $stmt->bind_param("s", $otp_id);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows === 0) {
                return [
                    'success' => false,
                    'message' => 'OTP session not found or expired'
                ];
            }

            $otpRecord = $result->fetch_assoc();
            $stmt->close();

            // Check expiry
            if (time() > $otpRecord['expires_at']) {
                $this->markOTPAsExpired($otp_id);
                return [
                    'success' => false,
                    'message' => 'OTP has expired'
                ];
            }

            // Check attempts
            if ($otpRecord['attempts'] >= $this->maxAttempts) {
                $this->markOTPAsExpired($otp_id);
                return [
                    'success' => false,
                    'message' => 'Too many attempts. Request a new OTP.'
                ];
            }

            // Verify OTP code
            if ($otpRecord['otp_code'] !== $otp_code) {
                $this->incrementOTPAttempts($otp_id);
                return [
                    'success' => false,
                    'message' => 'Invalid OTP code'
                ];
            }

            // Mark OTP as verified
            $query = "UPDATE otp_codes SET status = 'verified', verified_at = ? WHERE otp_id = ?";
            $stmt = $this->db->prepare($query);
            $verified_at = time();
            $stmt->bind_param("is", $verified_at, $otp_id);
            $stmt->execute();
            $stmt->close();

            return [
                'success' => true,
                'message' => 'OTP verified successfully',
                'email' => $otpRecord['email']
            ];
        } catch (Exception $e) {
            error_log('OTP verification error: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Verification failed: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Mark OTP as Expired
     */
    private function markOTPAsExpired($otp_id) {
        if (!$this->db) return;
        
        $query = "UPDATE otp_codes SET status = 'expired' WHERE otp_id = ?";
        $stmt = $this->db->prepare($query);
        $stmt->bind_param("s", $otp_id);
        $stmt->execute();
        $stmt->close();
    }

    /**
     * Increment Failed Attempts
     */
    private function incrementOTPAttempts($otp_id) {
        if (!$this->db) return;
        
        $query = "UPDATE otp_codes SET attempts = attempts + 1 WHERE otp_id = ?";
        $stmt = $this->db->prepare($query);
        $stmt->bind_param("s", $otp_id);
        $stmt->execute();
        $stmt->close();
    }

    /**
     * Resend OTP
     */
    public function resendOTP($otp_id) {
        if (!$this->db) {
            return [
                'success' => false,
                'message' => 'Database not available'
            ];
        }

        try {
            // Fetch previous OTP
            $query = "SELECT email FROM otp_codes WHERE otp_id = ? AND status IN ('pending', 'verified')";
            $stmt = $this->db->prepare($query);
            $stmt->bind_param("s", $otp_id);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows === 0) {
                return [
                    'success' => false,
                    'message' => 'OTP session not found'
                ];
            }

            $email = $result->fetch_assoc()['email'];
            $stmt->close();

            // Generate new OTP
            return $this->generateAndSendOTP($email);
        } catch (Exception $e) {
            error_log('OTP resend error: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Failed to resend OTP: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Get OTP Status
     */
    public function getOTPStatus($otp_id) {
        if (!$this->db) {
            return [
                'exists' => false,
                'status' => 'unknown'
            ];
        }

        $query = "SELECT status, expires_at, attempts FROM otp_codes WHERE otp_id = ?";
        $stmt = $this->db->prepare($query);
        $stmt->bind_param("s", $otp_id);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 0) {
            $stmt->close();
            return [
                'exists' => false,
                'status' => 'not_found'
            ];
        }

        $data = $result->fetch_assoc();
        $stmt->close();

        return [
            'exists' => true,
            'status' => $data['status'],
            'expired' => time() > $data['expires_at'],
            'attempts' => $data['attempts'],
            'time_remaining' => max(0, $data['expires_at'] - time())
        ];
    }

    /**
     * Cleanup Expired OTPs (run periodically)
     */
    public function cleanupExpiredOTPs() {
        if (!$this->db) return;

        $query = "DELETE FROM otp_codes WHERE expires_at < ? OR status IN ('expired', 'verified') AND created_at < ?";
        $stmt = $this->db->prepare($query);
        
        $now = time();
        $expiry_cutoff = $now - (24 * 3600); // Delete verified OTPs older than 24 hours
        
        $stmt->bind_param("ii", $now, $expiry_cutoff);
        $stmt->execute();
        $stmt->close();
    }
}
?>
