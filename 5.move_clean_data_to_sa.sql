USE Staging_EmployeeManagement;
GO

-- -- ETL to move data to staging

-- Drop the procedure if it already exists
IF OBJECT_ID('CopyToStaging', 'P') IS NOT NULL
    DROP PROCEDURE CopyToStaging;
GO

-- Create the procedure
CREATE PROCEDURE CopyToStaging
AS
BEGIN

    INSERT INTO Staging_EmployeeManagement.dbo.Employees (EmployeeID, FirstName, LastName, Gender, DepartmentID, Birthday, PhoneNumber, StartDate, EndDate, BirthCity)
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        CASE 
            WHEN Gender = 'M' THEN 'Male'
            WHEN Gender = 'F' THEN 'Female'
        END AS Gender,
        DepartmentID,
        Birthday,
        PhoneNumber,
        StartDate,
        EndDate,
        BirthCity
    FROM EmployeeManagement.dbo.Employees
    WHERE StartDate IS NOT NULL AND 
        StartDate <= GETDATE() AND
        (EndDate IS NULL OR (StartDate < EndDate AND EndDate <= GETDATE()));
    
    INSERT INTO Staging_EmployeeManagement.dbo.Projects (ProjectID, ProjectName, Description, StartDate, EndDate, Status, Advisor)
    SELECT 
        ProjectID,
        ProjectName,
        Description,
        StartDate,
        EndDate,
        Status,
        Advisor
    FROM EmployeeManagement.dbo.Projects
    WHERE ProjectName IS NOT NULL AND 
        StartDate IS NOT NULL AND StartDate <= GETDATE() AND
        (EndDate IS NULL OR (StartDate < EndDate AND EndDate <= GETDATE()));

    INSERT INTO Staging_EmployeeManagement.dbo.Tasks (TaskID, TaskName, ProjectID, AssignedTo, StartDate, EndDate, Description)
    SELECT 
       TaskID, 
       TaskName, 
       ProjectID, 
       AssignedTo, 
       StartDate, 
       EndDate, 
       Description
    FROM EmployeeManagement.dbo.Tasks
    WHERE TaskName IS NOT NULL AND 
        EndDate IS NOT NULL AND StartDate < EndDate AND
        EndDate < GETDATE();

    INSERT INTO Staging_EmployeeManagement.dbo.TimeEntries (TimeEntryID, TaskID, EmployeeID, HoursWorked, EntryDate)
    SELECT 
       TimeEntryID, 
       TaskID, 
       EmployeeID, 
       HoursWorked, 
       EntryDate
    FROM EmployeeManagement.dbo.TimeEntries
    WHERE EntryDate IS NOT NULL AND EntryDate < GETDATE();

    INSERT INTO Staging_EmployeeManagement.dbo.Departments (DepartmentID, Name, MaxEmployeeSize)
    SELECT 
       DepartmentID, 
       Name, 
       MaxEmployeeSize
    FROM EmployeeManagement.dbo.Departments
    WHERE Name IS NOT NULL;

    INSERT INTO Staging_EmployeeManagement.dbo.Cities (CityID, Name, Country)
    SELECT 
       CityID, 
       Name, 
       Country
    FROM EmployeeManagement.dbo.Cities
    WHERE Name IS NOT NULL;

END;
GO


-- Move clean data from source to staging area
EXEC CopyToStaging;