USE USERDB
SELECT * FROM sales

---------------------------------------------------------
--Step 1 :- To check for duplicates
--Step 2 :- Check For Null Values
--Step 3 :- Treating Null values
--Step 4 :- Handling Negative values
--Step 5 :- Fixing Inconsistent Date Formats & Invalid Dates
--Step 6 :- Fixing Invalid Email Addresses
--Step 7 :- Checking the datatype
--------------------------------------------------------------------------------------------
--Step 1 :- To check for duplicates

WITH CTE AS(
SELECT *,
      ROW_NUMBER()OVER(PARTITION BY Transaction_id order by Transaction_id)row_num
FROM sales
)
DELETE FROM CTE
WHERE row_num>1

SELECT * FROM CTE
WHERE transaction_id IN (1001,1004,1030,1074)


--1001
--1004
--1030
--1074

--------------------------------------------------------------------------------------------
--Step 2 :- Check For Null Values

SELECT * FROM sales 
WHERE transaction_id is null
OR 
customer_id IS NULL
OR 
customer_name IS NULL
--------------------------------------------------------------------------------------------
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;
--------------------------------------------------------------------------------------------

--Step 3 :- Treating Null values

SELECT DISTINCT category from sales
-----------------category
UPDATE sales 
SET category='Unknown'
WHERE category IS NULL

-----------------customer_address
UPDATE sales 
SET customer_address='Not Available'
WHERE customer_address  IS NULL


-----------------payment_method
SELECT DISTINCT payment_method FROM sales

UPDATE sales 
SET payment_method='credit card'
WHERE payment_method IN('credit','CC','creditcard')

UPDATE sales 
SET payment_method='Cash'
WHERE payment_method IS NULL

-----------------delivery_status
SELECT DISTINCT delivery_status FROM sales

UPDATE sales 
SET delivery_status  ='Not Delivered'
WHERE delivery_status  IS NULL

-----------------price
----MEAN----2510.76804057412
SELECT AVG(price) FROM sales

---MODE
SELECT price,COUNT(*)AS max_count
FROM sales
GROUP BY price
ORDER BY max_count DESC

----Median--
SELECT DISTINCT
   PERCENTILE_CONT(0.5)WITHIN GROUP (ORDER BY Price) OVER()AS median
FROM sales

--------
SELECT category,AVG(Price) as avg_price
FROM sales
GROUP BY category


---Clothing       2539.27819389209
---Toys           2235.47169659589
---UNKNOWN        2511.41641440423
---Electronics    2663.9278355295
---Books          2574.45734735087
---Home & Kitchen  2507.05837494618 

--Unknown
UPDATE sales
SET price=2511.41
WHERE price IS NULL and category='Unknown'

--Books
UPDATE sales
SET price=2574.45
WHERE price IS NULL and category='Books'

--Home & Kitchen
UPDATE sales
SET price=2507.05
WHERE price IS NULL and category='Home & Kitchen '

--Toys
UPDATE sales
SET price=2235.47
WHERE price IS NULL and category='Toys '

--Electronics
UPDATE sales
SET price=2663.92
WHERE price IS NULL and category='Electronics '

--Clothing 
UPDATE sales
SET price=2539.27
WHERE price IS NULL and category='Clothing '

select * from sales

----------------------------------------------------------------------------------------------------------------------------------------------
--step 4 :- Handling Negative Values

SELECT * FROM sales
WHERE quantity<0

UPDATE sales
SET quantity=ABS(quantity)
WHERE quantity<0

UPDATE sales
SET total_amount=price*quantity
WHERE total_amount IS NULL OR total_amount<> price*quantity


SELECT * FROM sales
WHERE customer_id IS NULL

SELECT * FROM sales
WHERE customer_name IS NULL

UPDATE sales
SET customer_name='User'
WHERE customer_name IS NULL

--------------------------------------------------------------------------------------------

--Step 5 :- Fixing Inconsistent Date Formats & Invalid Dates


SELECT * FROM sales
WHERE purchase_date='2024-02-30'

UPDATE sales
SET purchase_date =
    CASE
        WHEN TRY_CONVERT(DATE,Purchase_date,103) IS NOT NULL
        THEN TRY_CONVERT(DATE,Purchase_date,103)
    ELSE NULL
END;


--------------------------------------------------------------------------------------------
--Step 6 :- Fixing Invalid Email Addresses

SELECT * FROM sales
WHERE email NOT LIKE '%@%'

UPDATE sales
SET email=NULL
WHERE email NOT LIKE '%@%'


--------------------------------------------------------------------------------------------
--Step 7 :- Checking the datatype

EXEC sp_help 'sales'

ALTER TABLE sales
ALTER COLUMN purchase_date DATE;

