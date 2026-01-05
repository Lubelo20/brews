-- SQL script to create database and tables for Brews of Opportunity
-- Save as: sql/create_tables.sql
-- Run with: mysql -u root -p < sql/create_tables.sql  (or run contents in your MySQL client)

-- Create database (if not already created)
CREATE DATABASE IF NOT EXISTS `brews` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `brews`;

-- Table: trainings (captures training signup requests)
CREATE TABLE IF NOT EXISTS `trainings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(200) NOT NULL,
  `email` VARCHAR(200) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `location` VARCHAR(200) DEFAULT NULL,
  `preferred_date` DATE DEFAULT NULL,
  `course_type` VARCHAR(200) DEFAULT NULL,
  `notes` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX (`email`),
  INDEX (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: sponsors (captures sponsor enquiries / interest)
CREATE TABLE IF NOT EXISTS `sponsors` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `company_name` VARCHAR(200) DEFAULT NULL,
  `contact_name` VARCHAR(200) DEFAULT NULL,
  `email` VARCHAR(200) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `sponsorship_level` VARCHAR(100) DEFAULT NULL,
  `amount` DECIMAL(10,2) DEFAULT NULL,
  `message` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX (`email`),
  INDEX (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional: a generic submissions table (if you prefer a single table)
-- Uncomment if you want a single submissions table instead of separate tables
--[[
CREATE TABLE IF NOT EXISTS `submissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `category` VARCHAR(50) NOT NULL,
  `name` VARCHAR(200) DEFAULT NULL,
  `email` VARCHAR(200) DEFAULT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `company` VARCHAR(200) DEFAULT NULL,
  `package_choice` VARCHAR(200) DEFAULT NULL,
  `message` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
]]--

-- Example SELECTs (admin queries)
-- All training signups:
-- SELECT * FROM trainings ORDER BY created_at DESC LIMIT 200;

-- All sponsor enquiries:
-- SELECT * FROM sponsors ORDER BY created_at DESC LIMIT 200;

-- Quick counts:
-- SELECT COUNT(*) AS total_trainings FROM trainings;
-- SELECT COUNT(*) AS total_sponsors FROM sponsors;

-- Notes:
-- 1) Adjust field lengths/types to match your form inputs.
-- 2) To store more structured data (e.g., multiple package choices), create a separate table and reference by id.
-- 3) For production, secure DB access (use a dedicated DB user) and run migrations instead of executing raw SQL in production environments.
