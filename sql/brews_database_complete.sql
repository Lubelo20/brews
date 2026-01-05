-- ===================================================================
-- Complete Database Schema for Brews of Opportunity Website
-- ===================================================================
-- This script creates a comprehensive database structure for the entire website
-- Run with: mysql -u root -p < sql/brews_database_complete.sql
-- ===================================================================

-- Create database (if not already created)
CREATE DATABASE IF NOT EXISTS `brews_opportunity` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `brews_opportunity`;

-- ===================================================================
-- CORE TABLES
-- ===================================================================

-- Users table for admin and future user management
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(200) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `first_name` VARCHAR(100) DEFAULT NULL,
  `last_name` VARCHAR(100) DEFAULT NULL,
  `role` ENUM('admin', 'staff', 'user') NOT NULL DEFAULT 'user',
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `last_login` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_username` (`username`),
  UNIQUE KEY `unique_email` (`email`),
  INDEX `idx_role` (`role`),
  INDEX `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- CONTENT MANAGEMENT TABLES
-- ===================================================================

-- Programs table for the different coffee programs
CREATE TABLE IF NOT EXISTS `programs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL,
  `slug` VARCHAR(200) NOT NULL UNIQUE,
  `description` TEXT NOT NULL,
  `what_we_do` TEXT,
  `who_we_help` TEXT,
  `community_impact` TEXT,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_slug` (`slug`),
  INDEX `idx_active` (`is_active`),
  INDEX `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Training courses table
CREATE TABLE IF NOT EXISTS `training_courses` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL,
  `slug` VARCHAR(200) NOT NULL UNIQUE,
  `description` TEXT NOT NULL,
  `price` DECIMAL(10,2) DEFAULT NULL,
  `duration_days` INT DEFAULT NULL,
  `what_you_learn` TEXT,
  `ideal_for` TEXT,
  `certification` VARCHAR(200) DEFAULT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_slug` (`slug`),
  INDEX `idx_active` (`is_active`),
  INDEX `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Products/Brands table for the uniform combos
CREATE TABLE IF NOT EXISTS `products` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `slug` VARCHAR(200) NOT NULL UNIQUE,
  `description` TEXT NOT NULL,
  `price_single` DECIMAL(10,2) DEFAULT NULL,
  `price_10_set` DECIMAL(10,2) DEFAULT NULL,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `category` VARCHAR(100) DEFAULT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_slug` (`slug`),
  INDEX `idx_category` (`category`),
  INDEX `idx_active` (`is_active`),
  INDEX `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sponsorship tiers table
CREATE TABLE IF NOT EXISTS `sponsorship_tiers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `min_amount` DECIMAL(12,2) NOT NULL,
  `max_amount` DECIMAL(12,2) DEFAULT NULL,
  `benefits` TEXT,
  `description` TEXT,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_slug` (`slug`),
  INDEX `idx_active` (`is_active`),
  INDEX `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- FORM SUBMISSIONS TABLES
-- ===================================================================

-- Training signups table (enhanced from existing)
CREATE TABLE IF NOT EXISTS `training_signups` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(200) NOT NULL,
  `email` VARCHAR(200) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `location` VARCHAR(200) DEFAULT NULL,
  `preferred_date` DATE DEFAULT NULL,
  `course_id` BIGINT UNSIGNED DEFAULT NULL,
  `course_type` VARCHAR(200) DEFAULT NULL,
  `goals` TEXT,
  `status` ENUM('new', 'contacted', 'enrolled', 'completed', 'cancelled') NOT NULL DEFAULT 'new',
  `notes` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_email` (`email`),
  INDEX `idx_status` (`status`),
  INDEX `idx_course` (`course_id`),
  INDEX `idx_created` (`created_at`),
  FOREIGN KEY (`course_id`) REFERENCES `training_courses`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sponsor enquiries table (enhanced from existing)
CREATE TABLE IF NOT EXISTS `sponsor_enquiries` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_name` VARCHAR(200) DEFAULT NULL,
  `contact_name` VARCHAR(200) NOT NULL,
  `email` VARCHAR(200) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `tier_id` BIGINT UNSIGNED DEFAULT NULL,
  `sponsorship_level` VARCHAR(100) DEFAULT NULL,
  `amount` DECIMAL(12,2) DEFAULT NULL,
  `message` TEXT,
  `status` ENUM('new', 'contacted', 'in_progress', 'confirmed', 'declined') NOT NULL DEFAULT 'new',
  `notes` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_email` (`email`),
  INDEX `idx_status` (`status`),
  INDEX `idx_tier` (`tier_id`),
  INDEX `idx_created` (`created_at`),
  FOREIGN KEY (`tier_id`) REFERENCES `sponsorship_tiers`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Contact form submissions table
CREATE TABLE IF NOT EXISTS `contact_submissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(200) NOT NULL,
  `email` VARCHAR(200) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `message` TEXT NOT NULL,
  `status` ENUM('new', 'read', 'replied', 'closed') NOT NULL DEFAULT 'new',
  `notes` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_email` (`email`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Newsletter subscriptions table
CREATE TABLE IF NOT EXISTS `newsletter_subscriptions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(200) NOT NULL UNIQUE,
  `name` VARCHAR(200) DEFAULT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `subscription_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `unsubscribed_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_email` (`email`),
  INDEX `idx_active` (`is_active`),
  INDEX `idx_subscription_date` (`subscription_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- ADDITIONAL FEATURES TABLES
-- ===================================================================

-- Gallery images table for website galleries
CREATE TABLE IF NOT EXISTS `gallery_images` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(200) DEFAULT NULL,
  `alt_text` VARCHAR(200) DEFAULT NULL,
  `image_url` VARCHAR(500) NOT NULL,
  `thumbnail_url` VARCHAR(500) DEFAULT NULL,
  `category` VARCHAR(100) DEFAULT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `sort_order` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_category` (`category`),
  INDEX `idx_active` (`is_active`),
  INDEX `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Site settings table for dynamic content
CREATE TABLE IF NOT EXISTS `site_settings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `setting_key` VARCHAR(100) NOT NULL UNIQUE,
  `setting_value` TEXT,
  `setting_type` ENUM('text', 'html', 'json', 'number', 'boolean') NOT NULL DEFAULT 'text',
  `description` TEXT,
  `is_public` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_key` (`setting_key`),
  INDEX `idx_public` (`is_public`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Activity log for admin actions
CREATE TABLE IF NOT EXISTS `activity_log` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT UNSIGNED DEFAULT NULL,
  `action` VARCHAR(100) NOT NULL,
  `table_name` VARCHAR(100) DEFAULT NULL,
  `record_id` BIGINT UNSIGNED DEFAULT NULL,
  `old_values` JSON DEFAULT NULL,
  `new_values` JSON DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_user` (`user_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_table` (`table_name`),
  INDEX `idx_created` (`created_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ===================================================================
-- VIEWS FOR COMMON QUERIES
-- ===================================================================

-- View for recent submissions across all forms
CREATE OR REPLACE VIEW `recent_submissions` AS
SELECT 
  'training' as type,
  id,
  full_name as name,
  email,
  phone,
  created_at
FROM training_signups
UNION ALL
SELECT 
  'sponsor' as type,
  id,
  contact_name as name,
  email,
  phone,
  created_at
FROM sponsor_enquiries
UNION ALL
SELECT 
  'contact' as type,
  id,
  name,
  email,
  phone,
  created_at
FROM contact_submissions
ORDER BY created_at DESC;

-- View for dashboard statistics
CREATE OR REPLACE VIEW `dashboard_stats` AS
SELECT 
  (SELECT COUNT(*) FROM training_signups WHERE status = 'new') as new_training_signups,
  (SELECT COUNT(*) FROM sponsor_enquiries WHERE status = 'new') as new_sponsor_enquiries,
  (SELECT COUNT(*) FROM contact_submissions WHERE status = 'new') as new_contact_messages,
  (SELECT COUNT(*) FROM newsletter_subscriptions WHERE is_active = 1) as active_subscribers,
  (SELECT COUNT(*) FROM programs WHERE is_active = 1) as active_programs,
  (SELECT COUNT(*) FROM training_courses WHERE is_active = 1) as active_courses;

-- ===================================================================
-- INDEXES FOR PERFORMANCE
-- ===================================================================

-- Composite indexes for common queries
CREATE INDEX idx_training_status_date ON training_signups(status, created_at);
CREATE INDEX idx_sponsor_status_date ON sponsor_enquiries(status, created_at);
CREATE INDEX idx_contact_status_date ON contact_submissions(status, created_at);
CREATE INDEX idx_newsletter_active_date ON newsletter_subscriptions(is_active, subscription_date);

-- ===================================================================
-- TRIGGERS FOR AUDITING
-- ===================================================================

DELIMITER //

-- Trigger to log changes to training signups
CREATE TRIGGER training_signups_audit_insert
AFTER INSERT ON training_signups
FOR EACH ROW
BEGIN
  INSERT INTO activity_log (action, table_name, record_id, new_values)
  VALUES ('INSERT', 'training_signups', NEW.id, JSON_OBJECT(
    'full_name', NEW.full_name,
    'email', NEW.email,
    'phone', NEW.phone,
    'course_type', NEW.course_type,
    'status', NEW.status
  ));
END//

CREATE TRIGGER training_signups_audit_update
AFTER UPDATE ON training_signups
FOR EACH ROW
BEGIN
  INSERT INTO activity_log (action, table_name, record_id, old_values, new_values)
  VALUES ('UPDATE', 'training_signups', NEW.id, 
    JSON_OBJECT('status', OLD.status, 'notes', OLD.notes),
    JSON_OBJECT('status', NEW.status, 'notes', NEW.notes)
  );
END//

-- Trigger to log sponsor enquiries
CREATE TRIGGER sponsor_enquiries_audit_insert
AFTER INSERT ON sponsor_enquiries
FOR EACH ROW
BEGIN
  INSERT INTO activity_log (action, table_name, record_id, new_values)
  VALUES ('INSERT', 'sponsor_enquiries', NEW.id, JSON_OBJECT(
    'company_name', NEW.company_name,
    'contact_name', NEW.contact_name,
    'email', NEW.email,
    'sponsorship_level', NEW.sponsorship_level,
    'status', NEW.status
  ));
END//

DELIMITER ;

-- ===================================================================
-- SAMPLE DATA (Optional - uncomment to populate with test data)
-- ===================================================================

/*
-- Insert default admin user (password: admin123 - change in production!)
INSERT INTO users (username, email, password_hash, first_name, last_name, role) VALUES
('admin', 'admin@brewsopportunity.co.za', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin', 'User', 'admin');

-- Insert sample programs
INSERT INTO programs (title, slug, description, what_we_do, who_we_help, community_impact, sort_order) VALUES
('Mobile Coffee Carts', 'mobile-coffee-carts', 'Mobile coffee cart setups for township entrepreneurs', 'We provide mobile coffee carts, equipment, training, and ongoing support to entrepreneurs in high-traffic township areas.', 'Aspiring entrepreneurs in township areas with limited startup capital but high motivation.', 'Creates visible entrepreneurship opportunities, brings quality coffee to underserved areas, and inspires community members.', 1),
('Spaza Shop Coffee', 'spaza-shop-coffee', 'Adding professional coffee setups to existing spaza shops', 'Install coffee equipment in existing spaza shops, train owners and staff, provide supply chain support.', 'Existing spaza shop owners looking to expand their product offerings.', 'Strengthens existing businesses, adds convenience for community members, transforms shops into multi-service hubs.', 2);

-- Insert sample training courses
INSERT INTO training_courses (title, slug, description, price, duration_days, what_you_learn, ideal_for, certification, sort_order) VALUES
('Basic Barista Course', 'basic-barista-course', 'Essential coffee making skills for beginners', 3500.00, 3, 'Coffee fundamentals, espresso preparation, milk steaming, basic latte art, customer service', 'Beginners with little or no coffee experience', 'Basic Barista Certificate', 1),
('Professional Barista Course', 'professional-barista-course', 'Comprehensive training for professional baristas', 5500.00, 5, 'Advanced espresso techniques, latte art, coffee brewing methods, equipment maintenance, menu development', 'Those with basic experience wanting to become professional baristas', 'Professional Barista Certificate', 2);

-- Insert sample products
INSERT INTO products (name, slug, description, price_single, price_10_set, category, sort_order) VALUES
('Waiter Combo', 'waiter-combo', 'Formal Shirt, Black Poly Cotton Apron with eyelets and BLACK LEATHER HALTER, Gatsby hat', 1110.00, 9990.00, 'Combo', 1),
('Barman Combo', 'barman-combo', 'Formal Shirt, Black Poly Cotton Apron with eyelets and BLACK LEATHER HALTER, Gatsby hat', 1710.00, 15390.00, 'Combo', 2);

-- Insert sample sponsorship tiers
INSERT INTO sponsorship_tiers (name, slug, min_amount, max_amount, benefits, sort_order) VALUES
('Bronze Sponsor', 'bronze', 50000.00, 100000.00, 'Logo on website, Social media recognition, Quarterly impact reports, Certificate of partnership, Support 5-10 entrepreneurs, Invitation to annual showcase event', 1),
('Silver Sponsor', 'silver', 100001.00, 250000.00, 'All Bronze benefits, Featured sponsor status, Brand presence at events, Monthly updates, Media coverage, Support 10-25 entrepreneurs, Co-branded stories', 2);

-- Insert sample site settings
INSERT INTO site_settings (setting_key, setting_value, setting_type, description, is_public) VALUES
('site_title', 'Brews of Opportunity', 'text', 'Website title', true),
('contact_email', 'info@wearyourbrand.co.za', 'text', 'Main contact email', true),
('contact_phone', '065 904 2919', 'text', 'Main contact phone', true),
('company_address', 'Durban, South Africa', 'text', 'Company address', true),
('social_facebook', '#', 'text', 'Facebook URL', true),
('social_instagram', '#', 'text', 'Instagram URL', true),
('social_tiktok', '#', 'text', 'TikTok URL', true);
*/

-- ===================================================================
-- NOTES AND NEXT STEPS
-- ===================================================================

/*
1. SECURITY:
   - Change default admin password immediately
   - Create dedicated database user with limited privileges
   - Enable SSL for database connections in production

2. BACKUPS:
   - Set up regular automated backups
   - Test backup restoration procedures
   - Consider point-in-time recovery setup

3. PERFORMANCE:
   - Monitor query performance
   - Add additional indexes as needed
   - Consider partitioning for large tables

4. SCALING:
   - Consider read replicas for high traffic
   - Implement connection pooling
   - Monitor disk space and memory usage

5. MAINTENANCE:
   - Regularly optimize tables
   - Monitor error logs
   - Update statistics on large tables

6. INTEGRATION:
   - Create API endpoints for form submissions
   - Implement email notifications for new submissions
   - Set up admin dashboard for data management
*/
