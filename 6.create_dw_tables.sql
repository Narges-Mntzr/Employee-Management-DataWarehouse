-- CREATE DATABASE DW_EmployeeManagement;
-- GO

-- DROP DATABASE DW_EmployeeManagement;

USE DW_EmployeeManagement;
GO

CREATE TABLE Dim_Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(60),
    LastName NVARCHAR(60),
    Gender NVARCHAR(10),
    DepartmentID INT,
    DepartmentName NVARCHAR(100),
    DepartmentMaxEmployeeSize INT,
    Birthday DATE,
    PhoneNumber NVARCHAR(20),
    StartDate DATE,
    EndDate DATE,
    BirthCityID INT,
    BirthCityName NVARCHAR(100),
    BirthCityCountry NVARCHAR(100),
    SCD_StartDate DATE,
    SCD_EndDate DATE,
    SCD_Flag CHAR(1)
);

CREATE TABLE Dim_Date (
    DateKey DATE PRIMARY KEY,
    Year INT,
    ShamsiYear INT,
    Quarter INT,
    ShamsiQuarter INT,
    Month INT,
    ShamsiMonth INT,
    Day INT,
    ShamsiDay INT,
    WeekDay NVARCHAR(10),
    ShamsiWeekDay NVARCHAR(10)
);

CREATE TABLE Dim_Projects (
    ProjectID INT PRIMARY KEY,
    CurrentProjectName NVARCHAR(100),
    OriginalProjectName NVARCHAR(100),
    Description NVARCHAR(MAX),
    StartDate DATE,
    EndDate DATE,
    Status CHAR(30),
    Advisor INT,
    FOREIGN KEY (Advisor) REFERENCES Dim_Employees(EmployeeID)
);

CREATE TABLE Dim_Tasks (
    TaskID INT PRIMARY KEY,
    TaskName NVARCHAR(100),
    ProjectID INT,
    AssignedTo INT,
    StartDate DATE,
    EndDate DATE,
    FOREIGN KEY (ProjectID) REFERENCES Dim_Projects(ProjectID),
    FOREIGN KEY (AssignedTo) REFERENCES Dim_Employees(EmployeeID)
);

CREATE TABLE Dim_Roles (
    RoleID INT PRIMARY KEY,
    Name NVARCHAR(100)
);

CREATE TABLE Fact_Transactions (
    TransactionID INT PRIMARY KEY,
    ProjectID INT,
    TaskID INT,
    EmployeeID INT,
    HoursWorked DECIMAL(5, 2),
    EntryDate DATE,
    FOREIGN KEY (ProjectID) REFERENCES Dim_Projects(ProjectID),
    FOREIGN KEY (TaskID) REFERENCES Dim_Tasks(TaskID),
    FOREIGN KEY (EmployeeID) REFERENCES Dim_Employees(EmployeeID),
    FOREIGN KEY (EntryDate) REFERENCES Dim_Date(DateKey)
);

CREATE TABLE Fact_Daily (
    Date DATE,
    ProjectID INT,
    EmployeeID INT,
    TaskNum INT,
    SumHours DECIMAL(5, 2),
    NumberOfDays INT,
    NumberOfConsecutiveFreeDays INT,
    PRIMARY KEY (Date, ProjectID, EmployeeID),
    FOREIGN KEY (Date) REFERENCES Dim_Date(DateKey),
    FOREIGN KEY (ProjectID) REFERENCES Dim_Projects(ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Dim_Employees(EmployeeID)
);

CREATE TABLE Fact_Acc (
    ProjectID INT,
    EmployeeID INT,
    ProjectStatus NVARCHAR(50),
    TotalTaskNum INT,
    TotalHours DECIMAL(10, 2),
    NumberOfDays INT,
    NumberOfConsecutiveFreeDays INT,
    PRIMARY KEY (ProjectID, EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES Dim_Projects(ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Dim_Employees(EmployeeID)
);

CREATE TABLE Factless (
    ProjectID INT,
    EmployeeID INT,
    Role INT,
    PRIMARY KEY (ProjectID, EmployeeID, Role),
    FOREIGN KEY (ProjectID) REFERENCES Dim_Projects(ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Dim_Employees(EmployeeID),
    FOREIGN KEY (Role) REFERENCES Dim_Roles(RoleID)
);


-- temp tables
CREATE TABLE Tmp_Dim_Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(60),
    LastName NVARCHAR(60),
    Gender NVARCHAR(10),
    DepartmentID INT,
    DepartmentName NVARCHAR(100),
    DepartmentMaxEmployeeSize INT,
    Birthday DATE,
    PhoneNumber NVARCHAR(20),
    StartDate DATE,
    EndDate DATE,
    BirthCityID INT,
    BirthCityName NVARCHAR(100),
    BirthCityCountry NVARCHAR(100),
    SCD_StartDate DATE,
    SCD_EndDate DATE,
    SCD_Flag CHAR(1)
);

CREATE TABLE Tmp_Dim_Projects (
    ProjectID INT PRIMARY KEY,
    CurrentProjectName NVARCHAR(100),
    OriginalProjectName NVARCHAR(100),
    Description NVARCHAR(MAX),
    StartDate DATE,
    EndDate DATE,
    Status CHAR(30),
    Advisor NVARCHAR(100),
);

CREATE TABLE Tmp_Factless (
    ProjectID INT,
    EmployeeID INT,
    Role INT,
);