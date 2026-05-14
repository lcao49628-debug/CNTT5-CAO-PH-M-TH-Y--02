CREATE DATABASE Ktracuoimuon02;
USE Ktracuoimon02;
 
 -- PHẦN 1: 
 -- TẠO BẢNG
CREATE TABLE Customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    join_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE Insurance_Packages (
    package_id VARCHAR(10) PRIMARY KEY,
    package_name VARCHAR(150) NOT NULL,
    max_limit DECIMAL(15,2) NOT NULL CHECK (max_limit > 0),
    base_premium DECIMAL(15,2) NOT NULL CHECK (base_premium > 0)
);

CREATE TABLE Policies (
    policy_id VARCHAR(10) PRIMARY KEY,
    customer_id VARCHAR(10) NOT NULL,
    package_id VARCHAR(10) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('Active', 'Expired', 'Cancelled') DEFAULT 'Active',
    
    CONSTRAINT fk_policy_customer
        FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    CONSTRAINT fk_policy_package
        FOREIGN KEY (package_id)
        REFERENCES Insurance_Packages(package_id),

    CONSTRAINT chk_policy_date
        CHECK (end_date > start_date )
);

CREATE TABLE Claims (
    claim_id VARCHAR(10) PRIMARY KEY,
    policy_id VARCHAR(10) NOT NULL,
    claim_date DATE NOT NULL,
    claim_amount DECIMAL(15,2) NOT NULL CHECK (claim_amount > 0),
    status ENUM('Pending', 'Approved', 'Rejected') DEFAULT 'Pending',

    CONSTRAINT fk_claim_policy
        FOREIGN KEY (policy_id)
        REFERENCES Policies(policy_id)
);

CREATE TABLE Claim_Processing_Log (
    log_id VARCHAR(10) PRIMARY KEY,
    claim_id VARCHAR(10) NOT NULL,
    action_detail VARCHAR(255) NOT NULL,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    processor VARCHAR(100),

    CONSTRAINT fk_log_claim
        FOREIGN KEY (claim_id)
        REFERENCES Claims(claim_id)
);

INSERT INTO Customers (customer_id, full_name,phone_number,email,join_date)
VALUES
('C001', 'Nguyen Hoang Long', '0901112223', 'long.nh@gmail.com', '2024-01-15'),
('C002', 'Tran Thi Kim Anh', '0988877766', 'anh.tk@yahoo.com', '2024-03-10'),
('C003', 'Le Hoang Nam', '0903334445', 'nam.lh@outlook.com', '2025-05-20'),
('C004', 'Pham Minh Duc', '0355556667', 'duc.pm@gmail.com', '2025-08-12'),
('C005', 'Hoang Thu Thao', '0779998881', 'thao.ht@gmail.com', '2026-05-01');

INSERT INTO Insurance_Packages (package_id,package_name,max_limit,base_premium)
VALUES
('PKG01', 'Bao hiem Suc khoe Gold', 500000000, 5000000),
('PKG02', 'Bao hiem O to Liberty', 1000000000, 15000000),
('PKG03', 'Bao hiem Nhan tho An Binh', 2000000000, 25000000),
('PKG04', 'Bao hiem Du lich Quoc te', 100000000, 1000000),
('PKG05', 'Bao hiem Tai nan 24/7', 200000000, 2500000);

INSERT INTO Policies (policy_id,customer_id,package_id,start_date,end_date,status)
VALUES
('POL101', 'C001', 'PKG01', '2024-01-15', '2025-01-15', 'Expired'),
('POL102', 'C002', 'PKG02', '2024-03-10', '2026-03-10', 'Active'),
('POL103', 'C003', 'PKG03', '2025-05-20', '2035-05-20', 'Active'),
('POL104', 'C004', 'PKG04', '2025-08-12', '2025-09-12', 'Expired'),
('POL105', 'C005', 'PKG01', '2026-01-01', '2027-01-01', 'Active');

INSERT INTO Claims (claim_id, policy_id,claim_date,claim_amount,status)
VALUES
('CLM901', 'POL102', '2024-06-15', 12000000, 'Approved'),
('CLM902', 'POL103', '2025-10-20', 50000000, 'Pending'),
('CLM903', 'POL101', '2024-11-05', 5500000, 'Approved'),
('CLM904', 'POL105', '2026-01-15', 2000000, 'Rejected'),
('CLM905', 'POL102', '2025-02-10', 120000000, 'Approved');

INSERT INTO Claim_Processing_Log (log_id,claim_id,action_detail,recorded_at,processor)
VALUES
('L001', 'CLM901', 'Da nhan ho so hien truong', '2024-06-15 09:00:00', 'Admin_01'),
('L002', 'CLM901', 'Chap nhan boi thuong xe tai nan', '2024-06-20 14:30:00', 'Admin_01'),
('L003', 'CLM902', 'Dang tham dinh ho so benh an', '2025-10-21 10:00:00', 'Admin_02'),
('L004', 'CLM904', 'Tu choi do loi co y cua khach hang', '2026-01-16 16:00:00', 'Admin_03'),
('L005', 'CLM905', 'Da thanh toan qua chuyen khoan', '2025-02-15 08:30:00', 'Accountant_01');

-- CÂU 1:
UPDATE Insurance_Packages
SET base_premium = base_premium * 1.15
WHERE max_limit > 500000000;

-- Câu 2:
DELETE FROM Claim_Processing_Log
WHERE recorded_at < '2025-06-17';

-- PHẦN 2:
-- Câu 1:
SELECT *
FROM Policies
WHERE status = 'Active'AND YEAR(end_date) = 2026;

-- CÂU 2:
SELECT
    full_name,
    email
FROM Customers
WHERE full_name LIKE '%Hoang%'AND YEAR(join_date) >= 2025;

-- CÂU 3:
SELECT *
FROM Claims
ORDER BY claim_amount DESC
LIMIT 3 OFFSET 1;

-- PHẦN 3: 
-- CÂU 1:
SELECT
    c.full_name,
    ip.package_name,
    p.start_date,
    cl.claim_amount
FROM Customers c
JOIN Policies p 
ON c.customer_id = p.customer_id
JOIN Insurance_Packages ip 
ON p.package_id = ip.package_id
LEFT JOIN Claims cl
    ON p.policy_id = cl.policy_id;

-- CÂU 2:
SELECT
    c.full_name,
    SUM(cl.claim_amount) AS total_approved_claim
FROM Customers c
JOIN Policies p
    ON c.customer_id = p.customer_id
JOIN Claims cl
    ON p.policy_id = cl.policy_id
WHERE cl.status = 'Approved'
GROUP BY c.customer_id, c.full_name
HAVING SUM(cl.claim_amount) > 50000000;

-- CÂU 3:
SELECT
    ip.package_id,
    ip.package_name,
    COUNT(p.policy_id) AS total_customers
FROM Insurance_Packages ip
JOIN Policies p
    ON ip.package_id = p.package_id
GROUP BY ip.package_id, ip.package_name
ORDER BY total_customers DESC
LIMIT 1;

-- PHẦN 4:
-- CÂU 1:
CREATE INDEX idx_policy_status_date
ON Policies(status, start_date);

-- CÂU 2:
CREATE VIEW vw_customer_summary AS
SELECT
    c.full_name,
    COUNT(p.policy_id) AS total_policies,
    SUM(ip.base_premium) AS total_base_premium
FROM Customers c
LEFT JOIN Policies p
    ON c.customer_id = p.customer_id
LEFT JOIN Insurance_Packages ip
    ON p.package_id = ip.package_id
GROUP BY c.customer_id, c.full_name;

SELECT * FROM vw_customer_summary;

-- Phần 5:
-- Câu 1: