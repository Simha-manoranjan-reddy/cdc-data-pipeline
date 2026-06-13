------------------------------------------------------------
-- INSERT 10 NEW ROWS
------------------------------------------------------------
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
VALUES
(101, 'Customer_101', 'customer101@gmail.com', '9000000101', 'Hyderabad', 'Telangana', 'India', '500101', 29, 'Male',   'Premium', 1250000.00, 85000.00, 780, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(102, 'Customer_102', 'customer102@gmail.com', '9000000102', 'Bangalore', 'Karnataka', 'India', '560102', 34, 'Female', 'VIP',     1500000.00, 95000.00, 810, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(103, 'Customer_103', 'customer103@gmail.com', '9000000103', 'Chennai',   'Tamil Nadu', 'India', '600103', 31, 'Male',   'Regular',  980000.00, 65000.00, 720, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(104, 'Customer_104', 'customer104@gmail.com', '9000000104', 'Pune',      'Maharashtra', 'India', '411104', 27, 'Female', 'Premium', 1100000.00, 72000.00, 760, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(105, 'Customer_105', 'customer105@gmail.com', '9000000105', 'Mumbai',    'Maharashtra', 'India', '400105', 36, 'Male',   'VIP',     1700000.00,120000.00, 830, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(106, 'Customer_106', 'customer106@gmail.com', '9000000106', 'Hyderabad', 'Telangana', 'India', '500106', 30, 'Female', 'Regular', 850000.00, 50000.00, 690, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(107, 'Customer_107', 'customer107@gmail.com', '9000000107', 'Bangalore', 'Karnataka', 'India', '560107', 33, 'Male', 'Premium', 1320000.00, 91000.00, 790, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(108, 'Customer_108', 'customer108@gmail.com', '9000000108', 'Chennai', 'Tamil Nadu', 'India', '600108', 42, 'Female', 'VIP', 1550000.00, 101000.00, 805, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(109, 'Customer_109', 'customer109@gmail.com', '9000000109', 'Pune', 'Maharashtra', 'India', '411109', 26, 'Male', 'Regular', 720000.00, 43000.00, 670, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System'),
(110, 'Customer_110', 'customer110@gmail.com', '9000000110', 'Mumbai', 'Maharashtra', 'India', '400110', 38, 'Female', 'Premium', 1450000.00, 98000.00, 775, 'Active', CAST(GETDATE() AS DATE), SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME(), 'System', SYSUTCDATETIME(), 'System');
GO

------------------------------------------------------------
-- UPDATE 5 EXISTING ROWS
------------------------------------------------------------
UPDATE dbo.Customer_Source_TB
SET
    City = 'Chennai',
    State = 'Tamil Nadu',
    CustomerType = 'VIP',
    AnnualIncome = AnnualIncome + 250000,
    AccountBalance = AccountBalance + 15000,
    CreditScore = CreditScore + 20,
    LastLoginDate = SYSUTCDATETIME(),
    LastTransactionDate = SYSUTCDATETIME(),
    UpdatedAt = SYSUTCDATETIME(),
    UpdatedBy = 'CDC_Test'
WHERE CustomerID IN (10, 20, 30, 40, 50);
GO

------------------------------------------------------------
-- DELETE 3 EXISTING ROWS
------------------------------------------------------------
DELETE FROM dbo.Customer_Source_TB
WHERE CustomerID IN (60, 70, 80);
GO
