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
-- ============================================================
-- 2. DATA INSERTION (AT LEAST FIVE RECORDS IN MAIN TABLES)
-- ============================================================
INSERT INTO patients
(patient_id, national_id, first_name, last_name, gender, date_of_birth, phone, blood_type)
VALUES
(1, '1010000001', 'Ahmed', 'Al-Harbi', 'M', '1990-04-12', '0500000001', 'A+'),
(2, '1010000002', 'Sara', 'Al-Qahtani', 'F', '1988-11-05', '0500000002', 'O+'),
(3, '1010000003', 'Omar', 'Al-Shammari', 'M', '1979-06-23', '0500000003', 'B+'),
(4, '1010000004', 'Laila', 'Al-Zahrani', 'F', '1995-02-14', '0500000004', 'AB+'),
(5, '1010000005', 'Youssef','Al-Dosari', 'M', '2001-09-30', '0500000005', 'O-'),
(6, '1010000006', 'Huda', 'Al-Mutairi', 'F', '1968-12-08', '0500000006', 'A-');
INSERT INTO staff
(staff_id, first_name, last_name, phone, email, hire_date, staff_type)
VALUES
(101, 'Fahad', 'Al-Salem', '0551000001', 'fahad.salem@clinic.sa', '2018-01-15', 'DOCTOR'),
(102, 'Mona', 'Al-Rashid', '0551000002', 'mona.rashid@clinic.sa', '2019-03-10', 'DOCTOR'),
(103, 'Khalid', 'Al-Anazi', '0551000003', 'khalid.anazi@clinic.sa','2020-06-01', 'DOCTOR'),
(104, 'Reem', 'Al-Sayed', '0551000004', 'reem.sayed@clinic.sa', '2017-09-20', 'DOCTOR'),
(105, 'Nasser', 'Al-Ghamdi', '0551000005', 'nasser.ghamdi@clinic.sa','2021-02-14','DOCTOR'),
(201, 'Abeer', 'Al-Hassan', '0552000001', 'abeer.hassan@clinic.sa','2020-01-05', 'NURSE'),
(202, 'Majed', 'Al-Otaibi', '0552000002', 'majed.otaibi@clinic.sa','2018-11-11', 'NURSE'),
(203, 'Noor', 'Al-Yami', '0552000003', 'noor.yami@clinic.sa', '2022-04-18', 'NURSE'),
(204, 'Rakan', 'Al-Qahtani', '0552000004', 'rakan.qahtani@clinic.sa','2019-07-07','NURSE'),
(205, 'Hanan', 'Al-Malki', '0552000005', 'hanan.malki@clinic.sa', '2021-10-25', 'NURSE');
INSERT INTO doctors (staff_id, specialty, license_number, consultation_fee)
VALUES
(101, 'Cardiology', 'MED-1001', 250.00),
(102, 'Dermatology', 'MED-1002', 200.00),
(103, 'Pediatrics', 'MED-1003', 180.00),
(104, 'Orthopedics', 'MED-1004', 220.00),
(105, 'General Medicine', 'MED-1005', 150.00);
INSERT INTO nurses (staff_id, grade_level, shift_name)
VALUES
(201, 'Senior', 'MORNING'),
(202, 'Senior', 'EVENING'),
(203, 'Junior', 'MORNING'),
(204, 'Junior', 'NIGHT'),
(205, 'Senior', 'NIGHT');

INSERT INTO appointments 
(appointment_id, patient_id, doctor_id, appointment_datetime, reason, status, payment_status) 
VALUES 
(1001, 1, 101, '2026-07-20 09:00:00', 'Chest pain and high blood pressure', 'COMPLETED', 'PAID'), 
(1002, 2, 102, '2026-07-20 10:00:00', 'Persistent skin rash',               'COMPLETED', 'PAID'), 
(1003, 3, 105, '2026-07-21 11:30:00', 'Fatigue and dizziness',             'COMPLETED', 'PARTIALLY_PAID'), 
(1004, 4, 104, '2026-07-22 14:00:00', 'Knee pain after exercise',          'COMPLETED', 'PAID'), 
(1005, 5, 103, '2026-07-23 09:30:00', 'Fever and sore throat',             'COMPLETED', 'PAID'), 
(1006, 6, 101, '2026-07-24 13:00:00', 'Cardiology follow-up',              'COMPLETED', 'PAID'), 
(1007, 1, 105, '2026-07-25 16:00:00', 'Annual health check',               'CANCELLED', 'UNPAID'), 
(1008, 2, 102, '2026-07-26 10:30:00', 'Dermatology follow-up',             'SCHEDULED', 'UNPAID'); 


INSERT INTO treatments 
(treatment_id, appointment_id, diagnosis, procedure_name, treatment_notes, treatment_cost) 
VALUES 
(5001, 1001, 'Hypertension',             'ECG and clinical examination', 'Low-sodium diet and follow-up in four weeks.', 400.00), 
(5002, 1002, 'Atopic eczema',            'Skin examination',             'Use prescribed cream and avoid irritants.',    250.00), 
(5003, 1003, 'Iron-deficiency anemia',   'Blood test review',             'Increase iron-rich foods and repeat CBC.',     300.00), 
(5004, 1004, 'Early knee osteoarthritis','Knee X-ray and examination',    'Physiotherapy and reduced high-impact activity.',350.00), 
(5005, 1005, 'Viral upper respiratory infection','Pediatric evaluation','Rest, fluids, and monitor temperature.',         180.00), 
(5006, 1006, 'Stable cardiac arrhythmia','Follow-up ECG',                 'Continue medication and return in six weeks.', 300.00); 
INSERT INTO medicines
 (medicine_id, medicine_name, dosage_form, unit_price, stock_quantity)
 VALUES (301, 'Amlodipine 5 mg',       'Tablet', 18.50, 120),
 (302, 'Hydrocortisone 1%',     'Cream',  22.00,  65),
 (303, 'Ferrous Sulfate 200 mg','Tablet', 15.75,  90),
 (304, 'Paracetamol 500 mg',    'Tablet',  8.00, 200),
 (305, 'Diclofenac Gel',        'Gel',    19.50,  70),
 (306, 'Saline Nasal Spray',    'Spray',  12.25,  80);
INSERT INTO prescriptions
 (prescription_id, treatment_id, prescribed_date, instructions)
 VALUES (7001, 5001, '2026-07-20', 'Take after breakfast and monitor blood pressure.'),
 (7002, 5002, '2026-07-20', 'Apply a thin layer twice daily.'), 
 (7003, 5003, '2026-07-21', 'Take with food; avoid tea for two hours.'), 
 (7004, 5004, '2026-07-22', 'Apply to the painful area and begin physiotherapy.'),
 (7005, 5005, '2026-07-23', 'Use only when fever or pain is present.'); 
INSERT INTO prescription_items (prescription_id, medicine_id, dosage, frequency, duration_days, quantity)
 VALUES
 (7001, 301, '5 mg',        'Once daily',               30, 30),
 (7002, 302, 'Thin layer',  'Twice daily',              10,  1), 
 (7003, 303, '200 mg',      'Once daily',               30, 30),
 (7004, 305, 'Small amount','Three times daily',        14,  1), 
 (7004, 304, '500 mg',      'Every 8 hours if needed',   5, 15), 
 (7005, 304, '500 mg',      'Every 8 hours if needed',   3, 10),
 (7005, 306, 'Two sprays',  'Three times daily',         5,  1),
 (7003, 304, '500 mg',      'Once daily if headache',    5,  5); 
