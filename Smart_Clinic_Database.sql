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
 staff_id      INT PRIMARY KEY,
 specialty    VARCHAR(80) NOT NULL,
 license_number   VARCHAR(30) NOT NULL UNIQUE,  
 consultation_fee DECIMAL(10,2) NOT NULL CHECK (consultation_fee >= 0),  
   CONSTRAINT fk_doctor_staff
     FOREIGN KEY (staff_id) REFERENCES staff(staff_id)  
     ON UPDATE CASCADE ON DELETE CASCADE
 );

-- Nurse is a subtype of Staff.
CREATE TABLE nurses (  
 staff_id        INT PRIMARY KEY,
  grade_level VARCHAR(30) NOT NULL,
  shift_name  ENUM('MORNING','EVENING','NIGHT') NOT NULL,
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
);


CREATE TABLE medicines ( 
    medicine_id       INT PRIMARY KEY, 
    medicine_name     VARCHAR(120) NOT NULL UNIQUE, 
    dosage_form       VARCHAR(50) NOT NULL, 
    unit_price        DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0), 
    stock_quantity    INT NOT NULL CHECK (stock_quantity >= 0) 
); 

 

CREATE TABLE prescriptions ( 
    prescription_id   INT PRIMARY KEY, 
    treatment_id      INT NOT NULL, 
    prescribed_date   DATE NOT NULL, 
    instructions      VARCHAR(255), 
    CONSTRAINT fk_prescription_treatment 
        FOREIGN KEY (treatment_id) REFERENCES treatments(treatment_id) 
        ON UPDATE CASCADE ON DELETE CASCADE 
); 

 

CREATE TABLE prescription_items ( 
    prescription_id   INT NOT NULL, 
    medicine_id       INT NOT NULL, 
    dosage            VARCHAR(50) NOT NULL, 
    frequency         VARCHAR(80) NOT NULL, 
    duration_days     INT NOT NULL CHECK (duration_days > 0), 
    quantity          INT NOT NULL CHECK (quantity > 0), 
    PRIMARY KEY (prescription_id, medicine_id), 
    CONSTRAINT fk_item_prescription 
        FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id) 
        ON UPDATE CASCADE ON DELETE CASCADE, 
    CONSTRAINT fk_item_medicine 
        FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id) 
        ON UPDATE CASCADE ON DELETE RESTRICT 
); 
CREATE TABLE payments ( 
 payment_id        INT PRIMARY KEY,
 appointment_id    INT NOT NULL,
 payment_date      DATETIME NOT NULL,
 amount            DECIMAL(10,2) NOT NULL CHECK
 (amount > 0),     payment_method    ENUM('CASH','CARD','TRANSFER') NOT NULL,
 reference_number  VARCHAR(50) UNIQUE,  
 payment_status    ENUM('COMPLETED','REFUNDED') NOT NULL DEFAULT 'COMPLETED', 
 CONSTRAINT fk_payment_appointment    
 FOREIGN KEY (appointment_id) REFERENCES 
 appointments(appointment_id)         ON UPDATE CASCADE ON DELETE RESTRICT 
 );  
CREATE TABLE appointment_status_log (
 log_id             INT AUTO_INCREMENT PRIMARY KEY, 
 appointment_id     INT NOT NULL, 
 old_status         VARCHAR(20) NOT NULL,
 new_status         VARCHAR(20) NOT NULL, 
 changed_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
 CONSTRAINT fk_status_log_appointment 
 FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) 
 ON UPDATE CASCADE ON DELETE CASCADE 
);
