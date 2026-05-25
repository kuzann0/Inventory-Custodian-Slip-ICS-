-- Create a copy of the database
CREATE DATABASE `LATEST DATABASE COPY` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Copy all tables from my_app_db to the new database
USE `LATEST DATABASE COPY`;

-- Get the table creation statements from the original database
