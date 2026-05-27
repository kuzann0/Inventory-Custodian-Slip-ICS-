-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Mar 21, 2026 at 02:55 AM
-- Server version: 5.7.44
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `my_app_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `entries`
--

CREATE TABLE `entries` (
  `order_id` int(11) NOT NULL,
  `Quantity` int(11) DEFAULT NULL,
  `Unit` varchar(50) DEFAULT NULL,
  `Amount` decimal(10,2) DEFAULT NULL,
  `UnitCost` decimal(10,2) DEFAULT NULL,
  `TotalCost` decimal(10,2) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Item` varchar(100) DEFAULT NULL,
  `SerialNo` varchar(100) DEFAULT NULL,
  `DateAcquired` date DEFAULT NULL,
  `Location` varchar(100) DEFAULT NULL,
  `InventoryItemNo` varchar(50) DEFAULT NULL,
  `EstimatedUsefulLife` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `entries`
--

INSERT INTO `entries` (`order_id`, `Quantity`, `Unit`, `Amount`, `UnitCost`, `TotalCost`, `Description`, `Item`, `SerialNo`, `DateAcquired`, `Location`, `InventoryItemNo`, `EstimatedUsefulLife`) VALUES
(1, 10, 'set', 5000.00, 5000.00, 10000.00, 'TESTING', 'Waste Basket', 'S9583SC', '2026-03-23', '10th Floor', 'IIN9432SCG', '5'),
(2, 10, 'set', 5000.00, 5000.00, 10000.00, 'TESTING', 'Standard, Staper', 'S9684SC', '2026-03-23', '10th Floor', 'IIN9533SCG', '5');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `entries`
--
ALTER TABLE `entries`
  ADD PRIMARY KEY (`order_id`),
  ADD UNIQUE KEY `unique_serial` (`SerialNo`),
  ADD UNIQUE KEY `unique_inventory` (`InventoryItemNo`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `entries`
--
ALTER TABLE `entries`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
