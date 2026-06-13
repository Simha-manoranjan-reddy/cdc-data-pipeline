EXEC sys.sp_cdc_enable_db;
GO

EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'Customer_Source_TB',
    @role_name = NULL,
    @supports_net_changes = 1;
GO
