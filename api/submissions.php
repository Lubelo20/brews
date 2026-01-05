<?php
/**
 * API Endpoints for Form Submissions
 * Brews of Opportunity Website
 */

require_once 'config.php';

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Get request method and endpoint
$method = $_SERVER['REQUEST_METHOD'];
$endpoint = $_GET['action'] ?? '';

logApiCall($endpoint, $method);

try {
    switch ($endpoint) {
        case 'training':
            handleTrainingSubmission($db, $method);
            break;
        case 'sponsor':
            handleSponsorSubmission($db, $method);
            break;
        case 'contact':
            handleContactSubmission($db, $method);
            break;
        case 'newsletter':
            handleNewsletterSubscription($db, $method);
            break;
        case 'list':
            validateApiToken();
            handleSubmissionsList($db);
            break;
        default:
            sendErrorResponse('Invalid endpoint', 404);
    }
} catch (Exception $e) {
    sendErrorResponse('Server error: ' . $e->getMessage(), 500);
}

// Handle training form submissions
function handleTrainingSubmission($db, $method) {
    if ($method !== 'POST') {
        sendErrorResponse('Method not allowed', 405);
    }

    // Get and validate input
    $name = sanitizeInput($_POST['name'] ?? '');
    $email = sanitizeInput($_POST['email'] ?? '');
    $phone = sanitizeInput($_POST['phone'] ?? '');
    $location = sanitizeInput($_POST['location'] ?? '');
    $course = sanitizeInput($_POST['course'] ?? '');
    $message = sanitizeInput($_POST['message'] ?? '');
    $preferred_date = $_POST['preferred_date'] ?? null;

    // Validation
    if (empty($name) || empty($email) || empty($phone)) {
        sendErrorResponse('Name, email, and phone are required');
    }

    if (!validateEmail($email)) {
        sendErrorResponse('Invalid email address');
    }

    if (!validatePhone($phone)) {
        sendErrorResponse('Invalid phone number');
    }

    // Prepare date if provided
    $date_value = null;
    if ($preferred_date && !empty($preferred_date)) {
        $date_obj = DateTime::createFromFormat('Y-m-d', $preferred_date);
        if ($date_obj) {
            $date_value = $date_obj->format('Y-m-d');
        }
    }

    // Insert into database
    $query = "INSERT INTO training_signups 
              (full_name, email, phone, location, preferred_date, course_type, goals) 
              VALUES (?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$name, $email, $phone, $location, $date_value, $course, $message]);

    if ($stmt->rowCount() > 0) {
        // Send email notification (implement email function)
        sendTrainingNotificationEmail($name, $email, $phone, $course, $message);
        sendSuccessResponse(null, 'Training registration submitted successfully');
    } else {
        sendErrorResponse('Failed to submit registration');
    }
}

// Handle sponsor form submissions
function handleSponsorSubmission($db, $method) {
    if ($method !== 'POST') {
        sendErrorResponse('Method not allowed', 405);
    }

    // Get and validate input
    $company = sanitizeInput($_POST['company'] ?? '');
    $contact_name = sanitizeInput($_POST['contact_name'] ?? '');
    $email = sanitizeInput($_POST['email'] ?? '');
    $phone = sanitizeInput($_POST['phone'] ?? '');
    $sponsorship_level = sanitizeInput($_POST['sponsorship_level'] ?? '');
    $amount = $_POST['amount'] ?? null;
    $message = sanitizeInput($_POST['message'] ?? '');

    // Validation
    if (empty($contact_name) || empty($email)) {
        sendErrorResponse('Contact name and email are required');
    }

    if (!validateEmail($email)) {
        sendErrorResponse('Invalid email address');
    }

    if (!validatePhone($phone)) {
        sendErrorResponse('Invalid phone number');
    }

    // Validate amount if provided
    $amount_value = null;
    if ($amount && !empty($amount)) {
        $amount_value = floatval($amount);
        if ($amount_value <= 0) {
            sendErrorResponse('Invalid amount');
        }
    }

    // Insert into database
    $query = "INSERT INTO sponsor_enquiries 
              (company_name, contact_name, email, phone, sponsorship_level, amount, message) 
              VALUES (?, ?, ?, ?, ?, ?, ?)";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$company, $contact_name, $email, $phone, $sponsorship_level, $amount_value, $message]);

    if ($stmt->rowCount() > 0) {
        // Send email notification
        sendSponsorNotificationEmail($company, $contact_name, $email, $phone, $sponsorship_level, $amount_value, $message);
        sendSuccessResponse(null, 'Sponsor enquiry submitted successfully');
    } else {
        sendErrorResponse('Failed to submit enquiry');
    }
}

// Handle contact form submissions
function handleContactSubmission($db, $method) {
    if ($method !== 'POST') {
        sendErrorResponse('Method not allowed', 405);
    }

    // Get and validate input
    $name = sanitizeInput($_POST['name'] ?? '');
    $email = sanitizeInput($_POST['email'] ?? '');
    $phone = sanitizeInput($_POST['phone'] ?? '');
    $message = sanitizeInput($_POST['message'] ?? '');

    // Validation
    if (empty($name) || empty($email) || empty($message)) {
        sendErrorResponse('Name, email, and message are required');
    }

    if (!validateEmail($email)) {
        sendErrorResponse('Invalid email address');
    }

    if (!validatePhone($phone)) {
        sendErrorResponse('Invalid phone number');
    }

    // Insert into database
    $query = "INSERT INTO contact_submissions 
              (name, email, phone, message) 
              VALUES (?, ?, ?, ?)";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$name, $email, $phone, $message]);

    if ($stmt->rowCount() > 0) {
        // Send email notification
        sendContactNotificationEmail($name, $email, $phone, $message);
        sendSuccessResponse(null, 'Message sent successfully');
    } else {
        sendErrorResponse('Failed to send message');
    }
}

// Handle newsletter subscriptions
function handleNewsletterSubscription($db, $method) {
    if ($method !== 'POST') {
        sendErrorResponse('Method not allowed', 405);
    }

    // Get and validate input
    $email = sanitizeInput($_POST['email'] ?? '');
    $name = sanitizeInput($_POST['name'] ?? '');

    // Validation
    if (empty($email)) {
        sendErrorResponse('Email is required');
    }

    if (!validateEmail($email)) {
        sendErrorResponse('Invalid email address');
    }

    // Check if already subscribed
    $check_query = "SELECT id FROM newsletter_subscriptions WHERE email = ? AND is_active = 1";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->execute([$email]);
    
    if ($check_stmt->rowCount() > 0) {
        sendSuccessResponse(null, 'Already subscribed');
    }

    // Insert or reactivate subscription
    $query = "INSERT INTO newsletter_subscriptions (email, name, is_active) 
              VALUES (?, ?, 1) 
              ON DUPLICATE KEY UPDATE 
              is_active = 1, unsubscribed_at = NULL, updated_at = CURRENT_TIMESTAMP";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$email, $name]);

    sendSuccessResponse(null, 'Successfully subscribed to newsletter');
}

// Handle submissions list for admin
function handleSubmissionsList($db) {
    $type = $_GET['type'] ?? 'all';
    $limit = intval($_GET['limit'] ?? 50);
    $offset = intval($_GET['offset'] ?? 0);

    $results = [];

    switch ($type) {
        case 'training':
            $query = "SELECT * FROM training_signups 
                      ORDER BY created_at DESC 
                      LIMIT ? OFFSET ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$limit, $offset]);
            $results = $stmt->fetchAll();
            break;

        case 'sponsor':
            $query = "SELECT * FROM sponsor_enquiries 
                      ORDER BY created_at DESC 
                      LIMIT ? OFFSET ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$limit, $offset]);
            $results = $stmt->fetchAll();
            break;

        case 'contact':
            $query = "SELECT * FROM contact_submissions 
                      ORDER BY created_at DESC 
                      LIMIT ? OFFSET ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$limit, $offset]);
            $results = $stmt->fetchAll();
            break;

        case 'newsletter':
            $query = "SELECT * FROM newsletter_subscriptions 
                      WHERE is_active = 1
                      ORDER BY subscription_date DESC 
                      LIMIT ? OFFSET ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$limit, $offset]);
            $results = $stmt->fetchAll();
            break;

        case 'all':
        default:
            // Get recent submissions from all tables
            $query = "SELECT * FROM recent_submissions 
                      ORDER BY created_at DESC 
                      LIMIT ? OFFSET ?";
            $stmt = $db->prepare($query);
            $stmt->execute([$limit, $offset]);
            $results = $stmt->fetchAll();
            break;
    }

    sendSuccessResponse($results);
}

// Email notification functions (basic implementation)
function sendTrainingNotificationEmail($name, $email, $phone, $course, $message) {
    $to = 'info@wearyourbrand.co.za'; // Update with actual admin email
    $subject = 'New Training Registration - Brews of Opportunity';
    
    $body = "New training registration received:\n\n";
    $body .= "Name: $name\n";
    $body .= "Email: $email\n";
    $body .= "Phone: $phone\n";
    $body .= "Course: $course\n";
    $body .= "Message: $message\n";
    $body .= "Time: " . date('Y-m-d H:i:s') . "\n";
    
    $headers = "From: noreply@brewsopportunity.co.za\r\n";
    $headers .= "Reply-To: $email\r\n";
    
    // Uncomment to send emails (requires proper mail configuration)
    // mail($to, $subject, $body, $headers);
}

function sendSponsorNotificationEmail($company, $contact_name, $email, $phone, $level, $amount, $message) {
    $to = 'info@wearyourbrand.co.za';
    $subject = 'New Sponsor Enquiry - Brews of Opportunity';
    
    $body = "New sponsor enquiry received:\n\n";
    $body .= "Company: $company\n";
    $body .= "Contact: $contact_name\n";
    $body .= "Email: $email\n";
    $body .= "Phone: $phone\n";
    $body .= "Sponsorship Level: $level\n";
    $body .= "Amount: R" . number_format($amount, 2) . "\n";
    $body .= "Message: $message\n";
    $body .= "Time: " . date('Y-m-d H:i:s') . "\n";
    
    $headers = "From: noreply@brewsopportunity.co.za\r\n";
    $headers .= "Reply-To: $email\r\n";
    
    // mail($to, $subject, $body, $headers);
}

function sendContactNotificationEmail($name, $email, $phone, $message) {
    $to = 'info@wearyourbrand.co.za';
    $subject = 'New Contact Message - Brews of Opportunity';
    
    $body = "New contact message received:\n\n";
    $body .= "Name: $name\n";
    $body .= "Email: $email\n";
    $body .= "Phone: $phone\n";
    $body .= "Message: $message\n";
    $body .= "Time: " . date('Y-m-d H:i:s') . "\n";
    
    $headers = "From: noreply@brewsopportunity.co.za\r\n";
    $headers .= "Reply-To: $email\r\n";
    
    // mail($to, $subject, $body, $headers);
}
?>
