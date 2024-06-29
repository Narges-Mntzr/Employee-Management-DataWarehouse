USE DW_EmployeeManagement;
GO

CREATE PROCEDURE Load_Dim_Employees
AS
BEGIN
    DECLARE @TmpRowCount INT;
    DECLARE @DimRowCount INT;

    SELECT @TmpRowCount = COUNT(*) FROM DW_EmployeeManagement.dbo.Tmp_Dim_Employees;
    SELECT @DimRowCount = COUNT(*) FROM DW_EmployeeManagement.dbo.Dim_Employees;

    IF @TmpRowCount > 0 AND @DimRowCount = 0
    BEGIN
        RETURN
    END

    TRUNCATE TABLE DW_EmployeeManagement.dbo.Tmp_Dim_Employees;

    INSERT INTO DW_EmployeeManagement.dbo.Tmp_Dim_Employees (EmployeeID, FirstName, LastName, Gender, DepartmentID, DepartmentName,
                    DepartmentMaxEmployeeSize, Birthday, PhoneNumber, StartDate, EndDate, BirthCityID, BirthCityName, BirthCityCountry, 
                    SCD_StartDate, SCD_EndDate, SCD_Flag)
    SELECT 
        EmployeeID, FirstName, LastName, Gender, DepartmentID, DepartmentName, DepartmentMaxEmployeeSize, 
        Birthday, PhoneNumber, StartDate, EndDate, BirthCityID, BirthCityName, BirthCityCountry, 
        SCD_StartDate, SCD_EndDate, SCD_Flag
    FROM DW_EmployeeManagement.dbo.Dim_Employees

    INSERT INTO DW_EmployeeManagement.dbo.Tmp_Dim_Employees (EmployeeID, FirstName, LastName, Gender, DepartmentID, DepartmentName,
                    DepartmentMaxEmployeeSize, Birthday, PhoneNumber, StartDate, EndDate, BirthCityID, BirthCityName, BirthCityCountry, 
                    SCD_StartDate, SCD_EndDate, SCD_Flag)
    SELECT 
        e.EmployeeID, e.FirstName, e.LastName, e.Gender, e.DepartmentID, d.DepartmentName, d.DepartmentMaxEmployeeSize, 
        e.Birthday, e.PhoneNumber, e.StartDate, e.EndDate, e.BirthCity, c.Name, c.Country, 
        GETDATE(), NULL, 1
    FROM Staging_EmployeeManagement.dbo.Employees e
    JOIN Staging_EmployeeManagement.dbo.Departments d ON (e.DepartmentID = d.DepartmentID)
    JOIN Staging_EmployeeManagement.dbo.Cities c ON (e.BirthCity = c.CityID)
    WHERE NOT EXISTS (SELECT EmployeeID 
        FROM DW_EmployeeManagement.dbo.Tmp_Dim_Employees tde
        WHERE tde.EmployeeID = e.EmployeeID AND tde.DepartmentID = e.DepartmentID
    )

    UPDATE tde1
    SET SCD_EndDate = GETDATE(), SCD_Flag=0
    FROM DW_EmployeeManagement.dbo.Tmp_Dim_Employees tde1
    WHERE SCD_Flag = 1 AND EXISTS ( SELECT EmployeeID
        FROM DW_EmployeeManagement.dbo.Tmp_Dim_Employees tde2
        WHERE tde1.EmployeeID = tde2.EmployeeID AND tde1.SCD_StartDate < tde2.SCD_StartDate
    )

    UPDATE tde
    SET EndDate = e.EndDate
    FROM DW_EmployeeManagement.dbo.Tmp_Dim_Employees tde
    JOIN Staging_EmployeeManagement.dbo.Employees e ON (e.EmployeeID = tde.EmployeeID)
    WHERE SCD_Flag = 1 AND tde.EndDate IS NULL AND e.EndDate IS NOT NULL

    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Employees;

    INSERT INTO DW_EmployeeManagement.dbo.Dim_Employees (EmployeeID, FirstName, LastName, Gender, DepartmentID, DepartmentName,
                    DepartmentMaxEmployeeSize, Birthday, PhoneNumber, StartDate, EndDate, BirthCityID, BirthCityName, BirthCityCountry, 
                    SCD_StartDate, SCD_EndDate, SCD_Flag)
    SELECT 
        EmployeeID, FirstName, LastName, Gender, DepartmentID, DepartmentName, DepartmentMaxEmployeeSize, 
        Birthday, PhoneNumber, StartDate, EndDate, BirthCityID, BirthCityName, BirthCityCountry, 
        SCD_StartDate, SCD_EndDate, SCD_Flag
    FROM DW_EmployeeManagement.dbo.Tmp_Dim_Employees

END;
GO

CREATE PROCEDURE Load_Dim_Projects
AS
BEGIN
    DECLARE @TmpRowCount INT;
    DECLARE @DimRowCount INT;

    SELECT @TmpRowCount = COUNT(*) FROM DW_EmployeeManagement.dbo.Tmp_Dim_Projects;
    SELECT @DimRowCount = COUNT(*) FROM DW_EmployeeManagement.dbo.Dim_Projects;

    IF @TmpRowCount > 0 AND @DimRowCount = 0
    BEGIN
        RETURN
    END

    TRUNCATE TABLE DW_EmployeeManagement.dbo.Tmp_Dim_Projects;

    INSERT INTO DW_EmployeeManagement.dbo.Tmp_Dim_Projects (ProjectID, CurrentProjectName, OriginalProjectName, Description, StartDate, 
                    EndDate, Status, Advisor)
    SELECT 
        ProjectID, CurrentProjectName, OriginalProjectName, Description, StartDate, 
        EndDate, Status, Advisor
    FROM DW_EmployeeManagement.dbo.Dim_Projects

    INSERT INTO DW_EmployeeManagement.dbo.Tmp_Dim_Projects (ProjectID, CurrentProjectName, OriginalProjectName, Description, StartDate, 
                    EndDate, Status, Advisor)
    SELECT 
        ProjectID, ProjectName, NULL, Description, StartDate, 
        EndDate, Status, ISNULL(Advisor,-1)
    FROM Staging_EmployeeManagement.dbo.Projects p
    WHERE NOT EXISTS (SELECT 1 
        FROM DW_EmployeeManagement.dbo.Tmp_Dim_Projects tdp
        WHERE tdp.ProjectID = p.ProjectID)

    UPDATE tdp
    SET tdp.OriginalProjectName = tdp.CurrentProjectName,
        tdp.CurrentProjectName = p.ProjectName
    FROM DW_EmployeeManagement.dbo.Tmp_Dim_Projects tdp
    JOIN Staging_EmployeeManagement.dbo.Projects p ON p.ProjectID = tdp.ProjectID
    WHERE p.ProjectName != tdp.CurrentProjectName;

    UPDATE tdp
    SET EndDate = p.EndDate
    FROM DW_EmployeeManagement.dbo.Tmp_Dim_Projects tdp
    JOIN Staging_EmployeeManagement.dbo.Projects p ON (p.ProjectID = tdp.ProjectID)
    WHERE tdp.EndDate IS NULL AND p.EndDate IS NOT NULL

    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Projects;

    INSERT INTO DW_EmployeeManagement.dbo.Dim_Projects (ProjectID, CurrentProjectName, OriginalProjectName, Description, StartDate, 
                    EndDate, Status, Advisor)
    SELECT 
        ProjectID, CurrentProjectName, OriginalProjectName, Description, StartDate, 
        EndDate, Status, Advisor
    FROM DW_EmployeeManagement.dbo.Tmp_Dim_Projects

END;
GO

CREATE PROCEDURE Load_Dim_Tasks
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Dim_Tasks;
    
    INSERT INTO DW_EmployeeManagement.dbo.Dim_Tasks (TaskID, TaskName, ProjectID, AssignedTo, StartDate, EndDate)
    SELECT
        TaskID, TaskName, ProjectID, AssignedTo, StartDate, EndDate
    FROM Staging_EmployeeManagement.dbo.Tasks
    WHERE TaskID NOT IN (SELECT TaskID 
                    FROM DW_EmployeeManagement.dbo.Dim_Tasks)
END;
GO


CREATE PROCEDURE Load_Fact_Transactions
AS
BEGIN
    DECLARE @CurrentDate DATE = DATEADD(DAY, 1, (SELECT max(EntryDate) FROM DW_EmployeeManagement.dbo.Fact_Transactions));
    DECLARE @EndDate DATE = (SELECT max(EntryDate) FROM Staging_EmployeeManagement.dbo.TimeEntries);    

    WHILE @CurrentDate < @EndDate
    BEGIN
        INSERT INTO DW_EmployeeManagement.dbo.Fact_Transactions (TransactionID, ProjectID, TaskID, EmployeeID, HoursWorked, EntryDate)
        SELECT 
            te.TimeEntryID, ISNULL(t.ProjectID,-1), ISNULL(te.TaskID,-1), ISNULL(te.EmployeeID,-1), te.HoursWorked, te.EntryDate
        FROM Staging_EmployeeManagement.dbo.TimeEntries te
        JOIN Staging_EmployeeManagement.dbo.Tasks t ON (te.TaskID=t.TaskID)
        WHERE te.EntryDate = @CurrentDate;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END;
GO

CREATE PROCEDURE Load_Fact_Daily
AS
BEGIN
    DECLARE @CurrentDate DATE = DATEADD(DAY, 1, (SELECT max(Date) FROM DW_EmployeeManagement.dbo.Fact_Daily));
    DECLARE @EndDate DATE = (SELECT max(EntryDate) FROM DW_EmployeeManagement.dbo.Fact_Transactions);    

    WHILE @CurrentDate < @EndDate
    BEGIN    
        INSERT INTO DW_EmployeeManagement.dbo.Fact_Daily (Date, ProjectID, EmployeeID, TaskNum, SumHours, NumberOfDays, NumberOfConsecutiveFreeDays)
        SELECT 
            ft.EntryDate, ft.ProjectID, ft.EmployeeID, cnt(1), 
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
        GROUP BY ft.EntryDate, ft.ProjectID, ft.EmployeeID;

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
    END
END;
GO

CREATE PROCEDURE Load_Fact_ACC
AS
BEGIN
    TRUNCATE TABLE DW_EmployeeManagement.dbo.Fact_ACC;

    INSERT INTO DW_EmployeeManagement.dbo.Fact_ACC (ProjectID, EmployeeID, TaskNum, SumHours, NumberOfDays, NumberOfConsecutiveFreeDays)
    SELECT 
        ft.ProjectID, ft.EmployeeID, cnt(1), 
        sum(HoursWorked), DATEDIFF(day, GETDATE(), p.StartDate), 
        DATEDIFF(day, DATEADD(DAY, -1, GETDATE()), 
                (SELECT TOP 1 EntryDate 
                FROM DW_EmployeeManagement.dbo.Fact_Transactions ft2 
                WHERE ft.EmployeeID=ft2.EmployeeID AND ft.ProjectID=ft2.ProjectID 
                ORDER BY EntryDate DESC)
        )
    FROM DW_EmployeeManagement.dbo.Fact_Transactions ft
    JOIN Staging_EmployeeManagement.dbo.Projects p ON p.ProjectID=ft.ProjectID
    GROUP BY ft.ProjectID, ft.EmployeeID;
END;
GO

CREATE PROCEDURE Load_Factless
AS
BEGIN
    DECLARE @TmpRowCount INT;
    DECLARE @DimRowCount INT;

    SELECT @TmpRowCount = COUNT(*) FROM DW_EmployeeManagement.dbo.Tmp_Factless;
    SELECT @DimRowCount = COUNT(*) FROM DW_EmployeeManagement.dbo.Factless;

    IF @TmpRowCount > 0 AND @DimRowCount = 0
    BEGIN
        RETURN
    END

    TRUNCATE TABLE DW_EmployeeManagement.dbo.Tmp_Factless;

    INSERT INTO DW_EmployeeManagement.dbo.Tmp_Factless (ProjectID, EmployeeID, Role)
    SELECT
        ft.ProjectID, ft.EmployeeID, 2
    FROM DW_EmployeeManagement.dbo.Fact_Transactions ft
    GROUP BY ft.ProjectID, ft.EmployeeID;

    INSERT INTO DW_EmployeeManagement.dbo.Tmp_Factless (ProjectID, EmployeeID, Role)
    SELECT
        p.ProjectID, p.Advisor, 1
    FROM Staging_EmployeeManagement.dbo.Projects p
    GROUP BY ft.ProjectID, ft.EmployeeID;

    TRUNCATE TABLE DW_EmployeeManagement.dbo.Factless;

    INSERT INTO DW_EmployeeManagement.dbo.Factless (ProjectID, EmployeeID, Role)
    SELECT
        ProjectID, Advisor, Role
    FROM DW_EmployeeManagement.dbo.Tmp_Factless 
END;
GO

CREATE PROCEDURE Load_DW
AS
BEGIN
    EXEC Load_Dim_Employees;
    EXEC Load_Dim_Projects;
    EXEC Load_Dim_Tasks;
    EXEC Load_Fact_Transactions;
    EXEC Load_Fact_Daily;
    EXEC Load_Fact_ACC;
    EXEC Load_Factless;
END;
GO

EXEC Load_DW;