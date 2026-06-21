/*
============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
  Actions Performed:
    - Truncates Silver tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
============================================================================
*/


Use DataWarehouse
Go
Create or alter procedure silver.load_silver as
Begin
	Declare @Start_time datetime, @End_time datetime;
	Begin TRY
		Print'==================================================='
		Print'Loading Silver Layer'
		Print'==================================================='
		
		Print'---------------------------------------------------'
		Print'Loading CRM Tables'
		Print'---------------------------------------------------'


		--Loading: silver.crm_cust_info
		Set @start_time = getdate()
		Print'>> Truncating table:  silver.crm_cust_info';
			Truncate table  silver.crm_cust_info;


		Print'>> Inserting data Into:  silver.crm_cust_info';
		Insert into silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_material_status,
		cst_gndr,
		cst_create_date
		)
		Select  
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,
			Case
				When Upper(TRIM(cst_material_status)) = 'M' then 'Married'
				When  Upper(TRIM(cst_material_status)) = 'S' then 'Single'
				else 'N/A'
			End as cst_material_status,
			Case 
				when upper(Trim(cst_gndr)) = 'M' then 'Male'
				When upper(Trim(cst_gndr)) = 'F' then 'Female'
				else 'N/A'
			end as cst_gndr,
			cst_create_date
		from
		(
			Select 
			*,
			Row_number() over(partition by cst_id order by cst_create_date desc) as create_date
			From bronze.crm_cust_info
		)t
		where create_date = 1 and cst_id is not null

		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'




		--Loading: silver.crm_prd_info
		Set @start_time = getdate()
		Print'>> Truncating table:  silver.crm_prd_info';
			Truncate table  silver.crm_prd_info;


		Print'>> Inserting data Into:  silver.crm_prd_info';
		Insert into silver.crm_prd_info 
		(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			replace(substring(prd_key,1,5), '-','_') as cat_id,
			Substring(prd_key,7,LEN(prd_key)) as prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) as prd_cost,
			Case 
				When Upper(Trim(prd_line)) = 'R' Then 'Road'
				When Upper(Trim(prd_line)) = 'M' Then 'Mountain'
				When Upper(Trim(prd_line)) = 'T' Then 'Touring'
				When Upper(Trim(prd_line)) = 'S' Then 'Other Sales'
				Else 'N/A'
			End as prd_line,
			cast(prd_start_dt as date) as prd_start_dt,
			cast(LEAD(prd_start_dt) OVER (PARTITION by prd_key order by prd_start_dt asc)-1 as date) as prd_end_dt
		FROM bronze.crm_prd_info
		
		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'



		--Loading: silver.crm_sales_details
		Set @start_time = getdate()
		Print'>> Truncating table: silver.crm_sales_details';
			Truncate table  silver.crm_sales_details;


		Print'>> Inserting data Into:  silver.crm_sales_details';
		Insert into silver.crm_sales_details
		(
		sls_ord_num, 
		sls_prd_key, 
		sls_cust_id, 
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,   
		sls_sales,    
		sls_quantity,
		sls_price    
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			Case 
				when sls_order_dt = 0 or LEN(sls_order_dt) != 8 then Null
				else  cast(cast(sls_order_dt as varchar) as date)
			end as sls_ship_dt,
			Case 
				when sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 then Null
				else  cast(cast(sls_ship_dt as varchar) as date)
			end as sls_ship_dt,
			Case 
				when sls_due_dt = 0 or LEN(sls_due_dt) != 8 then Null
				else  cast(cast(sls_due_dt as varchar) as date)
			end as sls_due_dt,
			Case
				when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity*ABS(sls_price)
				then sls_quantity*ABS(sls_price)
				else sls_sales
			end as sls_sales,
			sls_quantity,
			Case 
				when sls_price is null or sls_price <=0
					then sls_sales / nullif(sls_quantity,0)
				else sls_price
			end as sls_price
		FROM bronze.crm_sales_details

		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'




		Print'---------------------------------------------------'
		Print'Loading ERP Tables'
		Print'---------------------------------------------------'



		--Loading: silver.erp_cust_az12
		Set @start_time = getdate()
		Print'>> Truncating table:  silver.erp_cust_az12';
			Truncate table  silver.erp_cust_az12;


		Print'>> Inserting data Into:  silver.erp_cust_az12';

		Insert into silver.erp_cust_az12 (cid,bdate,gen)
		Select
		Case 
			when cid like 'NAS%' Then SUBSTRING(cid,4,len(cid)) 
			else cid
		end as cid2,
		Case
			when bdate > getdate() then null
			else bdate
		end as bdate,
		Case 
			When upper(TRIM(gen)) in ('F','FEMALE') then 'Female'
			When upper(TRIM(gen)) in ('M','MALE') then 'Male'
			else 'N/A'
		end as gen
		From bronze.erp_cust_az12

		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'



		--Loading: silver.erp_loc_a101
		Set @start_time = getdate()
		Print'>> Truncating table:   silver.erp_loc_a101';
			Truncate table   silver.erp_loc_a101;


		Print'>> Inserting data Into:   silver.erp_loc_a101';
		Insert into silver.erp_loc_a101 (cid,cntry)
		Select 
			Replace(cid,'-','') cid,
			Case
				when TRIM(cntry) = 'DE' Then 'Germany' 
				when TRIM(cntry) in ('Usa','Us') then 'United States'
				when TRIM(cntry) = '' or cntry is null then 'N/A'
				else cntry
			end as cntry
		from bronze.erp_loc_a101

		Set @End_time = getdate()
		Print'>> Load Duration: ' + Cast( Datediff(Second, @start_time,@end_time) as nvarchar(50)) + ' second'
		Print'--------------------------'




		--Loading: silver.erp_px_cat_g1v2
		Set @start_time = getdate()
		Print'>> Truncating table:  silver.erp_px_cat_g1v2';
			Truncate table  silver.erp_px_cat_g1v2;

		Print'>> Inserting data Into:  silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2
		(id, cat, subcat, maintenance)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2

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
Exec silver.load_silver
