<?php
/**
 * Database Configuration
 * Brews of Opportunity Website
 */

// Database connection settings
define('DB_HOST', 'localhost');
define('DB_NAME', 'brews_opportunity');
define('DB_USER', 'root');
define('DB_PASS', '');

// Security settings
define('API_TOKEN', 'your-secure-api-token-here'); // Change this in production
define('CORS_ORIGIN', '*'); // Set to your domain in production

// Error reporting (disable in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Set headers
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: ' . CORS_ORIGIN);
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Database connection class
class Database {
    private $host = DB_HOST;
    private $db_name = DB_NAME;
    private $username = DB_USER;
    private $password = DB_PASS;
    private $conn;

    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO(
                "mysql:host=" . $this->host . ";dbname=" . $this->db_name . ";charset=utf8mb4",
                $this->username,
                $this->password,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]
            );
        } catch(PDOException $exception) {
            http_response_code(500);
            echo json_encode([
                'success' => false,
                'message' => 'Database connection failed: ' . $exception->getMessage()
            ]);
            exit;
        }

        return $this->conn;
    }
}

// Helper functions
function sanitizeInput($data) {
    $data = trim($data);
    $data = stripslashes($data);
    $data = htmlspecialchars($data, ENT_QUOTES, 'UTF-8');
    return $data;
}

function validateEmail($email) {
    return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
}

function validatePhone($phone) {
    // Basic phone validation - adjust as needed for South African formats
    return preg_match('/^[\d\s\-\+\(\)]+$/', $phone) && strlen($phone) >= 10;
}

function sendErrorResponse($message, $code = 400) {
    http_response_code($code);
    echo json_encode([
        'success' => false,
        'message' => $message
    ]);
    exit;
}

function sendSuccessResponse($data = null, $message = 'Success') {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => $message,
        'data' => $data
    ]);
    exit;
}

// API Token validation (optional)
function validateApiToken() {
    $headers = getallheaders();
    $token = null;
    
    // Check Authorization header
    if (isset($headers['Authorization'])) {
        $auth = $headers['Authorization'];
        if (preg_match('/Bearer\s+(.*)$/i', $auth, $matches)) {
            $token = $matches[1];
        }
    }
    
    // Check query parameter as fallback
    if (!$token && isset($_GET['token'])) {
        $token = $_GET['token'];
    }
    
    // Validate token (disable if not using token authentication)
    if ($token && $token !== API_TOKEN) {
        sendErrorResponse('Invalid API token', 401);
    }
    
    return true;
}

// Log API calls for debugging
function logApiCall($endpoint, $method, $data = null) {
    $log_entry = [
        'timestamp' => date('Y-m-d H:i:s'),
        'endpoint' => $endpoint,
        'method' => $method,
        'ip' => $_SERVER['REMOTE_ADDR'],
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? '',
        'data' => $data
    ];
    
    // Only log in development or create a proper logging system
    if (defined('DEBUG_MODE') && DEBUG_MODE) {
        error_log(json_encode($log_entry));
    }
}
 
?>
