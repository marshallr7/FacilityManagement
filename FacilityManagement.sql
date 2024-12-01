-- CREATE DATABASE FacilityManagement;
USE FacilityManagement;

DROP TABLE IF EXISTS FacilityUsage;
DROP TABLE IF EXISTS ClassEnrollment;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS EmployeeSchedule;
DROP TABLE IF EXISTS Equipment;
DROP TABLE IF EXISTS Member;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS MembershipType;
DROP TABLE IF EXISTS Facility;

CREATE TABLE Facility (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Location VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20), -- Changed to VARCHAR for consistency
    Email VARCHAR(255),
    OpenHour TIME NOT NULL,
    CloseHour TIME NOT NULL,
    FacilityType VARCHAR(255),
    CHECK (CloseHour > OpenHour) -- Ensures logical business hours
);

CREATE TABLE MembershipType (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    MonthlyFee DECIMAL(10, 2) NOT NULL,
    BenefitLevel VARCHAR(255) NOT NULL
);

CREATE TABLE Member (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    PhoneNumber VARCHAR(20),
    DateOfBirth DATE,
    JoinDate DATE NOT NULL,
    EndDate DATE,
    MembershipTypeRID INT NOT NULL,
    FOREIGN KEY (MembershipTypeRID) REFERENCES MembershipType(RID),
    INDEX idx_member_membership (MembershipTypeRID)
);

CREATE TABLE Employee (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    PhoneNumber VARCHAR(20),
    HireDate DATE NOT NULL,
    TerminationDate DATE,
    Position VARCHAR(255) NOT NULL,
    FacilityRID INT NOT NULL,
    SupervisorRID INT, -- Nullable in case the employee is the top level for their group
    FOREIGN KEY (FacilityRID) REFERENCES Facility(RID),
    FOREIGN KEY (SupervisorRID) REFERENCES Employee(RID),
    INDEX idx_employee_facility (FacilityRID)
);

CREATE TABLE FacilityUsage (
    UsageRID INT AUTO_INCREMENT PRIMARY KEY,
    MemberRID INT NOT NULL,
    FacilityRID INT NOT NULL,
    CheckIn TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    CheckOut TIMESTAMP,
    FOREIGN KEY (MemberRID) REFERENCES Member(RID),
    FOREIGN KEY (FacilityRID) REFERENCES Facility(RID),
    INDEX idx_usage_member (MemberRID),
    INDEX idx_usage_facility (FacilityRID)
);

CREATE TABLE Class (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    FacilityRID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Schedule TIMESTAMP NOT NULL,
    Capacity INT CHECK (Capacity >= 0), -- Ensures non-negative capacity
    FOREIGN KEY (FacilityRID) REFERENCES Facility(RID),
    INDEX idx_class_facility (FacilityRID)
);

CREATE TABLE ClassEnrollment (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    ClassRID INT NOT NULL,
    MemberRID INT, -- Nullable in case it's a free class that doesn't require membership
    EnrollmentDate DATE NOT NULL,
    FOREIGN KEY (ClassRID) REFERENCES Class(RID),
    FOREIGN KEY (MemberRID) REFERENCES Member(RID),
    INDEX idx_enrollment_class (ClassRID),
    INDEX idx_enrollment_member (MemberRID)
);

CREATE TABLE EmployeeSchedule (
    RID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeRID INT NOT NULL,
    FacilityRID INT NOT NULL,
    StartTime TIMESTAMP NOT NULL,
    EndTime TIMESTAMP NOT NULL,
    FOREIGN KEY (EmployeeRID) REFERENCES Employee(RID),
    FOREIGN KEY (FacilityRID) REFERENCES Facility(RID),
    INDEX idx_schedule_employee (EmployeeRID),
    INDEX idx_schedule_facility (FacilityRID)
);

CREATE TABLE Equipment (
    EquipmentRID INT AUTO_INCREMENT PRIMARY KEY,
    FacilityRID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    MaintenanceDate DATE,
    FOREIGN KEY (FacilityRID) REFERENCES Facility(RID),
    INDEX idx_equipment_facility (FacilityRID)
);


-- Test data
-- Test Data for Facility
INSERT INTO Facility (Name, Location, PhoneNumber, Email, OpenHour, CloseHour, FacilityType)
VALUES
('Downtown Fitness', '123 Main St, Cityville', '1234567890', 'info@downtownfitness.com', '06:00:00', '22:00:00', 'Gym'),
('Eastside Pool', '456 Elm St, Cityville', '9876543210', 'contact@eastsidepool.com', '07:00:00', '20:00:00', 'Pool'),
('Westside Sports Center', '789 Maple St, Cityville', '5551234567', 'info@westsidesports.com', '08:00:00', '21:00:00', 'Sports Complex');

-- Test Data for MembershipType
INSERT INTO MembershipType (Name, Description, MonthlyFee, BenefitLevel)
VALUES
('Basic', 'Access to gym and pool only', 30.00, 'Standard'),
('Premium', 'Access to all facilities and group classes', 60.00, 'High'),
('VIP', 'Access to all facilities, classes, and personal trainers', 100.00, 'Exclusive');

-- Test Data for Member
INSERT INTO Member (FirstName, LastName, Email, PhoneNumber, DateOfBirth, JoinDate, EndDate, MembershipTypeRID)
VALUES
('John', 'Doe', 'john.doe@example.com', '1112223333', '1990-01-15', '2024-01-01', NULL, 1),
('Jane', 'Smith', 'jane.smith@example.com', '4445556666', '1985-06-20', '2024-02-01', NULL, 2),
('Alice', 'Johnson', 'alice.johnson@example.com', '7778889999', '1992-11-05', '2024-03-01', NULL, 3),
('Phil', 'Stevenson', 'phil@example.com', '2233445566', '2000-01-01', '2024-02-14', NULL, 3);

-- Test Data for Employee
INSERT INTO Employee (FirstName, LastName, Email, PhoneNumber, HireDate, TerminationDate, Position, FacilityRID, SupervisorRID)
VALUES
('Bob', 'Williams', 'bob.williams@example.com', '2223334444', '2022-01-15', NULL, 'Manager', 1, NULL),
('Carol', 'Davis', 'carol.davis@example.com', '3334445555', '2023-05-20', NULL, 'Trainer', 1, 1),
('Eve', 'Wilson', 'eve.wilson@example.com', '4445556667', '2023-06-15', NULL, 'Receptionist', 2, 1),
('Frank', 'Brown', 'frank.brown@example.com', '5556667778', '2023-09-01', NULL, 'Lifeguard', 2, 3);

-- Test Data for FacilityUsage
INSERT INTO FacilityUsage (MemberRID, FacilityRID, CheckIn, CheckOut)
VALUES
(1, 1, '2024-11-20 08:00:00', '2024-11-20 10:00:00'),
(2, 2, '2024-11-20 12:00:00', '2024-11-20 14:00:00'),
(3, 1, '2024-11-20 18:00:00', '2024-11-20 20:00:00');

-- Test Data for Class
INSERT INTO Class (FacilityRID, Name, Description, Schedule, Capacity)
VALUES
(1, 'Yoga Basics', 'Beginner-level yoga class', '2024-11-21 10:00:00', 20),
(1, 'HIIT', 'High-intensity interval training', '2024-11-21 18:00:00', 15),
(2, 'Swim Lessons', 'Intermediate swimming class', '2024-11-22 15:00:00', 10);

-- Test Data for ClassEnrollment
INSERT INTO ClassEnrollment (ClassRID, MemberRID, EnrollmentDate)
VALUES
(1, 1, '2024-11-15'),
(2, 2, '2024-11-16'),
(3, 3, '2024-11-17');

-- Test Data for EmployeeSchedule
INSERT INTO EmployeeSchedule (EmployeeRID, FacilityRID, StartTime, EndTime)
VALUES
(1, 1, '2024-11-21 08:00:00', '2024-11-21 16:00:00'),
(2, 1, '2024-11-21 16:00:00', '2024-11-21 22:00:00'),
(3, 2, '2024-11-22 07:00:00', '2024-11-22 15:00:00'),
(4, 2, '2024-11-22 15:00:00', '2024-11-22 22:00:00');

-- Test Data for Equipment
INSERT INTO Equipment (FacilityRID, Name, Description, MaintenanceDate)
VALUES
(1, 'Treadmill', 'High-performance running treadmill', '2024-11-01'),
(1, 'Bench Press', 'Weight bench for chest exercises', '2024-10-15'),
(2, 'Pool Heater', 'Heater for maintaining pool temperature', '2024-09-25');


-- Example queries:

-- 1. Simple SELECT Query
-- Retrieve all members who joined after January 1, 2024.
SELECT FirstName, LastName, JoinDate 
FROM Member
WHERE JoinDate > '2024-01-01';

-- 2. JOIN Query
-- Get a list of all classes with their associated facilities' names and locations.
SELECT 
    Class.Name AS ClassName,
    Facility.Name AS FacilityName,
    Facility.Location AS FacilityLocation
FROM Class
INNER JOIN Facility ON Class.FacilityRID = Facility.RID;

-- 3. Aggregate Query
-- Count the number of members enrolled in each membership type.
SELECT 
    MembershipType.Name AS MembershipType,
    COUNT(Member.RID) AS TotalMembers
FROM Member
INNER JOIN MembershipType ON Member.MembershipTypeRID = MembershipType.RID
GROUP BY MembershipType.Name;

-- 4. Nested Query
-- Find all members who attended a class on or after November 15, 2024.
SELECT DISTINCT FirstName, LastName
FROM Member
WHERE RID IN (
    SELECT MemberRID 
    FROM ClassEnrollment
    WHERE EnrollmentDate >= '2024-11-15'
);

-- 5. UPDATE Query
-- Update the email of an employee by their ID.
SELECT * FROM Employee Where RID = 1; -- for data display
UPDATE Employee
SET Email = 'new.example.email@example.com'
WHERE RID = 1;
SELECT * FROM Employee Where RID = 1; -- for data display

-- 6. DELETE Query
-- Remove all facility usage records for a member with ID 1.
SELECT * FROM FacilityUsage; -- for data display
DELETE FROM FacilityUsage
WHERE MemberRID = 1;
SELECT * FROM FacilityUsage; -- for data display

-- 7. Complex Query with Multiple JOINS
-- List all employees, their supervisors (if applicable), and the facilities they work at.
SELECT 
    E.FirstName AS EmployeeFirstName,
    E.LastName AS EmployeeLastName,
    Supervisor.FirstName AS SupervisorFirstName,
    Supervisor.LastName AS SupervisorLastName,
    Facility.Name AS FacilityName
FROM Employee E
LEFT JOIN Employee Supervisor ON E.SupervisorRID = Supervisor.RID
INNER JOIN Facility ON E.FacilityRID = Facility.RID;


-- 8. Date Range Query
-- Retrieve all facility usages that occurred in November 2024.
SELECT 
    Facility.Name AS FacilityName,
    Member.FirstName AS MemberFirstName,
    Member.LastName AS MemberLastName,
    FacilityUsage.CheckIn, 
    FacilityUsage.CheckOut
FROM FacilityUsage
INNER JOIN Facility ON FacilityUsage.FacilityRID = Facility.RID
INNER JOIN Member ON FacilityUsage.MemberRID = Member.RID
WHERE FacilityUsage.CheckIn BETWEEN '2024-11-01' AND '2024-11-30';

-- 9. Query with Subquery and Calculations
-- Find the total monthly fee collected from all members grouped by membership type.
SELECT 
    MembershipType.Name AS MembershipType,
    SUM(MembershipType.MonthlyFee) AS TotalCollected
FROM Member
INNER JOIN MembershipType ON Member.MembershipTypeRID = MembershipType.RID
GROUP BY MembershipType.Name;


CREATE VIEW `ActiveMembersView` AS
	SELECT
		m.RID AS MemberRID,
		m.FirstName,
		m.LastName,
		m.Email,
		mt.RID AS MembershipTypeRID,
		mt.Name AS MembershipType,
		mt.MonthlyFee,
		f.RID AS LastFactilityUsedRID,
		f.Name AS LastFacilityUsed,
		m.JoinDate
	FROM Member m
	JOIN MembershipType mt ON m.MembershipTypeRID = mt.RID
	JOIN FacilityUsage fusage ON m.RID = fusage.MemberRID
	JOIN Facility f ON fusage.FacilityRID = f.RID
	WHERE m.EndDate IS NULL OR m.EndDate > CURDATE();


CREATE VIEW `MembershipSummaryView` AS
	SELECT
		mt.Name AS MembershipType,
		COUNT(m.RID) AS TotalMembers,
		SUM(mt.MonthlyFee) AS TotalMonthlyRevenue
	FROM MembershipType mt
	LEFT JOIN Member m ON mt.RID = m.MembershipTypeRID
	GROUP BY mt.RID, mt.Name;
	
	
CREATE VIEW `FacilityUsageView` AS
	SELECT
		f.Name AS FacilityName,
		m.RID AS MemberRID,
		m.FirstName,
		m.LastName,
		fusage.CheckIn AS CheckedInAt,
		fusage.CheckOut AS CheckedOutAt,
		mt.Name AS MembershipType
	FROM FacilityUsage fusage
	JOIN Facility f ON fusage.FacilityRID = f.RID
	JOIN Member m ON fusage.MemberRID = m.RID
	JOIN MembershipType mt ON m.MembershipTypeRID = mt.RID
	ORDER BY CheckedInAt DESC;


CREATE VIEW `ClassSummaryView` AS
	SELECT
		c.Name AS ClassName,
		c.Description,
		c.Schedule,
		c.Capacity,
		f.Name AS FacilityName,
		f.Location AS FacilityLocation,
		COUNT(ce.MemberRID) AS EnrolledMembers
	FROM Class c
	JOIN Facility f ON c.FacilityRID = f.RID
	JOIN ClassEnrollment ce ON c.RID = ce.ClassRID
	GROUP BY 
		c.RID,
		c.Name,
		c.Description,
		c.Schedule,
		c.Capacity,
		f.Name,
		f.Location;



DELIMITER //

CREATE TRIGGER validate_class_capacity
BEFORE INSERT ON ClassEnrollment
FOR EACH ROW
BEGIN
    DECLARE current_enrollment INT;
    DECLARE class_capacity INT;

    SELECT COUNT(*) INTO current_enrollment
    FROM ClassEnrollment
    WHERE ClassRID = NEW.ClassRID;

    SELECT Capacity INTO class_capacity
    FROM Class
    WHERE RID = NEW.ClassRID;

    IF current_enrollment >= class_capacity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Class capacity exceeded.';
    END IF;
END

DELIMITER //



DELIMITER //

CREATE TRIGGER validate_membership_validity
BEFORE INSERT ON FacilityUsage
FOR EACH ROW
BEGIN
    DECLARE membership_end_date DATE;

    -- Get the member's membership end date
    SELECT EndDate INTO membership_end_date
    FROM Member
    WHERE RID = NEW.MemberRID;

    -- Check if the membership is expired
    IF membership_end_date < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Membership is not valid. Please renew membership.';
    END IF;
END$$

DELIMITER //