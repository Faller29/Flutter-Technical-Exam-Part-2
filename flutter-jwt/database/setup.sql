-- ===================================
-- Flutter Technical Exam Part 2
-- ===================================

-- Create database (if not exists)
CREATE DATABASE IF NOT EXISTS flutter_jwt;

-- Use the database
USE flutter_jwt;

-- Create login table
CREATE TABLE IF NOT EXISTS `login` (
  `id` int(255) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Insert demo users
INSERT INTO `login` (`username`, `password`, `name`) VALUES
('admin', 'admin123', 'Administrator'),
('user', 'user123', 'Test User');

-- Verify the data
SELECT * FROM `login`;

-- ===================================
-- IMPORTANT SECURITY NOTE:
-- In production, passwords should be hashed :X
