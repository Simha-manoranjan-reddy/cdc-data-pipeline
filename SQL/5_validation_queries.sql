-- Source row count
SELECT COUNT(*) AS TotalRows
FROM dbo.Customer_Source_TB;
GO

-- Source sample rows
SELECT TOP 20 *
FROM dbo.Customer_Source_TB
ORDER BY CustomerID;
GO

-- Control table status
SELECT *
FROM dbo.CDC_Control_Table_TB
WHERE TableName = 'dbo_Customer_Source_TB';
GO

-- Database CDC enabled?
SELECT
    name,
    is_cdc_enabled
FROM sys.databases
WHERE name = DB_NAME();
GO

-- Table CDC enabled?
SELECT
    t.name AS TableName,
    t.is_tracked_by_cdc
FROM sys.tables t
WHERE t.name = 'Customer_Source_TB';
GO

-- CDC capture instance exists?
SELECT
    capture_instance,
    supports_net_changes
FROM cdc.change_tables
WHERE capture_instance = 'dbo_Customer_Source_TB';
GO
