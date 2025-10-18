-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 11, 2025 at 07:23 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `onukul`
--

-- --------------------------------------------------------

--
-- Table structure for table `aid_item`
--

CREATE TABLE `aid_item` (
  `id` int(11) NOT NULL,
  `item_name` varchar(120) NOT NULL,
  `unit` varchar(40) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `aid_item`
--

INSERT INTO `aid_item` (`id`, `item_name`, `unit`, `quantity`) VALUES
(1, 'Rice', 'kg', 555),
(2, 'Lentils', 'kg', 200),
(3, 'Oil', 'L', 150),
(4, 'Salt', 'kg', 300),
(5, 'Water', 'bottle', 800),
(6, 'Rice', 'kg', 555),
(7, 'Lentils', 'kg', 200),
(8, 'Oil', 'L', 150),
(9, 'Salt', 'kg', 300),
(10, 'Water', 'bottle', 800),
(12, 'fish', 'kg', 11),
(13, 'chicken', 'kg', 7),
(14, 'fish', '1kg', 5);

-- --------------------------------------------------------

--
-- Table structure for table `aid_request_item`
--

CREATE TABLE `aid_request_item` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `item_name` varchar(120) NOT NULL,
  `unit` varchar(40) NOT NULL,
  `quantity` int(11) NOT NULL,
  `reason` text DEFAULT NULL,
  `request_status` enum('pending','approved','rejected','distributed') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `aid_request_item`
--

INSERT INTO `aid_request_item` (`id`, `user_id`, `item_name`, `unit`, `quantity`, `reason`, `request_status`, `created_at`) VALUES
(1, 5, 'chicken', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(2, 5, 'fish', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(3, 5, 'Lentils', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(4, 5, 'Lentils', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(5, 5, 'Oil', 'L', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(6, 5, 'Oil', 'L', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(7, 5, 'Rice', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(8, 5, 'Rice', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(9, 5, 'Salt', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(10, 5, 'Salt', 'kg', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(11, 5, 'Water', 'bottle', 1, 'faltujinis', 'pending', '2025-09-11 04:07:39'),
(12, 5, 'Water', 'bottle', 1, 'faltujinis', 'approved', '2025-09-11 04:07:39'),
(13, 4, 'chicken', 'kg', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(14, 4, 'fish', 'kg', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(15, 4, 'Lentils', 'kg', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(16, 4, 'Lentils', 'kg', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(17, 4, 'Oil', 'L', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(18, 4, 'Oil', 'L', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(19, 4, 'Rice', 'kg', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(20, 4, 'Rice', 'kg', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(21, 4, 'Salt', 'kg', 1, 'fgadfhg', 'pending', '2025-09-11 04:27:45'),
(22, 4, 'Salt', 'kg', 1, 'fgadfhg', 'approved', '2025-09-11 04:27:45'),
(23, 4, 'Water', 'bottle', 1, 'fgadfhg', 'approved', '2025-09-11 04:27:45'),
(24, 4, 'Water', 'bottle', 1, 'fgadfhg', 'approved', '2025-09-11 04:27:45'),
(25, 5, 'Oil', 'L', 1, 'fegre', 'distributed', '2025-09-11 05:03:28');

-- --------------------------------------------------------

--
-- Table structure for table `aid_request_packages`
--

CREATE TABLE `aid_request_packages` (
  `request_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `package_id` int(11) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `request_date` date NOT NULL DEFAULT curdate(),
  `request_status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `aid_request_packages`
--

INSERT INTO `aid_request_packages` (`request_id`, `user_id`, `package_id`, `reason`, `request_date`, `request_status`) VALUES
(1, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(2, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(3, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(4, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(5, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(6, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(7, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(8, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(9, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(10, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(11, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(12, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(13, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(14, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(15, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(16, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(17, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(18, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(19, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(20, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(21, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(22, 4, 1, 'erwerxzd', '2025-09-11', 'pending'),
(23, 4, 2, 'erwerxzd', '2025-09-11', 'pending'),
(24, 4, 3, 'erwerxzd', '2025-09-11', 'pending'),
(25, 4, 1, 'sdgsdg', '2025-09-11', 'approved'),
(26, 4, 2, 'sdgsdg', '2025-09-11', 'approved'),
(27, 4, 3, 'sdgsdg', '2025-09-11', 'approved');

-- --------------------------------------------------------

--
-- Table structure for table `donation`
--

CREATE TABLE `donation` (
  `donation_id` int(11) NOT NULL,
  `donated_by` int(11) DEFAULT NULL,
  `donation_date` date NOT NULL,
  `amount_given` decimal(12,2) DEFAULT NULL,
  `item_given` varchar(120) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `donation`
--

INSERT INTO `donation` (`donation_id`, `donated_by`, `donation_date`, `amount_given`, `item_given`) VALUES
(2, 6, '2025-09-10', 7811.00, NULL),
(3, 6, '2025-09-10', NULL, '3 11 fish'),
(4, 10, '2025-09-10', 4554.00, NULL),
(5, 10, '2025-09-10', 333.00, NULL),
(6, 10, '2025-09-10', 22.00, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `funds_total`
--

CREATE TABLE `funds_total` (
  `id` tinyint(4) NOT NULL DEFAULT 1,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `funds_total`
--

INSERT INTO `funds_total` (`id`, `total`, `updated_at`) VALUES
(1, 12720.00, '2025-09-10 15:22:44');

-- --------------------------------------------------------

--
-- Table structure for table `packages`
--

CREATE TABLE `packages` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `packages`
--

INSERT INTO `packages` (`id`, `name`, `description`) VALUES
(1, 'Basic Food Pack', 'Rice, lentils, oil, salt'),
(2, 'Hygiene Pack', 'Soap, sanitizer, masks'),
(3, 'Water Relief', 'Drinking water bottles');

-- --------------------------------------------------------

--
-- Table structure for table `package_items`
--

CREATE TABLE `package_items` (
  `package_id` int(11) NOT NULL,
  `item_name` varchar(120) NOT NULL,
  `unit` varchar(40) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `story`
--

CREATE TABLE `story` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `narrative` text NOT NULL,
  `before_path` varchar(255) NOT NULL,
  `after_path` varchar(255) NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `story`
--

INSERT INTO `story` (`id`, `title`, `narrative`, `before_path`, `after_path`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'story of anwara begum', 'a succesful farmer becomes the owner of 10lacs ', '1757512249_before_Screenshot (2).png', '1757512249_after_Screenshot (21).png', 9, '2025-09-10 13:50:49', '2025-09-10 13:50:49');

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `user_id` int(11) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `nid` varchar(100) NOT NULL,
  `age` int(11) NOT NULL,
  `type` enum('needy','volunteer','donor','admin') NOT NULL,
  `district` varchar(120) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `registration_date` date NOT NULL DEFAULT curdate(),
  `email` varchar(255) NOT NULL,
  `phone` varchar(40) NOT NULL,
  `lat` decimal(9,6) DEFAULT NULL,
  `lng` decimal(9,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`user_id`, `first_name`, `last_name`, `nid`, `age`, `type`, `district`, `password`, `registration_date`, `email`, `phone`, `lat`, `lng`) VALUES
(4, 'user', '1', '111222333', 88, 'needy', 'Bagerhat', '$2y$10$run3fdcw.SHlIRMctHCgBewNlotr1DFnS8geApxAOVux2OjH7k7Ku', '2025-09-10', 'mohammodroby117236@gmail.com', '01817755693', NULL, NULL),
(5, 'user', '2', '111222334', 33, 'needy', 'Bagerhat', '$2y$10$eII3XExGyaikXH66AUNQoujcLPOrLTBHAx9vbrUK6wVPv6wwCj/Uy', '2025-09-10', 'yasir@g.bracu.ac.bd', '41545484', NULL, NULL),
(6, 'userdon', '1', '777888999', 69, 'donor', 'Gazipur', '$2y$10$aNPXCpRwzGboxBC7Qpvky.X2ajDRLF2bF/iHxGllq6zNzItSGVx76', '2025-09-10', 'yasir0mahmud@gmail.com', '41545484', NULL, NULL),
(7, 'useraid', '3', '11223366', 66, 'needy', 'Bagerhat', '$2y$10$hdWsZlSZqghgGI39NVb0MupM7JQu1t57AGiEJxommQsdEF8N3Rpm2', '2025-09-10', 'furtigpt01@gmail.com', '41545484', NULL, NULL),
(8, 'user', 'volunteer 3', '444555666', 34, 'volunteer', 'Gopalganj', '$2y$10$9vuL.R2fe/7PGi1dvh0ZaerpxUHscFMUyMHpx2EKyEfKZeQYYMklC', '2025-09-10', 'mohammodroby11736@gmail.com', '41545484', 23.005000, 89.826000),
(9, 'user', 'admin', '9999999999', 30, 'admin', 'Dhaka', '$2y$10$/ZYE4za8MZLUxEDnSQ2dSezHqV3o7QETc9AOYI.cp7UyMGonsV7mW', '2025-09-10', 'admin@example.com', '01000000000', NULL, NULL),
(10, 'user', 'donor 3', '7778942254', 33, 'donor', 'Habiganj', '$2y$10$UgTCRjhygr5eXJXL4SG0Oedi7Qmi9GI581OWZyqdx1WyQNpLxaSyq', '2025-09-10', 'yasir0mahmud@gmail.com', '41545484', NULL, NULL),
(11, 'sds\\d', 'dssdd', '2314121312', 12, 'volunteer', 'Dhaka', '$2y$10$3rbxfJN0aVj2elRigC/WXe4MO6OC7mxq9aIM9nBckD2aNS4FQmx6G', '2025-09-11', 'yasir0mahmud@gmail.com', '01817755693', 23.780000, 90.407000);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `aid_item`
--
ALTER TABLE `aid_item`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `aid_request_item`
--
ALTER TABLE `aid_request_item`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ari_user` (`user_id`);

--
-- Indexes for table `aid_request_packages`
--
ALTER TABLE `aid_request_packages`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `fk_aid_req_user` (`user_id`),
  ADD KEY `fk_aid_req_package` (`package_id`);

--
-- Indexes for table `donation`
--
ALTER TABLE `donation`
  ADD PRIMARY KEY (`donation_id`),
  ADD KEY `fk_donation_user` (`donated_by`);

--
-- Indexes for table `funds_total`
--
ALTER TABLE `funds_total`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `packages`
--
ALTER TABLE `packages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `package_items`
--
ALTER TABLE `package_items`
  ADD PRIMARY KEY (`package_id`,`item_name`,`unit`);

--
-- Indexes for table `story`
--
ALTER TABLE `story`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_story_user` (`created_by`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `nid` (`nid`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `aid_item`
--
ALTER TABLE `aid_item`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `aid_request_item`
--
ALTER TABLE `aid_request_item`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `aid_request_packages`
--
ALTER TABLE `aid_request_packages`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `donation`
--
ALTER TABLE `donation`
  MODIFY `donation_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `packages`
--
ALTER TABLE `packages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `story`
--
ALTER TABLE `story`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `aid_request_item`
--
ALTER TABLE `aid_request_item`
  ADD CONSTRAINT `fk_ari_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `aid_request_packages`
--
ALTER TABLE `aid_request_packages`
  ADD CONSTRAINT `fk_aid_req_package` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`),
  ADD CONSTRAINT `fk_aid_req_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `donation`
--
ALTER TABLE `donation`
  ADD CONSTRAINT `fk_donation_user` FOREIGN KEY (`donated_by`) REFERENCES `user` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `package_items`
--
ALTER TABLE `package_items`
  ADD CONSTRAINT `fk_pi_pkg` FOREIGN KEY (`package_id`) REFERENCES `packages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `story`
--
ALTER TABLE `story`
  ADD CONSTRAINT `fk_story_user` FOREIGN KEY (`created_by`) REFERENCES `user` (`user_id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
