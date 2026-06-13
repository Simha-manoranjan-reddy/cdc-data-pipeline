
DROP TABLE IF EXISTS dbo.Customer_Source_TB;
GO

CREATE TABLE dbo.Customer_Source_TB
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(150),
    PhoneNumber VARCHAR(20),

    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    ZipCode VARCHAR(10),

    Age INT,
    Gender VARCHAR(10),

    CustomerType VARCHAR(50),
    AnnualIncome DECIMAL(12,2),

    AccountBalance DECIMAL(12,2),
    CreditScore INT,
    Status VARCHAR(20),

    JoinDate DATE,
    LastLoginDate DATETIME2,
    LastTransactionDate DATETIME2,

    CreatedDate DATETIME2 DEFAULT SYSUTCDATETIME(),
    CreatedBy VARCHAR(50),

    UpdatedAt DATETIME2 DEFAULT SYSUTCDATETIME(),
    UpdatedBy VARCHAR(50)
);
GO

DROP TABLE IF EXISTS dbo.CDC_Control_Table_TB;
GO

CREATE TABLE dbo.CDC_Control_Table_TB
(
    TableName VARCHAR(100) PRIMARY KEY,
    LastProcessedLSN BINARY(10) NULL,
    IsInitialLoadDone BIT DEFAULT 0,
    LastProcessedTime DATETIME2 NULL,
    IsActive BIT DEFAULT 1
);
GO
