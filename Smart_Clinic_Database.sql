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
-- Doctor is a subtype of Staff.
CREATE TABLE doctors (  
staff_id      INT PRIMARY KEY,     specialty    
  VARCHAR(80) NOT NULL,     license_number   
  VARCHAR(30) NOT NULL UNIQUE,  
  consultation_fee DECIMAL(10,2) NOT NULL CHECK (consultation_fee >= 0),  
  CONSTRAINT fk_doctor_staff         FOREIGN KEY (staff_id) REFERENCES staff(staff_id)  
  ON UPDATE CASCADE ON DELETE CASCADE );
-- Nurse is a subtype of Staff.
CREATE TABLE nurses (  
staff_id        
INT PRIMARY KEY,     grade_level 
  VARCHAR(30) NOT NULL,     shift_name  
  ENUM('MORNING','EVENING','NIGHT') NOT NULL,
  CONSTRAINT fk_nurse_staff    
  FOREIGN KEY (staff_id) REFERENCES staff(staff_id)  
  ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE appointments (
 appointment_id INT PRIMARY KEY,
 patient_id INT NOT NULL,
 doctor_id INT NOT NULL,
 appointment_datetime DATETIME NOT NULL,
 reason VARCHAR(255) NOT NULL,
 status ENUM('SCHEDULED','COMPLETED','CANCELLED') NOT NULL DEFAULT 'SCHEDULED',
 payment_status ENUM('UNPAID','PARTIALLY_PAID','PAID') NOT NULL DEFAULT 'UNPAID',
 CONSTRAINT uq_doctor_slot UNIQUE (doctor_id, appointment_datetime),
 CONSTRAINT fk_appointment_patient
 FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
 ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT fk_appointment_doctor
 FOREIGN KEY (doctor_id) REFERENCES doctors(staff_id)
 ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE treatments (
 treatment_id INT PRIMARY KEY,
 appointment_id INT NOT NULL UNIQUE,
 diagnosis VARCHAR(255) NOT NULL,
 procedure_name VARCHAR(150) NOT NULL,
 treatment_notes TEXT,
 treatment_cost DECIMAL(10,2) NOT NULL CHECK (treatment_cost >= 0),
 CONSTRAINT fk_treatment_appointment
 FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
 ON UPDATE CASCADE ON DELETE CASCADE
)
