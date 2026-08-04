-- ============================================================ 
-- IT244 - Introduction to Database 
-- Smart Clinic Database System 
-- DBMS: MySQL 8.0+ 
-- ============================================================ 

 

DROP DATABASE IF EXISTS smart_clinic_db; 
CREATE DATABASE smart_clinic_db 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci; 
USE smart_clinic_db; 

 

-- ============================================================ 
-- 1. TABLE CREATION 
-- ============================================================ 

 

CREATE TABLE patients ( 
    patient_id       INT PRIMARY KEY, 
    national_id      VARCHAR(20) NOT NULL UNIQUE, 
    first_name       VARCHAR(50) NOT NULL, 
    last_name        VARCHAR(50) NOT NULL, 
    gender           ENUM('M','F') NOT NULL, 
    date_of_birth    DATE NOT NULL, 
    phone            VARCHAR(20) NOT NULL UNIQUE, 
    blood_type       VARCHAR(3), 
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP 
); 

 

-- Staff is the supertype in the EER specialization. 
CREATE TABLE staff ( 
    staff_id         INT PRIMARY KEY, 
    first_name       VARCHAR(50) NOT NULL, 
    last_name        VARCHAR(50) NOT NULL, 
    phone            VARCHAR(20) NOT NULL UNIQUE, 
    email            VARCHAR(100) NOT NULL UNIQUE, 
    hire_date        DATE NOT NULL, 
    staff_type       ENUM('DOCTOR','NURSE') NOT NULL 
); 
