<?php
/**
 * Mail Service Class
 * 
 * Handles email sending with fallback to offline mode
 * Supports both online (SMTP) and offline (file-based) scenarios
 */

namespace ICS;

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

class MailService {
    private $mailer;
    private $config;
    private $mode; // 'online' or 'offline'
    private $offlineDir;

    /**
     * Initialize Mail Service
     */
    public function __construct($configPath = null) {
        if ($configPath === null) {
            $configPath = __DIR__ . '/../config/mail.config.php';
        }

        $this->config = include $configPath;
        $this->mode = $this->config['mode'];
        $this->offlineDir = $this->config['offline']['email_dir'];

        // Create offline directories if they don't exist
        @mkdir($this->offlineDir, 0755, true);
        @mkdir($this->config['offline']['token_dir'], 0755, true);

        if ($this->mode === 'online') {
            $this->initializePHPMailer();
        }
    }

    /**
     * Initialize PHPMailer for online mode
     */
    private function initializePHPMailer() {
        try {
            $this->mailer = new PHPMailer(true);
            
            // SMTP Configuration
            $this->mailer->isSMTP();
            $this->mailer->Host = $this->config['smtp']['host'];
            $this->mailer->SMTPAuth = true;
            $this->mailer->Username = $this->config['smtp']['username'];
            $this->mailer->Password = $this->config['smtp']['password'];
            $this->mailer->SMTPSecure = $this->config['smtp']['encryption'];
            $this->mailer->Port = $this->config['smtp']['port'];
            
            // SSL Verification
            if (!$this->config['smtp']['verifySSL']) {
                $this->mailer->SMTPOptions = [
                    'ssl' => [
                        'verify_peer' => false,
                        'verify_peer_name' => false,
                        'allow_self_signed' => true
                    ]
                ];
            }

            // Set From
            $this->mailer->setFrom(
                $this->config['from']['address'],
                $this->config['from']['name']
            );

            return true;
        } catch (Exception $e) {
            error_log('PHPMailer initialization failed: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send Email
     * 
     * @param string $to Recipient email
     * @param string $subject Email subject
     * @param string $body Email body (HTML)
     * @param string $altText Plain text alternative
     * @param array $attachments Files to attach [['path' => '...', 'name' => '...'], ...]
     * @return array ['success' => bool, 'message' => string, 'mode' => 'online'|'offline']
     */
    public function send($to, $subject, $body, $altText = '', $attachments = []) {
        if ($this->mode === 'online') {
            return $this->sendOnline($to, $subject, $body, $altText, $attachments);
        } else {
            return $this->sendOffline($to, $subject, $body, $altText, $attachments);
        }
    }

    /**
     * Send Email in Online Mode
     */
    private function sendOnline($to, $subject, $body, $altText = '', $attachments = []) {
        try {
            $this->mailer->clearAddresses();
            $this->mailer->addAddress($to);
            $this->mailer->Subject = $subject;
            $this->mailer->isHTML(true);
            $this->mailer->Body = $body;
            
            if ($altText) {
                $this->mailer->AltBody = $altText;
            }

            // Add attachments
            foreach ($attachments as $attachment) {
                if (file_exists($attachment['path'])) {
                    $this->mailer->addAttachment(
                        $attachment['path'],
                        $attachment['name'] ?? basename($attachment['path'])
                    );
                }
            }

            $this->mailer->send();

            return [
                'success' => true,
                'message' => 'Email sent successfully',
                'mode' => 'online',
                'to' => $to
            ];
        } catch (Exception $e) {
            // Fallback to offline mode if online send fails
            error_log('Online email failed: ' . $e->getMessage() . '. Falling back to offline storage.');
            return $this->sendOffline($to, $subject, $body, $altText, $attachments);
        }
    }

    /**
     * Store Email in Offline Mode
     */
    private function sendOffline($to, $subject, $body, $altText = '', $attachments = []) {
        try {
            $emailData = [
                'timestamp' => time(),
                'to' => $to,
                'subject' => $subject,
                'body' => $body,
                'altText' => $altText,
                'from' => $this->config['from']['address'],
                'fromName' => $this->config['from']['name'],
                'attachments' => []
            ];

            // Store attachment details (files handled separately)
            foreach ($attachments as $attachment) {
                if (file_exists($attachment['path'])) {
                    $emailData['attachments'][] = [
                        'path' => $attachment['path'],
                        'name' => $attachment['name'] ?? basename($attachment['path'])
                    ];
                }
            }

            // Save email to JSON file
            $filename = $this->offlineDir . md5($to . $subject . time()) . '.json';
            file_put_contents($filename, json_encode($emailData, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

            return [
                'success' => true,
                'message' => 'Email stored offline. Will be sent when connection restored.',
                'mode' => 'offline',
                'to' => $to,
                'file' => $filename
            ];
        } catch (Exception $e) {
            return [
                'success' => false,
                'message' => 'Failed to store email: ' . $e->getMessage(),
                'mode' => 'offline'
            ];
        }
    }

    /**
     * Process Offline Emails
     * 
     * Called periodically to send stored offline emails when connection is restored
     * @return array Summary of sent emails
     */
    public function processOfflineEmails() {
        if (!is_dir($this->offlineDir)) {
            return ['sent' => 0, 'failed' => 0, 'pending' => 0];
        }

        $files = glob($this->offlineDir . '*.json');
        $summary = ['sent' => 0, 'failed' => 0, 'pending' => 0, 'details' => []];

        foreach ($files as $file) {
            $emailData = json_decode(file_get_contents($file), true);
            
            try {
                $this->mailer->clearAddresses();
                $this->mailer->addAddress($emailData['to']);
                $this->mailer->Subject = $emailData['subject'];
                $this->mailer->isHTML(true);
                $this->mailer->Body = $emailData['body'];

                if ($emailData['altText']) {
                    $this->mailer->AltBody = $emailData['altText'];
                }

                // Re-attach files
                foreach ($emailData['attachments'] as $attachment) {
                    if (file_exists($attachment['path'])) {
                        $this->mailer->addAttachment(
                            $attachment['path'],
                            $attachment['name']
                        );
                    }
                }

                $this->mailer->send();
                
                // Delete sent email file
                unlink($file);
                $summary['sent']++;
                $summary['details'][] = [
                    'to' => $emailData['to'],
                    'status' => 'sent',
                    'subject' => $emailData['subject']
                ];
            } catch (Exception $e) {
                $summary['failed']++;
                $summary['details'][] = [
                    'to' => $emailData['to'],
                    'status' => 'failed',
                    'subject' => $emailData['subject'],
                    'error' => $e->getMessage()
                ];
            }
        }

        $summary['pending'] = count(glob($this->offlineDir . '*.json'));
        return $summary;
    }

    /**
     * Get Offline Emails Count
     */
    public function getOfflineEmailsCount() {
        if (!is_dir($this->offlineDir)) {
            return 0;
        }
        return count(glob($this->offlineDir . '*.json'));
    }

    /**
     * Get Current Mode
     */
    public function getMode() {
        return $this->mode;
    }
}
?>
