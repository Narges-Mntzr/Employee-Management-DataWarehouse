-- CREATE DATABASE EmployeeManagement;
-- GO

-- DROP DATABASE EmployeeManagement;

USE EmployeeManagement;
GO

-- Departments Table
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50),
    MaxEmployeeSize INT
);

-- Cities Table
CREATE TABLE Cities (
    CityID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50),
    Country NVARCHAR(50)
);

-- Employees Table
CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    DepartmentID INT,
    Birthday DATE,
    PhoneNumber NVARCHAR(15),
    StartDate DATE,
    EndDate DATE,
    BirthCity INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    FOREIGN KEY (BirthCity) REFERENCES Cities(CityID)
);

-- Projects Table
CREATE TABLE Projects (
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName NVARCHAR(100),
    Description NVARCHAR(MAX),
    StartDate DATE,
    EndDate DATE,
    Status CHAR(20) NOT NULL CHECK (Status IN ('In Progress', 'Completed')),
    Advisor INT,
    FOREIGN KEY (Advisor) REFERENCES Employees(EmployeeID)
);

-- Tasks Table
CREATE TABLE Tasks (
    TaskID INT IDENTITY(1,1) PRIMARY KEY,
    TaskName NVARCHAR(100),
    ProjectID INT,
    AssignedTo INT,
    StartDate DATE,
    EndDate DATE,
    Description NVARCHAR(MAX),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (AssignedTo) REFERENCES Employees(EmployeeID)
);


-- TimeEntries Table
CREATE TABLE TimeEntries (
    TimeEntryID INT IDENTITY(1,1) PRIMARY KEY,
    TaskID INT,
    EmployeeID INT,
    HoursWorked DECIMAL(5, 2),
    EntryDate DATE,
    FOREIGN KEY (TaskID) REFERENCES Tasks(TaskID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
