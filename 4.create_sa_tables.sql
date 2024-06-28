-- CREATE DATABASE Staging_EmployeeManagement;
-- GO

-- DROP DATABASE Staging_EmployeeManagement;

USE Staging_EmployeeManagement;
GO

-- Staging Tables
CREATE TABLE Employees (
    EmployeeID INT,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender CHAR(20),
    DepartmentID INT,
    Birthday DATE,
    PhoneNumber NVARCHAR(15),
    StartDate DATE,
    EndDate DATE,
    BirthCity INT
);

CREATE TABLE Projects (
    ProjectID INT,
    ProjectName NVARCHAR(100),
    Description NVARCHAR(MAX),
    StartDate DATE,
    EndDate DATE,
    Status CHAR(20),
    Advisor INT,
);

CREATE TABLE Tasks (
    TaskID INT,
    TaskName NVARCHAR(100),
    ProjectID INT,
    AssignedTo INT,
    StartDate DATE,
    EndDate DATE,
    Description NVARCHAR(MAX)
);

CREATE TABLE TimeEntries (
    TimeEntryID INT,
    TaskID INT,
    EmployeeID INT,
    HoursWorked DECIMAL(5, 2),
    EntryDate DATE
);

CREATE TABLE Departments (
    DepartmentID INT,
    Name NVARCHAR(50),
    MaxEmployeeSize INT
);

CREATE TABLE Cities (
    CityID INT,
    Name NVARCHAR(50),
    Country NVARCHAR(50)
);
