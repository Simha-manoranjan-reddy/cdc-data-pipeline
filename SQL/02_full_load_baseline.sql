DELETE FROM dbo.Customer_Source_TB;
GO

INSERT INTO dbo.Customer_Source_TB
(
    CustomerID,
    CustomerName,
    Email,
    PhoneNumber,
    City,
    State,
    Country,
    ZipCode,
    Age,
    Gender,
    CustomerType,
    AnnualIncome,
    AccountBalance,
    CreditScore,
    Status,
    JoinDate,
    LastLoginDate,
    LastTransactionDate,
    CreatedDate,
    CreatedBy,
    UpdatedAt,
    UpdatedBy
)
SELECT 
    n AS CustomerID,
    CONCAT('Customer_', n) AS CustomerName,
    CONCAT('customer', n, '@gmail.com') AS Email,
    CONCAT('900000', RIGHT('0000' + CAST(n AS VARCHAR(4)), 4)) AS PhoneNumber,

    CASE 
        WHEN n % 5 = 0 THEN 'Hyderabad'
        WHEN n % 5 = 1 THEN 'Pune'
        WHEN n % 5 = 2 THEN 'Bangalore'
        WHEN n % 5 = 3 THEN 'Chennai'
        ELSE 'Mumbai'
    END AS City,

    CASE 
        WHEN n % 5 = 0 THEN 'Telangana'
        WHEN n % 5 = 1 THEN 'Maharashtra'
        WHEN n % 5 = 2 THEN 'Karnataka'
        WHEN n % 5 = 3 THEN 'Tamil Nadu'
        ELSE 'Maharashtra'
    END AS State,

    'India' AS Country,
    CONCAT('500', RIGHT('000' + CAST(n AS VARCHAR(3)), 3)) AS ZipCode,

    20 + (n % 30) AS Age,

    CASE 
        WHEN n % 2 = 0 THEN 'Male'
        ELSE 'Female'
    END AS Gender,

    CASE 
        WHEN n % 3 = 0 THEN 'Premium'
        WHEN n % 3 = 1 THEN 'Regular'
        ELSE 'VIP'
    END AS CustomerType,

    CAST(300000 + (n * 10000) AS DECIMAL(12,2)) AS AnnualIncome,
    CAST(5000 + (n * 500) AS DECIMAL(12,2)) AS AccountBalance,
    600 + (n % 200) AS CreditScore,

    'Active' AS Status,

    DATEADD(DAY, -n, CAST(GETDATE() AS DATE)) AS JoinDate,
    DATEADD(DAY, -(n % 7), SYSUTCDATETIME()) AS LastLoginDate,
    DATEADD(DAY, -(n % 3), SYSUTCDATETIME()) AS LastTransactionDate,

    SYSUTCDATETIME() AS CreatedDate,
    'System' AS CreatedBy,
    SYSUTCDATETIME() AS UpdatedAt,
    'System' AS UpdatedBy
FROM
(
    SELECT TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.objects
) AS Numbers;
GO

DELETE FROM dbo.CDC_Control_Table_TB
WHERE TableName = 'dbo_Customer_Source_TB';
GO

INSERT INTO dbo.CDC_Control_Table_TB
(
    TableName,
    LastProcessedLSN,
    IsInitialLoadDone,
    LastProcessedTime,
    IsActive
)
VALUES
(
    'dbo_Customer_Source_TB',
    NULL,
    0,
    NULL,
    1
);
GO
