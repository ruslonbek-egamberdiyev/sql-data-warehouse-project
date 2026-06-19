/*
================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
================================================================================
Script Purpose:
This stored procedure loads data into the 'bronze' schema from external CSV files.
It performs the following actions:
- Truncates the bronze tables before loading data.
- Uses the BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:

None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
EXEC bronze.load_bronze;
================================================================================
*/

Use DataWarehouse
Go
Create or Alter Procedure bronze.load_bronze as
BEGIN
	Declare @Start_time datetime, @End_time datetime;
	Begin TRY
		Print'==================================================='
		Print'Loading Bronze Layer'
		Print'==================================================='

		Print'---------------------------------------------------'
		Print'Loading CRM Tables'
		Print'---------------------------------------------------'


		Set @start_time = getdate()
		Print'>> Truncating Table: bronze.crm_cust_info'
		Truncate table bronze.crm_cust_info;

		Print'>> Inserting Data Into: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info
		FROM 'F:\Telegram\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		with (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'



		Set @start_time = getdate()
		Print'>> Truncating Table: bronze.crm_prd_info'
		Truncate table bronze.crm_prd_info;

		Print'>> Inserting Data Into: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info
		FROM 'F:\Telegram\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		with (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'



		Set @start_time = getdate()
		Print'>> Truncating Table: bronze.crm_sales_details'
		Truncate table bronze.crm_sales_details;

		Print'>> Inserting Data Into: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'F:\Telegram\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		with (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'




		Print'---------------------------------------------------'
		Print'Loading ERP Tables'
		Print'---------------------------------------------------'



		Set @start_time = getdate()
		Print'>> Truncating Table: bronze.erp_loc_a101'
		Truncate table bronze.erp_loc_a101;

		Print'>> Inserting Data Into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'F:\Telegram\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		with (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'




		Set @start_time = getdate()
		Print'>> Truncating Table: bronze.erp_cust_az12'
		Truncate table bronze.erp_cust_az12;

		Print'>> Inserting Data Into: bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'F:\Telegram\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		with (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
	    Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'



	    Set @start_time = getdate()
		Print'>> Truncating Table: bronze.erp_px_cat_g1v2'
		Truncate table bronze.erp_px_cat_g1v2;

		Print'>> Inserting Data Into: bronze.erp_px_cat_g1v2' 
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'F:\Telegram\f78e076e5b83435d84c6b6af75d8a679\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		with (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'

	END TRY
	Begin Catch
		PRINT'==================================================='
		Print'Error Occured During Loading Bronze Layer'
		Print'Error Message: ' + Error_Message();
		Print'Error Number: ' + Cast(Error_message() as nvarchar(50));
		Print'Error State: ' + Cast(Error_state() as nvarchar(50));
		Print'Error Line; ' + Cast(Error_line() as nvarchar(50))
		PRINT'==================================================='
	End Catch
End

Go
Exec bronze.load_bronze
