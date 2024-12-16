CREATE DATABASE Proiect;
GO


CREATE LOGIN tudor WITH PASSWORD = 'ParolaSigura123!';
CREATE USER tudor FOR LOGIN tudor;
ALTER ROLE db_owner ADD MEMBER tudor;
GO


SELECT name FROM sys.databases;

USE Proiect;
GO
ALTER USER tudor WITH DEFAULT_SCHEMA = dbo;
GO
ALTER ROLE db_owner ADD MEMBER tudor;
GO



USE Proiect;
GO
SELECT * FROM sys.tables;
