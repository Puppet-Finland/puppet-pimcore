DROP   DATABASE IF EXISTS pimcore;
CREATE DATABASE pimcore charset=utf8mb4;

DROP   USER IF EXISTS 'pimcore'@'localhost';
CREATE USER 'pimcore'@'localhost' IDENTIFIED BY 'supersecret';

GRANT ALL ON `pimcore`.* TO 'pimcore'@'localhost';
