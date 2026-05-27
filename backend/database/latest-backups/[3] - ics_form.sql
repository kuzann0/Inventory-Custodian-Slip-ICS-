CREATE TABLE `ics_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pr_id` int(11) DEFAULT NULL,
  `pr_no` varchar(100) DEFAULT NULL,
  `ics_entry_no` varchar(50) NOT NULL,
  `sp_value` enum('SPLV','SPHV') NOT NULL,
  `location_code` varchar(10) DEFAULT NULL,
  `items` json DEFAULT NULL,  -- store the full items array
  `total_amount` decimal(15,2) DEFAULT NULL,
  `received_from` varchar(255) DEFAULT NULL,
  `received_by` varchar(255) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `approved_by_position` varchar(100) DEFAULT NULL,
  `property_no` varchar(100) DEFAULT NULL,
  `estimated_useful_life` varchar(50) DEFAULT NULL,
  `remarks` text,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);