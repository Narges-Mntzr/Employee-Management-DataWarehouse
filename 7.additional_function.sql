USE DW_EmployeeManagement;
GO

-- Example function to convert Gregorian date to Shamsi date (YYYY-MM-DD format)
DROP FUNCTION dbo.ToShamsiDate;
GO

CREATE FUNCTION dbo.ToShamsiDate(@GregorianDate DATE)
RETURNS TABLE
AS
RETURN
(
    WITH BaseData AS
    (
        SELECT 
            @GregorianDate AS GregorianDate,
            DATEPART(YEAR, @GregorianDate) AS GregorianYear,
            DATEPART(MONTH, @GregorianDate) AS GregorianMonth,
            DATEPART(DAY, @GregorianDate) AS GregorianDay
    ),
    ShamsiYear AS
    (
        SELECT 
            CASE 
                WHEN GregorianMonth < 3 OR (GregorianMonth = 3 AND GregorianDay < 21)
                THEN GregorianYear - 622
                ELSE GregorianYear - 621
            END AS Year
        FROM BaseData
    ),
    ShamsiDate AS
    (
        SELECT
            GregorianDate,
            GregorianMonth,
            GregorianDay,
            Year,
            CASE 
                WHEN GregorianMonth = 1 THEN CASE WHEN GregorianDay < 21 THEN 10 ELSE 11 END
                WHEN GregorianMonth = 2 THEN CASE WHEN GregorianDay < 20 THEN 11 ELSE 12 END
                WHEN GregorianMonth = 3 THEN CASE WHEN GregorianDay < 20 THEN 12 ELSE 1 END
                WHEN GregorianMonth = 4 THEN CASE WHEN GregorianDay < 20 THEN 1 ELSE 2 END
                WHEN GregorianMonth = 5 THEN CASE WHEN GregorianDay < 21 THEN 2 ELSE 3 END
                WHEN GregorianMonth = 6 THEN CASE WHEN GregorianDay < 21 THEN 3 ELSE 4 END
                WHEN GregorianMonth = 7 THEN CASE WHEN GregorianDay < 22 THEN 4 ELSE 5 END
                WHEN GregorianMonth = 8 THEN CASE WHEN GregorianDay < 22 THEN 5 ELSE 6 END
                WHEN GregorianMonth = 9 THEN CASE WHEN GregorianDay < 22 THEN 6 ELSE 7 END
                WHEN GregorianMonth = 10 THEN CASE WHEN GregorianDay < 22 THEN 7 ELSE 8 END
                WHEN GregorianMonth = 11 THEN CASE WHEN GregorianDay < 21 THEN 8 ELSE 9 END
                WHEN GregorianMonth = 12 THEN CASE WHEN GregorianDay < 21 THEN 9 ELSE 10 END
            END AS Month
        FROM ShamsiYear, BaseData
    ),
    ShamsiFinal AS
    (
        SELECT 
            GregorianDate,
            Year,
            Month,
            GregorianDay,
            CASE
                WHEN GregorianMonth IN (1,11,12) AND GregorianDay < 21 THEN GregorianDay + 10
                WHEN GregorianMonth IN (1,5,6,11,12) AND GregorianDay >= 21 THEN GregorianDay - 20
                WHEN GregorianMonth IN (2) AND GregorianDay < 20 THEN GregorianDay + 11
                WHEN GregorianMonth IN (2,3,4) AND GregorianDay >= 20 THEN GregorianDay - 19
                WHEN GregorianMonth IN (3) AND GregorianDay < 20 THEN GregorianDay + 10
                WHEN GregorianMonth IN (4) AND GregorianDay < 20 THEN GregorianDay + 12
                WHEN GregorianMonth IN (5,6) AND GregorianDay < 21 THEN GregorianDay + 11
                WHEN GregorianMonth IN (7,8,9) AND GregorianDay < 22 THEN GregorianDay + 10
                WHEN GregorianMonth IN (7,8,9,10) AND GregorianDay >= 22 THEN GregorianDay - 21
                WHEN GregorianMonth IN (10) AND GregorianDay < 22 THEN GregorianDay + 9
            END AS Day
        FROM ShamsiDate
    )
    SELECT 
        CONCAT(Year, '-', FORMAT(Month, '00'), '-', FORMAT(Day, '00')) AS ShamsiDate
    FROM ShamsiFinal
);  
GO

-- Example function to get Shamsi weekday name
CREATE FUNCTION dbo.GetShamsiWeekDay(@EnglishWeekday DATE)
RETURNS NVARCHAR(10)
AS
BEGIN
    DECLARE @PersianWeekday NVARCHAR(10);

    SET @PersianWeekday = CASE @EnglishWeekday
        WHEN 'Monday' THEN N'دوشنبه'
        WHEN 'Tuesday' THEN N'سه‌شنبه'
        WHEN 'Wednesday' THEN N'چهارشنبه'
        WHEN 'Thursday' THEN N'پنج‌شنبه'
        WHEN 'Friday' THEN N'جمعه'
        WHEN 'Saturday' THEN N'شنبه'
        WHEN 'Sunday' THEN N'یک‌شنبه'
        ELSE N'نامشخص' -- Unspecified or unknown
    END;

    RETURN @PersianWeekday;
END;
GO

-- Usage of functions
SELECT * FROM dbo.ToShamsiDate('2020-10-22') --output: 1399-08-01