ALTER DATABASE DW_EmployeeManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE DW_EmployeeManagement;
GO

BACKUP DATABASE EmployeeManagement TO DISK = '/var/opt/mssql/backup/EmployeeManagement.bak' WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup of EmployeeManagement';

BACKUP DATABASE Staging_EmployeeManagement TO DISK = '/var/opt/mssql/backup/Staging_EmployeeManagement.bak' WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup of Staging_EmployeeManagement';

BACKUP DATABASE DW_EmployeeManagement TO DISK = '/var/opt/mssql/backup/DW_EmployeeManagement.bak' WITH FORMAT, MEDIANAME = 'SQLServerBackups', NAME = 'Full Backup of DW_EmployeeManagement';

-- docker cp sql_server_container:/var/opt/mssql/backup/EmployeeManagement.bak /home/narges/Documents/IUT/8/DB2/FinalProject/datawarehouse/EmployeeManagement.bak