USE DW_EmployeeManagement;
GO

CREATE PROCEDURE First_Load_Dim_Employees
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Employees

    INSERT INTO DW_EmployeeManagement.dbo.Dim_Employees (EmployeeID, FirstName, LastName, Gender, DepartmentID, DepartmentName,
                    DepartmentMaxEmployeeSize, Birthday, PhoneNumber, StartDate, EndDate, BirthCityID, BirthCityName, BirthCityCountry, 
                    SCD_StartDate, SCD_EndDate, SCD_Flag)
    VALUES 
        (-1, 'Unknown', 'Unknown', 'Unknown', -1, 'Unknown', 0, 
        GETDATE(), 0, GETDATE(), NULL, -1, 'Unknown', 'Unknown', 
        GETDATE(), NULL, 1)
END;
GO

CREATE PROCEDURE First_Load_Dim_Date
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Date

    DECLARE @CurrentDate DATE = '2020-01-01';
    DECLARE @EndDate DATE = '2025-01-01';

    WHILE @CurrentDate < @EndDate
    BEGIN
        DECLARE @Year INT = YEAR(@CurrentDate);
        DECLARE @Quarter INT = DATEPART(QUARTER, @CurrentDate);
        DECLARE @Month INT = MONTH(@CurrentDate);
        DECLARE @Day INT = DAY(@CurrentDate);
        DECLARE @WeekDay NVARCHAR(10) = DATENAME(WEEKDAY, @CurrentDate);
        
        -- Shamsi (Persian) date conversion (assumes a function called dbo.ToShamsiDate exists)
        DECLARE @ShamsiDate NVARCHAR(10) = (SELECT * FROM dbo.ToShamsiDate(@CurrentDate)); 
        DECLARE @ShamsiYear INT = CAST(SUBSTRING(@ShamsiDate, 1, 4) AS INT);
        DECLARE @ShamsiMonth INT = CAST(SUBSTRING(@ShamsiDate, 6, 2) AS INT);
        DECLARE @ShamsiDay INT = CAST(SUBSTRING(@ShamsiDate, 9, 2) AS INT);
        DECLARE @ShamsiQuarter INT = CASE 
                                        WHEN @ShamsiMonth IN (1, 2, 3) THEN 1
                                        WHEN @ShamsiMonth IN (4, 5, 6) THEN 2
                                        WHEN @ShamsiMonth IN (7, 8, 9) THEN 3
                                        WHEN @ShamsiMonth IN (10, 11, 12) THEN 4
                                     END;
        DECLARE @ShamsiWeekDay NVARCHAR(10) = dbo.GetShamsiWeekDay(@WeekDay); -- assumes a function that returns Shamsi weekday name

        INSERT INTO Dim_Date (DateKey, Year, ShamsiYear, Quarter, ShamsiQuarter, Month, ShamsiMonth, Day, ShamsiDay, WeekDay, ShamsiWeekDay)
        VALUES (@CurrentDate, @Year, @ShamsiYear, @Quarter, @ShamsiQuarter, @Month, @ShamsiMonth, @Day, @ShamsiDay, @WeekDay, @ShamsiWeekDay);

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END;
GO

CREATE PROCEDURE First_Load_Dim_Projects
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Projects;
    
    INSERT INTO DW_EmployeeManagement.dbo.Dim_Projects (ProjectID, CurrentProjectName, OriginalProjectName, Description, StartDate, 
                    EndDate, Status, Advisor)
    VALUES 
        (-1, 'Unknown', 'Unknown', 'Unknown', GETDATE(), 
        GETDATE(), 'Unknown', -1)
END;
GO

CREATE PROCEDURE First_Load_Dim_Tasks
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Tasks;
    
    INSERT INTO DW_EmployeeManagement.dbo.Dim_Tasks (TaskID, TaskName, ProjectID, AssignedTo, StartDate, EndDate)
    VALUES 
        (-1, 'Unknown', -1, -1, GETDATE(), GETDATE())
END;
GO

CREATE PROCEDURE First_Load_Dim_Roles
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Roles;
    
    INSERT INTO DW_EmployeeManagement.dbo.Dim_Roles (RoleID, Name)
    VALUES 
        (1,'Advisor'),
        (2, 'Worker')
END;
GO

CREATE PROCEDURE First_Load_Fact_Transactions
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Fact_Transactions;
    
    INSERT INTO DW_EmployeeManagement.dbo.Fact_Transactions (TransactionID, ProjectID, TaskID, EmployeeID, HoursWorked, EntryDate)
    SELECT 
        te.TimeEntryID, ISNULL(t.ProjectID,-1), ISNULL(te.TaskID,-1), ISNULL(te.EmployeeID,-1), te.HoursWorked, te.EntryDate
    FROM Staging_EmployeeManagement.dbo.TimeEntries te
    JOIN Staging_EmployeeManagement.dbo.Tasks t ON (te.TaskID=t.TaskID)
END;
GO

CREATE PROCEDURE First_Load_Fact_Daily
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Fact_Daily;
    
    DECLARE @CurrentDate DATE = (SELECT min(EntryDate) FROM DW_EmployeeManagement.dbo.Fact_Transactions);
    DECLARE @EndDate DATE = (SELECT max(EntryDate) FROM DW_EmployeeManagement.dbo.Fact_Transactions);    

    WHILE @CurrentDate < @EndDate
    BEGIN    
        INSERT INTO DW_EmployeeManagement.dbo.Fact_Daily (Date, ProjectID, EmployeeID, TaskNum, SumHours, NumberOfDays, NumberOfConsecutiveFreeDays)
        SELECT 
            ft.EntryDate, ft.ProjectID, ft.EmployeeID, COUNT(1), 
            sum(HoursWorked), DATEDIFF(day, ft.EntryDate, p.StartDate), 
            DATEDIFF(day, DATEADD(DAY, -1, ft.EntryDate), 
                    (SELECT TOP 1 EntryDate 
                    FROM DW_EmployeeManagement.dbo.Fact_Transactions ft2 
                    WHERE ft2.EntryDate<ft.EntryDate AND ft.EmployeeID=ft2.EmployeeID AND ft.ProjectID=ft2.ProjectID 
                    ORDER BY EntryDate DESC)
            )
        FROM DW_EmployeeManagement.dbo.Fact_Transactions ft
        JOIN Staging_EmployeeManagement.dbo.Projects p ON p.ProjectID=ft.ProjectID
        WHERE ft.EntryDate=@CurrentDate
        GROUP BY ft.EntryDate, ft.ProjectID, ft.EmployeeID, p.StartDate

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END;
GO

CREATE PROCEDURE First_Load_Fact_ACC
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Fact_ACC

    INSERT INTO DW_EmployeeManagement.dbo.Fact_ACC (ProjectID, EmployeeID, ProjectStatus, TotalTaskNum, TotalHours, NumberOfDays, NumberOfConsecutiveFreeDays)
    SELECT 
        ft.ProjectID, ft.EmployeeID, p.status, COUNT(1), 
        sum(HoursWorked), DATEDIFF(day, GETDATE(), p.StartDate), 
        DATEDIFF(day, DATEADD(DAY, -1, GETDATE()), 
                (SELECT TOP 1 EntryDate 
                FROM DW_EmployeeManagement.dbo.Fact_Transactions ft2 
                WHERE ft.EmployeeID=ft2.EmployeeID AND ft.ProjectID=ft2.ProjectID 
                ORDER BY EntryDate DESC)
        )
    FROM DW_EmployeeManagement.dbo.Fact_Transactions ft
    JOIN Staging_EmployeeManagement.dbo.Projects p ON p.ProjectID=ft.ProjectID
    GROUP BY ft.ProjectID, ft.EmployeeID, p.status, p.StartDate;
END;
GO


CREATE PROCEDURE First_Load_DW
AS
BEGIN
    EXEC First_Load_Dim_Employees;
    EXEC First_Load_Dim_Date;
    EXEC First_Load_Dim_Projects;
    EXEC First_Load_Dim_Tasks;
    EXEC First_Load_Dim_Roles;
    EXEC First_Load_Fact_Transactions;
    EXEC First_Load_Fact_Daily;
    EXEC First_Load_Fact_ACC;
END;
GO

EXEC First_Load_DW;