IF NOT EXISTS (SELECT 1
FROM sysobjects
WHERE name='Users' and xtype='U')
CREATE TABLE dbo.Users
(
    UserID int PRIMARY KEY CLUSTERED,
    FirstName VARCHAR (50) NOT NULL,
    LastName VARCHAR (50) NOT NULL,
    UserHandle VARCHAR (50) NOT NULL
);
GO

IF NOT EXISTS (SELECT TOP(1)
    1
FROM Users)
INSERT INTO Users
    (UserID, FirstName, LastName, UserHandle)
VALUES
    (1, 'Brendon', 'Thiede', 'bigpapa'),
    (2, 'Noah', 'Thiede', 'batmangler'),
    (3, 'Luke', 'Thiede', 'trogdorable')
GO