-- ============================================================
-- STEP 6: DATA CLEANING
-- ============================================================

-- ============================================================
-- 6.1 CLEAN CUSTOMERS DATA
-- ============================================================

drop table if exists customers_clean;

create table customers_clean as 
select distinct
	trim(Customer_ID) as Customer_ID,
    trim(Customer_Name) as Customer_Name,
    trim(Segment)		as Segment,
    cast(nullif(trim(Age), '') as unsigned) as Age,
    trim(Country)		as Country,
    trim(City)			as City,
    trim(State)			as State,
    trim(Postal_Code)	as Postal_Code,
    trim(Region)		as Region
from customers_raw;

select count(*) as cleaned_customer_rows
from customers_clean;

-- ============================================================
-- 6.1.1 VALIDATE CUSTOMERS_CLEAN
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Customer_ID) AS unique_customer_ids,
    SUM(Customer_ID IS NULL OR Customer_ID = '') AS missing_customer_ids,
    SUM(Age IS NULL) AS missing_age,
    SUM(Age < 18 OR Age > 100) AS invalid_age
FROM customers_clean;
    
-- ============================================================
-- 6.1.2 INVESTIGATE INVALID / MISSING AGE
-- ============================================================

select
	Customer_ID,
	Customer_Name,
	Age,
	Segment,
	City,
	State,
	Region
from customers_clean
where Age is null
   or Age < 18
   or Age > 100;
   
-- ============================================================
-- 6.1.3 CLEAN INVALID CUSTOMER AGE
-- Business rule:
-- Valid customer age = 18 to 100
-- Unknown/invalid values are stored as NULL
-- ============================================================

update customers_clean
set Age = Null
where Age < 18
   or Age > 100;

-- Error occured MySQL Workbench blocked the UPDATE because Safe Update Mode (Error 1175) is enabled. You do not need to disable Safe Updates permanently. For this project, use a temporary session-level setting.
-- Run these three statements together:

-- Temporarily disable safe update mode
SET SQL_SAFE_UPDATES = 0;

UPDATE customers_clean
SET Age = NULL
WHERE Age < 18
   OR Age > 100;

-- Turn safe update mode back on
SET SQL_SAFE_UPDATES = 1;

-- Then run our validation
select
	count(*) as total_rows,
    count(distinct Customer_ID) as unique_customer_ids,
    sum(customer_ID is null or Customer_ID = '') as missing_customer_id,
    sum(Age is null or Age > 100) as missing_age,
    sum(Age is null or Age < 18) as Invalid_age
from customers_clean;

-- ============================================================
-- 6.1.4 FINAL CUSTOMER CLEANING VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Customer_ID) AS unique_customer_ids,

    SUM(
        Customer_ID IS NULL
        OR TRIM(Customer_ID) = ''
    ) AS missing_customer_ids,

    SUM(
        Age IS NULL
    ) AS missing_age,

    SUM(
        Age IS NOT NULL
        AND (Age < 18 OR Age > 100)
    ) AS invalid_age

FROM customers_clean;

-- ============================================================
-- 6.2 CLEAN PRODUCTS DATA
-- ============================================================

DROP TABLE IF EXISTS products_clean;

CREATE TABLE products_clean AS
SELECT
    TRIM(Product_ID) AS Product_ID,

    CASE
        WHEN LOWER(TRIM(Category)) = 'grocery'
            THEN 'Grocery'
        ELSE TRIM(Category)
    END AS Category,

    TRIM(Sub_Category) AS Sub_Category,
    TRIM(Product_Name) AS Product_Name,

    NULLIF(TRIM(Brand), '') AS Brand,

    CAST(
        NULLIF(TRIM(Unit_Cost), '')
        AS DECIMAL(10,2)
    ) AS Unit_Cost,

    CAST(
        NULLIF(TRIM(Unit_Price), '')
        AS DECIMAL(10,2)
    ) AS Unit_Price

FROM products_raw;

-- Now validate only the basic result

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Product_ID) AS unique_product_ids,
    SUM(Product_ID IS NULL OR Product_ID = '') AS missing_product_ids,
    SUM(Brand IS NULL) AS missing_brand,
    SUM(Unit_Cost IS NULL) AS missing_unit_cost,
    SUM(Unit_Price IS NULL) AS missing_unit_price
FROM products_clean;

-- ============================================================
-- 6.2.1 INVESTIGATE DUPLICATE PRODUCT IDs
-- ============================================================

SELECT
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Brand,
    Unit_Cost,
    Unit_Price
FROM products_clean
WHERE Product_ID IN
(
    SELECT Product_ID
    FROM products_clean
    GROUP BY Product_ID
    HAVING COUNT(*) > 1
)
ORDER BY Product_ID;

-- ============================================================
-- 6.2.2 REMOVE EXACT DUPLICATE PRODUCT RECORDS
-- ============================================================

-- DROP TABLE IF EXISTS products_dedup;

CREATE TABLE products_dedup AS
SELECT DISTINCT
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Brand,
    Unit_Cost,
    Unit_Price
FROM products_clean;

-- Now check the results

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Product_ID) AS unique_product_ids
FROM products_dedup;

-- ============================================================
-- 6.2.3 INVESTIGATE MISSING PRODUCT VALUES
-- ============================================================

SELECT
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Brand,
    Unit_Cost,
    Unit_Price
FROM products_dedup
WHERE Brand IS NULL
   OR Unit_Cost IS NULL
   OR Unit_Price IS NULL
ORDER BY Product_ID;

-- 6.2.4 — Fix the missing Brand

set sql_safe_updates = 0;

update products_dedup
set Brand = 'FreshChoice'
where Product_ID = 'PROD0150'
  and Brand is null;

set sql_safe_updates = 1;

-- Then validate both problematic products:

SELECT
    Product_ID,
    Product_Name,
    Brand,
    Unit_Cost,
    Unit_Price
FROM products_dedup
WHERE Product_ID IN ('PROD0150', 'PROD0220');

-- ============================================================
-- 6.2.5 FINAL PRODUCTS DATA QUALITY CHECK
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Product_ID) AS unique_product_ids,

    SUM(Product_ID IS NULL OR TRIM(Product_ID) = '')
        AS missing_product_id,

    SUM(Category IS NULL OR TRIM(Category) = '')
        AS missing_category,

    SUM(Sub_Category IS NULL OR TRIM(Sub_Category) = '')
        AS missing_sub_category,

    SUM(Product_Name IS NULL OR TRIM(Product_Name) = '')
        AS missing_product_name,

    SUM(Brand IS NULL OR TRIM(Brand) = '')
        AS missing_brand,

    SUM(Unit_Cost IS NULL)
        AS missing_unit_cost,

    SUM(Unit_Price IS NULL)
        AS missing_unit_price,

    SUM(Unit_Cost < 0)
        AS invalid_unit_cost,

    SUM(Unit_Price < 0)
        AS invalid_unit_price

FROM products_dedup;


-- ============================================================
-- STEP 6.3: CLEAN SALES DATA
-- ============================================================

-- 6.3.1 CREATE WORKING SALES TABLE
-- Keep sales_raw unchanged for audit/reconciliation

-- DROP TABLE IF EXISTS sales_clean;

CREATE TABLE sales_clean AS
SELECT
    TRIM(Order_Line)   AS Order_Line,
    TRIM(Order_ID)     AS Order_ID,
    TRIM(Order_Date)   AS Order_Date,
    TRIM(Ship_Date)    AS Ship_Date,
    TRIM(Ship_Mode)    AS Ship_Mode,
    TRIM(Customer_ID)  AS Customer_ID,
    TRIM(Product_ID)   AS Product_ID,
    TRIM(Quantity)     AS Quantity,
    TRIM(Unit_Price)   AS Unit_Price,
    TRIM(Discount)     AS Discount,
    TRIM(Sales)        AS Sales,
    TRIM(Profit)       AS Profit,
    TRIM(Payment_Mode) AS Payment_Mode
FROM sales_raw;

select count(*) as sales_clean_rows
from sales_raw;

-- ============================================================
-- 6.3.2 INVESTIGATE DUPLICATE ORDER LINES
-- ============================================================

select
	Order_Line,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit,
    Payment_Mode
from sales_clean
where Order_Line in
(
	select Order_Line
    from sales_clean
    group by Order_Line
    having count(*) > 1
);	

-- ============================================================
-- 6.3.3 CHECK EXACT DUPLICATE SALES RECORDS
-- ============================================================

SELECT
    Order_Line,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit,
    Payment_Mode,
    COUNT(*) AS occurrence_count
FROM sales_clean
GROUP BY
    Order_Line,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit,
    Payment_Mode
HAVING COUNT(*) > 1
ORDER BY CAST(Order_Line AS UNSIGNED);

-- ============================================================
-- 6.3.4 CREATE DEDUPLICATED SALES TABLE
-- ============================================================

-- DROP TABLE IF EXISTS sales_dedup;

CREATE TABLE sales_dedup AS
SELECT DISTINCT
    Order_Line,
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit,
    Payment_Mode
FROM sales_clean;

-- Then validate:

select
	count(*) as totaal_rows,
    count(distinct Order_Line) as unique_order_lines
from sales_dedup;

-- ============================================================
-- 6.3.5 INVESTIGATE INVALID SALES VALUES
-- Business rules:
-- Quantity must be > 0
-- Discount must be between 0 and 1
-- Sales must be >= 0
-- ============================================================

SELECT
    Order_Line,
    Order_ID,
    Customer_ID,
    Product_ID,
    Quantity,
    Discount,
    Sales,
    Profit
FROM sales_dedup
WHERE CAST(NULLIF(TRIM(Quantity), '') AS SIGNED) <= 0
   OR CAST(NULLIF(TRIM(Discount), '') AS DECIMAL(10,2))
        NOT BETWEEN 0 AND 1
   OR CAST(NULLIF(TRIM(Sales), '') AS DECIMAL(12,2)) < 0
ORDER BY CAST(Order_Line AS UNSIGNED);

-- ============================================================
-- 6.3.6 CLEAN INVALID BUSINESS VALUES
-- Invalid/unrecoverable values -> NULL
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

-- Invalid Quantity
UPDATE sales_dedup
SET Quantity = NULL
WHERE CAST(NULLIF(TRIM(Quantity), '') AS SIGNED) <= 0;

-- Invalid Discount
UPDATE sales_dedup
SET Discount = NULL
WHERE CAST(NULLIF(TRIM(Discount), '') AS DECIMAL(10,2))
      NOT BETWEEN 0 AND 1;

-- Invalid Sales
UPDATE sales_dedup
SET Sales = NULL
WHERE CAST(NULLIF(TRIM(Sales), '') AS DECIMAL(12,2)) < 0;

SET SQL_SAFE_UPDATES = 1;

-- Now validate:

SELECT
    SUM(Quantity IS NULL OR TRIM(Quantity) = '')
        AS missing_quantity,

    SUM(
        Quantity IS NOT NULL
        AND CAST(Quantity AS SIGNED) <= 0
    ) AS invalid_quantity,
    
    SUM(Discount IS NULL OR TRIM(Discount) = '')
        AS missing_discount,

    SUM(
        Discount IS NOT NULL
        AND CAST(Discount AS DECIMAL(10,2)) NOT BETWEEN 0 AND 1
    ) AS invalid_discount,

    SUM(Sales IS NULL OR TRIM(Sales) = '')
        AS missing_sales,

    SUM(
        Sales IS NOT NULL
        AND CAST(Sales AS DECIMAL(12,2)) < 0
    ) AS negative_sales

FROM sales_dedup;

-- ============================================================
-- 6.3.7 INVESTIGATE INVALID ORDER DATES
-- ============================================================

SELECT
    Order_Line,
    Order_ID,
    Order_Date
FROM sales_dedup
WHERE NULLIF(TRIM(Order_Date), '') IS NOT NULL
  AND STR_TO_DATE(TRIM(Order_Date), '%d-%m-%Y') IS NULL;
  
-- ============================================================
-- 6.3.8 CLEAN INVALID ORDER DATE
-- Invalid/unrecoverable date -> NULL
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

-- UPDATE sales_dedup
-- SET Order_Date = NULL
-- WHERE NULLIF(TRIM(Order_Date), '') IS NOT NULL
--  AND STR_TO_DATE(TRIM(Order_Date), '%d-%m-%Y') IS NULL;

UPDATE sales_dedup
SET Order_Date = NULL
WHERE Order_Line = '100'
  AND Order_ID = 'ORD000050'
  AND TRIM(Order_Date) = '31-02-2024';


SET SQL_SAFE_UPDATES = 1;

-- Now validate:

SELECT
    SUM(Order_Date IS NULL OR TRIM(Order_Date) = '')
        AS missing_order_date,

    SUM(
        NULLIF(TRIM(Order_Date), '') IS NOT NULL
        AND STR_TO_DATE(TRIM(Order_Date), '%d-%m-%Y') IS NULL
    ) AS invalid_order_date
FROM sales_dedup;

-- ============================================================
-- 6.3.9 VALIDATE SHIP DATES
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(
        Ship_Date IS NULL
        OR TRIM(Ship_Date) = ''
    ) AS missing_ship_date,

    SUM(
        NULLIF(TRIM(Ship_Date), '') IS NOT NULL
        AND STR_TO_DATE(TRIM(Ship_Date), '%d-%m-%Y') IS NULL
    ) AS invalid_ship_date

FROM sales_dedup;

-- ============================================================
-- 6.3.10 CONVERT TEXT DATES TO MYSQL DATE
-- Step A: Add temporary DATE columns
-- ============================================================

alter table sales_dedup
add column Order_Date_New date null,
add column Ship_Date_New date null;

-- Populate them

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_dedup
SET
    Order_Date_New =
        CASE
            WHEN NULLIF(TRIM(Order_Date), '') IS NULL THEN NULL
            ELSE STR_TO_DATE(TRIM(Order_Date), '%d-%m-%Y')
        END,

    Ship_Date_New =
        CASE
            WHEN NULLIF(TRIM(Ship_Date), '') IS NULL THEN NULL
            ELSE STR_TO_DATE(TRIM(Ship_Date), '%d-%m-%Y')
        END;

SET SQL_SAFE_UPDATES = 1;

-- Validate the conversion

SELECT
    COUNT(*) AS total_rows,

    SUM(Order_Date_New IS NULL) AS null_order_dates,
    SUM(Ship_Date_New IS NULL) AS null_ship_dates,

    MIN(Order_Date_New) AS earliest_order_date,
    MAX(Order_Date_New) AS latest_order_date,

    MIN(Ship_Date_New) AS earliest_ship_date,
    MAX(Ship_Date_New) AS latest_ship_date

FROM sales_dedup;

-- ============================================================
-- 6.3.11 VALIDATE ORDER DATE vs SHIP DATE
-- Business rule:
-- Ship_Date must be >= Order_Date
-- ============================================================

SELECT
    COUNT(*) AS ship_before_order_count
FROM sales_dedup
WHERE Order_Date_New IS NOT NULL
  AND Ship_Date_New IS NOT NULL
  AND Ship_Date_New < Order_Date_New;

-- ============================================================
-- 6.3.12 PROMOTE CLEAN DATE COLUMNS
-- Keep original columns temporarily as backup
-- ============================================================

alter table sales_dedup
	rename column Order_Date to Order_Date_Original,
    rename column Ship_Date to Ship_Date_Original,
    rename column Order_Date_New to Order_Date,
    rename column Ship_Date_New to Ship_Date;

-- Then validate the structure:

describe sales_dedup;

-- Step 6.3.13 — Verify the new date columns

select 
	column_name,
    data_type
from information_schema.columns
where table_schema = 'supermart_analytics'
  and table_name = 'sales_dedup'
  and column_name in ('Order_Date', 'Ship_Date'); 

-- ============================================================
-- STEP 6.4.1
-- INVESTIGATE REMAINING MISSING NUMERIC VALUES
-- ============================================================

SELECT
    Order_Line,
    Order_ID,
    Order_Date,
    Customer_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit
FROM sales_dedup
WHERE NULLIF(TRIM(Quantity), '') IS NULL
   OR NULLIF(TRIM(Discount), '') IS NULL
   OR NULLIF(TRIM(Sales), '') IS NULL
ORDER BY CAST(Order_Line AS UNSIGNED);

-- ============================================================
-- STEP 6.4.2
-- VALIDATE SALES CALCULATION RULE
-- ============================================================

SELECT
    Order_Line,
    Quantity,
    Unit_Price,
    Discount,
    Sales,

    ROUND(
        CAST(Quantity AS DECIMAL(12,2))
        * CAST(Unit_Price AS DECIMAL(12,2))
        * (1 - CAST(Discount AS DECIMAL(10,4))),
        2
    ) AS calculated_sales,

    ROUND(
        CAST(Sales AS DECIMAL(12,2))
        -
        (
            CAST(Quantity AS DECIMAL(12,2))
            * CAST(Unit_Price AS DECIMAL(12,2))
            * (1 - CAST(Discount AS DECIMAL(10,4)))
        ),
        2
    ) AS difference

FROM sales_dedup

WHERE NULLIF(TRIM(Quantity), '') IS NOT NULL
  AND NULLIF(TRIM(Unit_Price), '') IS NOT NULL
  AND NULLIF(TRIM(Discount), '') IS NOT NULL
  AND NULLIF(TRIM(Sales), '') IS NOT NULL

ORDER BY CAST(Order_Line AS UNSIGNED)

LIMIT 20;

-- ============================================================
-- STEP 6.4.3
-- CALCULATE / PREVIEW MISSING NUMERIC VALUES
-- Do not update yet
-- ============================================================

SELECT
    Order_Line,
    Quantity,
    Unit_Price,
    Discount,
    Sales,

    -- Missing Quantity
    CASE
        WHEN NULLIF(TRIM(Quantity), '') IS NULL
        THEN ROUND(
            CAST(Sales AS DECIMAL(12,2))
            /
            (
                CAST(Unit_Price AS DECIMAL(12,2))
                * (1 - CAST(Discount AS DECIMAL(10,4)))
            ),
            2
        )
    END AS calculated_quantity,

    -- Missing Discount
    CASE
        WHEN NULLIF(TRIM(Discount), '') IS NULL
        THEN ROUND(
            1 -
            (
                CAST(Sales AS DECIMAL(12,2))
                /
                (
                    CAST(Quantity AS DECIMAL(12,2))
                    * CAST(Unit_Price AS DECIMAL(12,2))
                )
            ),
            4
        )
    END AS calculated_discount,

    -- Missing Sales
    CASE
        WHEN NULLIF(TRIM(Sales), '') IS NULL
        THEN ROUND(
            CAST(Quantity AS DECIMAL(12,2))
            * CAST(Unit_Price AS DECIMAL(12,2))
            * (1 - CAST(Discount AS DECIMAL(10,4))),
            2
        )
    END AS calculated_sales

FROM sales_dedup
WHERE NULLIF(TRIM(Quantity), '') IS NULL
   OR NULLIF(TRIM(Discount), '') IS NULL
   OR NULLIF(TRIM(Sales), '') IS NULL

ORDER BY CAST(Order_Line AS UNSIGNED);

-- ============================================================
-- STEP 6.4.4
-- REPAIR MISSING NUMERIC VALUES
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

-- 1. Reconstruct missing Quantity
UPDATE sales_dedup
SET Quantity = '7'
WHERE Order_Line = '1700'
  AND NULLIF(TRIM(Quantity), '') IS NULL;

-- 2. Reconstruct missing Discount
UPDATE sales_dedup
SET Discount = '0.15'
WHERE Order_Line = '2100'
  AND NULLIF(TRIM(Discount), '') IS NULL;

-- 3. Reconstruct missing Sales
UPDATE sales_dedup
SET Sales = '2558.08'
WHERE Order_Line = '2500'
  AND NULLIF(TRIM(Sales), '') IS NULL;

SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- STEP 6.4.5
-- VALIDATE NUMERIC REPAIRS
-- ============================================================

SELECT
    Order_Line,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit
FROM sales_dedup
WHERE Order_Line IN ('1700', '2100', '2500')
ORDER BY CAST(Order_Line AS UNSIGNED);

-- ============================================================
-- STEP 6.4.6
-- FINAL NUMERIC VALIDATION BEFORE DATATYPE CONVERSION
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(
        Quantity IS NULL
        OR TRIM(Quantity) = ''
    ) AS missing_quantity,

    SUM(
        Unit_Price IS NULL
        OR TRIM(Unit_Price) = ''
    ) AS missing_unit_price,

    SUM(
        Discount IS NULL
        OR TRIM(Discount) = ''
    ) AS missing_discount,

    SUM(
        Sales IS NULL
        OR TRIM(Sales) = ''
    ) AS missing_sales,

    SUM(
        Profit IS NULL
        OR TRIM(Profit) = ''
    ) AS missing_profit,

    SUM(
        CAST(Quantity AS SIGNED) <= 0
    ) AS invalid_quantity,

    SUM(
        CAST(Discount AS DECIMAL(10,4)) NOT BETWEEN 0 AND 1
    ) AS invalid_discount,

    SUM(
        CAST(Sales AS DECIMAL(12,2)) < 0
    ) AS negative_sales

FROM sales_dedup;

-- ============================================================
-- STEP 6.4.7
-- INVESTIGATE MISSING PROFIT
-- ============================================================

SELECT
    Order_Line,
    Order_ID,
    Order_Date,
    Customer_ID,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit
FROM sales_dedup
WHERE Profit IS NULL
   OR TRIM(Profit) = '';
   
-- ============================================================
-- STEP 6.4.8
-- VALIDATE PROFIT CALCULATION RULE
-- Hypothesis:
-- Profit = Sales - (Quantity * Unit_Cost)
-- ============================================================

SELECT
    s.Order_Line,
    s.Product_ID,
    s.Quantity,
    s.Sales,
    s.Profit,
    p.Unit_Cost,

    ROUND(
        CAST(s.Sales AS DECIMAL(12,2))
        -
        (
            CAST(s.Quantity AS DECIMAL(12,2))
            * CAST(p.Unit_Cost AS DECIMAL(12,2))
        ),
        2
    ) AS calculated_profit,

    ROUND(
        CAST(s.Profit AS DECIMAL(12,2))
        -
        (
            CAST(s.Sales AS DECIMAL(12,2))
            -
            (
                CAST(s.Quantity AS DECIMAL(12,2))
                * CAST(p.Unit_Cost AS DECIMAL(12,2))
            )
        ),
        2
    ) AS difference

FROM sales_dedup s

INNER JOIN products_dedup p
    ON TRIM(s.Product_ID) = TRIM(p.Product_ID)

WHERE NULLIF(TRIM(s.Profit), '') IS NOT NULL
  AND NULLIF(TRIM(s.Sales), '') IS NOT NULL
  AND NULLIF(TRIM(s.Quantity), '') IS NOT NULL
  AND p.Unit_Cost IS NOT NULL

ORDER BY CAST(s.Order_Line AS UNSIGNED)

LIMIT 20;

-- ============================================================
-- STEP 6.4.9
-- PREVIEW MISSING PROFIT
-- ============================================================

SELECT
    s.Order_Line,
    s.Product_ID,
    s.Quantity,
    s.Sales,
    p.Unit_Cost,

    ROUND(
        CAST(s.Sales AS DECIMAL(12,2))
        -
        (
            CAST(s.Quantity AS DECIMAL(12,2))
            * CAST(p.Unit_Cost AS DECIMAL(12,2))
        ),
        2
    ) AS calculated_profit

FROM sales_dedup s

INNER JOIN products_dedup p
    ON TRIM(s.Product_ID) = TRIM(p.Product_ID)

WHERE s.Order_Line = '2900';

-- ============================================================
-- STEP 6.4.10
-- REPAIR MISSING PROFIT
-- ============================================================

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_dedup
SET Profit = '1647.28'
WHERE Order_Line = '2900'
  AND (Profit IS NULL OR TRIM(Profit) = '');

SET SQL_SAFE_UPDATES = 1;

-- ============================================================
-- STEP 6.4.11
-- VALIDATE PROFIT REPAIR
-- ============================================================

SELECT
    Order_Line,
    Product_ID,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit
FROM sales_dedup
WHERE Order_Line = '2900';

-- ============================================================
-- STEP 6.4.12
-- FINAL NUMERIC DATA QUALITY VALIDATION
-- Expected: all issue counts = 0
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(Quantity IS NULL OR TRIM(Quantity) = '')
        AS missing_quantity,

    SUM(Unit_Price IS NULL OR TRIM(Unit_Price) = '')
        AS missing_unit_price,

    SUM(Discount IS NULL OR TRIM(Discount) = '')
        AS missing_discount,

    SUM(Sales IS NULL OR TRIM(Sales) = '')
        AS missing_sales,

    SUM(Profit IS NULL OR TRIM(Profit) = '')
        AS missing_profit,

    SUM(
        Quantity IS NOT NULL
        AND TRIM(Quantity) <> ''
        AND CAST(Quantity AS SIGNED) <= 0
    ) AS invalid_quantity,

    SUM(
        Discount IS NOT NULL
        AND TRIM(Discount) <> ''
        AND CAST(Discount AS DECIMAL(10,4)) NOT BETWEEN 0 AND 1
    ) AS invalid_discount,

    SUM(
        Sales IS NOT NULL
        AND TRIM(Sales) <> ''
        AND CAST(Sales AS DECIMAL(12,2)) < 0
    ) AS negative_sales

FROM sales_dedup;

-- ============================================================
-- STEP 6.4.13
-- CONVERT SALES NUMERIC COLUMNS TO PROPER DATA TYPES
-- ============================================================

alter table sales_dedup
	modify column Quantity int,
    modify column Unit_Price decimal(12,2),
    modify column Discount decimal (10,4),
    modify column Sales decimal (14,2),
    modify column Profit decimal (14,2);
    
-- ============================================================
-- STEP 6.4.14
-- VERIFY NUMERIC COLUMN DATA TYPES
-- ============================================================

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_TYPE
FROM information_schema.columns
WHERE table_schema = 'supermart_analytics'
  AND table_name = 'sales_dedup'
  AND column_name IN (
      'Quantity',
      'Unit_Price',
      'Discount',
      'Sales',
      'Profit'
  )
ORDER BY ORDINAL_POSITION;

-- ============================================================
-- STEP 6.4.15
-- VALIDATE SALES PRODUCT IDs AGAINST CLEAN PRODUCT MASTER
-- ============================================================

SELECT
    s.Product_ID,
    COUNT(*) AS sales_rows,
    ROUND(SUM(s.Sales), 2) AS affected_sales,
    ROUND(SUM(s.Profit), 2) AS affected_profit
FROM sales_dedup s
LEFT JOIN products_dedup p
    ON TRIM(s.Product_ID) = TRIM(p.Product_ID)
WHERE p.Product_ID IS NULL
GROUP BY s.Product_ID
ORDER BY sales_rows DESC;

-- ============================================================
-- STEP 6.4.16
-- CHECK PRODUCTS_DEDUP STRUCTURE BEFORE ADDING ORPHAN PRODUCT
-- ============================================================

DESCRIBE products_dedup;

-- ============================================================
-- STEP 6.4.17
-- ADD PLACEHOLDER PRODUCT FOR ORPHAN PRODUCT_ID
-- Business rule:
-- Preserve valid sales transaction.
-- Unknown product attributes are explicitly identified.
-- Do NOT fabricate Unit_Cost / Unit_Price.
-- ============================================================

INSERT INTO products_dedup
(
    Product_ID,
    Category,
    Sub_Category,
    Product_Name,
    Brand,
    Unit_Cost,
    Unit_Price
)
VALUES
(
    'PROD9999',
    'Unknown',
    'Unknown',
    'Unknown Product',
    'Unknown',
    NULL,
    NULL
);

-- ============================================================
-- STEP 6.4.18
-- VERIFY PLACEHOLDER PRODUCT
-- ============================================================

SELECT *
FROM products_dedup
WHERE Product_ID = 'PROD9999';

-- ============================================================
-- STEP 6.4.19
-- RECHECK ORPHAN PRODUCT IDs
-- Expected result: 0
-- ============================================================

SELECT COUNT(*) AS orphan_product_rows
FROM sales_dedup s
LEFT JOIN products_dedup p
    ON TRIM(s.Product_ID) = TRIM(p.Product_ID)
WHERE p.Product_ID IS NULL;

-- ============================================================
-- STEP 6.4.20
-- VALIDATE SALES CUSTOMER IDs AGAINST CLEAN CUSTOMER MASTER
-- ============================================================

SELECT
    s.Customer_ID,
    COUNT(*) AS sales_rows,
    ROUND(SUM(s.Sales), 2) AS affected_sales,
    ROUND(SUM(s.Profit), 2) AS affected_profit
FROM sales_dedup s

LEFT JOIN customers_clean c
    ON TRIM(s.Customer_ID) = TRIM(c.Customer_ID)

WHERE c.Customer_ID IS NULL

GROUP BY s.Customer_ID
ORDER BY sales_rows DESC;

-- ============================================================
-- STEP 6.4.21
-- CHECK CUSTOMERS_CLEAN STRUCTURE
-- BEFORE ADDING UNKNOWN CUSTOMER
-- ============================================================

DESCRIBE customers_clean;

-- ============================================================
-- STEP 6.4.22
-- ADD PLACEHOLDER CUSTOMER FOR ORPHAN CUSTOMER_ID
--
-- Business rule:
-- Preserve the valid sales transaction.
-- Do not fabricate customer demographic information.
-- ============================================================

INSERT INTO customers_clean
(
    Customer_ID,
    Customer_Name,
    Segment,
    Age,
    Country,
    City,
    State,
    Postal_Code,
    Region
)
VALUES
(
    'CUST9999',
    'Unknown Customer',
    'Unknown',
    NULL,
    'Unknown',
    'Unknown',
    'Unknown',
    NULL,
    'Unknown'
);

-- ============================================================
-- STEP 6.4.23
-- VERIFY PLACEHOLDER CUSTOMER
-- ============================================================

SELECT *
FROM customers_clean
WHERE Customer_ID = 'CUST9999';

-- ============================================================
-- STEP 6.4.24
-- RECHECK ORPHAN CUSTOMER IDs
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS orphan_customer_rows
FROM sales_dedup s
LEFT JOIN customers_clean c
    ON TRIM(s.Customer_ID) = TRIM(c.Customer_ID)
WHERE c.Customer_ID IS NULL;

   
-- ============================================================  $$$$$$$$$$$
-- STEP 6.5.4 - REBUILD RETURNS_CLEAN CORRECTLY
-- ============================================================  $$$$$$$$$$$

DROP TABLE IF EXISTS returns_clean;

CREATE TABLE returns_clean AS
SELECT DISTINCT
    TRIM(Return_ID)      AS Return_ID,
    TRIM(Order_ID)       AS Order_ID,
    TRIM(Order_Line)     AS Order_Line,
    TRIM(Return_Date)    AS Return_Date,
    TRIM(Return_Reason)  AS Return_Reason,
    TRIM(Refund_Amount)  AS Refund_Amount,
    TRIM(Return_Status)  AS Return_Status
FROM returns_raw;

DESCRIBE returns_clean;

-- ============================================================
-- STEP 6.5.2
-- CHECK RETURNS ROW COUNT
-- ============================================================

SELECT COUNT(*) AS returns_clean_rows
FROM returns_clean;



SELECT
    Return_ID,
    Order_ID,
    Order_Line,
    Return_Date,
    Return_Reason,
    Refund_Amount,
    Return_Status
FROM returns_clean
WHERE Refund_Amount IS NULL
   OR TRIM(Refund_Amount) = '';
   
-- ============================================================
-- STEP 6.5.6
-- VERIFY SALE FOR MISSING REFUND AMOUNT
-- ============================================================

SELECT
    r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    r.Return_Date,
    r.Return_Reason,
    r.Refund_Amount,
    r.Return_Status,

    s.Order_Date,
    s.Ship_Date,
    s.Customer_ID,
    s.Product_ID,
    s.Quantity,
    s.Unit_Price,
    s.Discount,
    s.Sales,
    s.Profit

FROM returns_clean r

LEFT JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE r.Refund_Amount IS NULL
   OR TRIM(r.Refund_Amount) = '';

-- ============================================================
-- STEP 6.5.7
-- CHECK DUPLICATE RETURN IDs
-- ============================================================

SELECT
    Return_ID,
    COUNT(*) AS duplicate_count
FROM returns_clean
GROUP BY Return_ID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, Return_ID;

-- ============================================================
-- STEP 6.5.8
-- CHECK MULTIPLE RETURNS FOR SAME ORDER LINE
-- ============================================================

SELECT
    Order_ID,
    Order_Line,
    COUNT(*) AS return_count
FROM returns_clean
GROUP BY
    Order_ID,
    Order_Line
HAVING COUNT(*) > 1
ORDER BY return_count DESC, Order_ID, Order_Line;

-- ============================================================
-- STEP 6.5.9
-- CHECK INVALID RETURN DATES
-- ============================================================

SELECT
    Return_ID,
    Order_ID,
    Order_Line,
    Return_Date
FROM returns_clean
WHERE NULLIF(TRIM(Return_Date), '') IS NOT NULL
  AND STR_TO_DATE(TRIM(Return_Date), '%d-%m-%Y') IS NULL
ORDER BY Return_ID;

-- ============================================================
-- STEP 6.5.10
-- RETURN DATE QUALITY SUMMARY
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(
        Return_Date IS NULL
        OR TRIM(Return_Date) = ''
    ) AS missing_return_date,

    SUM(
        NULLIF(TRIM(Return_Date), '') IS NOT NULL
        AND STR_TO_DATE(TRIM(Return_Date), '%d-%m-%Y') IS NULL
    ) AS invalid_return_date

FROM returns_clean;

-- ============================================================
-- STEP 6.5.11
-- CREATE CLEAN RETURN DATE COLUMN
-- Invalid/unrecoverable dates -> NULL
-- ============================================================

ALTER TABLE returns_clean
ADD COLUMN Return_Date_New DATE;

-- Populate it

SET SQL_SAFE_UPDATES = 0;

UPDATE returns_clean
SET Return_Date_New =
    CASE
        -- Missing date
        WHEN Return_Date IS NULL
             OR TRIM(Return_Date) = ''
        THEN NULL

        -- Known invalid date
        WHEN TRIM(Return_Date) = '31-11-2025'
        THEN NULL

        -- Valid dates
        ELSE STR_TO_DATE(TRIM(Return_Date), '%d-%m-%Y')
    END;

SET SQL_SAFE_UPDATES = 1;

-- 6.5.12 — Validate

SELECT
    COUNT(*) AS total_rows,
    SUM(Return_Date_New IS NULL) AS null_return_dates,
    MIN(Return_Date_New) AS earliest_return_date,
    MAX(Return_Date_New) AS latest_return_date
FROM returns_clean;

SELECT
    Return_ID,
    Order_ID,
    Order_Line,
    Return_Date,
    Return_Date_New
FROM returns_clean
WHERE Return_ID = 'RET0456';

-- ============================================================
-- STEP 6.5.13
-- CHECK RETURN DATE < ORDER DATE
-- Business rule: Return_Date must be >= Order_Date
-- ============================================================

SELECT
    COUNT(*) AS return_before_order_count
FROM returns_clean r

INNER JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE r.Return_Date_New IS NOT NULL
  AND s.Order_Date IS NOT NULL
  AND r.Return_Date_New < s.Order_Date;
  
-- ============================================================
-- STEP 6.5.14
-- CHECK ORPHAN RETURN RECORDS
-- Every return should match a sales transaction
-- ============================================================

SELECT
    COUNT(*) AS orphan_return_rows
FROM returns_clean r

LEFT JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE s.Order_ID IS NULL;

-- ============================================================
-- STEP 6.5.15
-- INVESTIGATE ORPHAN RETURN RECORD
-- ============================================================

SELECT
    r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    r.Return_Date_New AS Return_Date,
    r.Return_Reason,
    r.Refund_Amount,
    r.Return_Status
FROM returns_clean r

LEFT JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE s.Order_ID IS NULL;

-- ============================================================
-- STEP 6.5.16
-- CHECK WHETHER ORPHAN ORDER_ID EXISTS IN SALES
-- ============================================================

SELECT
    Order_Line,
    Order_ID,
    Order_Date,
    Customer_ID,
    Product_ID,
    Quantity,
    Sales,
    Profit
FROM sales_dedup
WHERE TRIM(Order_ID) = 'ORD999999'
ORDER BY CAST(Order_Line AS UNSIGNED);

-- ============================================================
-- STEP 6.5.17
-- CREATE VALID RETURNS TABLE
-- Keep only returns linked to an existing sales transaction
-- Preserve returns_clean for audit/history
-- ============================================================

DROP TABLE IF EXISTS returns_valid;

CREATE TABLE returns_valid AS
SELECT r.*
FROM returns_clean r
INNER JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED);

-- Then immediately validate the counts:

SELECT
    (SELECT COUNT(*) FROM returns_clean) AS original_returns,
    (SELECT COUNT(*) FROM returns_valid) AS valid_returns,
    (SELECT COUNT(*) FROM returns_clean)
      - (SELECT COUNT(*) FROM returns_valid) AS excluded_orphans;
      
-- ============================================================
-- STEP 6.5.18
-- CHECK REFUND AMOUNT AGAINST ORIGINAL SALES
-- Business rule:
-- Refund should normally be > 0 and <= original Sales
-- ============================================================

SELECT
    r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    r.Refund_Amount,
    s.Sales AS Original_Sales,
    
    ROUND(
        CAST(r.Refund_Amount AS DECIMAL(14,2))
        - s.Sales,
        2
    ) AS refund_minus_sales

FROM returns_valid r

INNER JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE
       (
           NULLIF(TRIM(r.Refund_Amount), '') IS NOT NULL
           AND CAST(r.Refund_Amount AS DECIMAL(14,2)) <= 0
       )
    OR (
           NULLIF(TRIM(r.Refund_Amount), '') IS NOT NULL
           AND CAST(r.Refund_Amount AS DECIMAL(14,2)) > s.Sales
       )

ORDER BY CAST(r.Order_Line AS UNSIGNED);

-- ============================================================
-- STEP 6.5.19
-- INVESTIGATE MISSING REFUND AMOUNT
-- Compare missing refund with original sales transaction
-- ============================================================

SELECT
    r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    r.Return_Date_New AS Return_Date,
    r.Return_Reason,
    r.Return_Status,
    r.Refund_Amount,
    
    s.Quantity,
    s.Unit_Price,
    s.Discount,
    s.Sales AS Original_Sales,
    s.Profit

FROM returns_valid r

INNER JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE r.Refund_Amount IS NULL
   OR TRIM(r.Refund_Amount) = '';

-- ============================================================
-- STEP 6.5.20
-- CHECK MISSING REFUND AMOUNTS BY RETURN STATUS
-- ============================================================

SELECT
    Return_Status,
    COUNT(*) AS total_returns,

    SUM(
        Refund_Amount IS NULL
        OR TRIM(Refund_Amount) = ''
    ) AS missing_refund_amounts

FROM returns_valid

GROUP BY Return_Status
ORDER BY Return_Status;

-- ============================================================
-- STEP 6.5.21
-- CREATE NUMERIC REFUND AMOUNT COLUMN
-- Preserve missing Pending refund as NULL
-- ============================================================

ALTER TABLE returns_valid
ADD COLUMN Refund_Amount_New DECIMAL(14,2);

SET SQL_SAFE_UPDATES = 0;

UPDATE returns_valid
SET Refund_Amount_New =
    CASE
        WHEN NULLIF(TRIM(Refund_Amount), '') IS NULL
            THEN NULL
        ELSE CAST(TRIM(Refund_Amount) AS DECIMAL(14,2))
    END;

SET SQL_SAFE_UPDATES = 1;

-- Then validate it:

SELECT
    COUNT(*) AS total_rows,
    COUNT(Refund_Amount_New) AS populated_refunds,
    SUM(Refund_Amount_New IS NULL) AS null_refunds,
    MIN(Refund_Amount_New) AS min_refund,
    MAX(Refund_Amount_New) AS max_refund,
    ROUND(SUM(Refund_Amount_New), 2) AS total_refund
FROM returns_valid;

-- ============================================================
-- STEP 6.5.22
-- REPLACE OLD VARCHAR REFUND_AMOUNT
-- WITH CLEAN DECIMAL COLUMN
-- ============================================================

ALTER TABLE returns_valid
    RENAME COLUMN Refund_Amount TO Refund_Amount_Original,
    RENAME COLUMN Refund_Amount_New TO Refund_Amount;
    
-- Then verify the datatype:

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_TYPE
FROM information_schema.columns
WHERE table_schema = 'supermart_analytics'
  AND table_name = 'returns_valid'
  AND column_name IN (
      'Refund_Amount',
      'Refund_Amount_Original'
  );
  
-- ============================================================
-- STEP 6.5.23
-- REPLACE OLD VARCHAR RETURN_DATE
-- WITH CLEAN DATE COLUMN
-- ============================================================

ALTER TABLE returns_valid
    RENAME COLUMN Return_Date TO Return_Date_Original,
    RENAME COLUMN Return_Date_New TO Return_Date;

-- Then verify:

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_TYPE
FROM information_schema.columns
WHERE table_schema = 'supermart_analytics'
  AND table_name = 'returns_valid'
  AND column_name IN (
      'Return_Date',
      'Return_Date_Original'
  );
  
-- ============================================================
-- STEP 6.5.24
-- PROFILE RETURN REASON AND RETURN STATUS
-- Check categorical consistency
-- ============================================================

SELECT
    'Return_Reason' AS column_name,
    Return_Reason AS value,
    COUNT(*) AS row_count
FROM returns_valid
GROUP BY Return_Reason

UNION ALL

SELECT
    'Return_Status' AS column_name,
    Return_Status AS value,
    COUNT(*) AS row_count
FROM returns_valid
GROUP BY Return_Status

ORDER BY column_name, value;

-- ============================================================
-- STEP 6.5.25
-- VALIDATE RETURN REASON AND RETURN STATUS
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(
        Return_Reason IS NULL
        OR TRIM(Return_Reason) = ''
    ) AS missing_return_reason,

    SUM(
        Return_Status IS NULL
        OR TRIM(Return_Status) = ''
    ) AS missing_return_status,

    SUM(
        Return_Reason NOT IN (
            'Changed Mind',
            'Damaged',
            'Defective',
            'Late Delivery',
            'Quality Issue',
            'Wrong Item'
        )
    ) AS invalid_return_reason,

    SUM(
        Return_Status NOT IN (
            'Approved',
            'Completed',
            'Pending'
        )
    ) AS invalid_return_status

FROM returns_valid;

-- ============================================================
-- STEP 6.5.26
-- FINAL RETURNS DATA QUALITY AUDIT
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT Return_ID) AS unique_return_ids,

    SUM(Return_ID IS NULL OR TRIM(Return_ID) = '') 
        AS missing_return_id,

    SUM(Order_ID IS NULL OR TRIM(Order_ID) = '') 
        AS missing_order_id,

    SUM(Order_Line IS NULL OR TRIM(Order_Line) = '') 
        AS missing_order_line,

    SUM(Return_Date IS NULL) 
        AS missing_return_date,

    SUM(Return_Reason IS NULL OR TRIM(Return_Reason) = '') 
        AS missing_return_reason,

    SUM(Refund_Amount IS NULL) 
        AS missing_refund_amount,

    SUM(Refund_Amount < 0) 
        AS negative_refund_amount,

    SUM(Return_Status IS NULL OR TRIM(Return_Status) = '') 
        AS missing_return_status

FROM returns_valid;

-- ============================================================
-- STEP 6.5.27
-- FINAL RETURN -> SALES REFERENTIAL INTEGRITY CHECK
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS unmatched_return_rows
FROM returns_valid r

LEFT JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE s.Order_ID IS NULL;

-- ============================================================
-- STEP 6.5.28
-- FINAL RETURN DATE BUSINESS RULE CHECK
-- Return_Date must be >= Order_Date
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS return_before_order_count
FROM returns_valid r

INNER JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE r.Return_Date IS NOT NULL
  AND s.Order_Date IS NOT NULL
  AND r.Return_Date < s.Order_Date;
  
-- ============================================================
-- STEP 6.5.29
-- FINAL REFUND vs ORIGINAL SALES VALIDATION
-- Business Rule:
-- Refund_Amount >= 0
-- Refund_Amount <= Original Sales
-- Expected result: 0
-- ============================================================

SELECT
    COUNT(*) AS invalid_refund_rows
FROM returns_valid r

INNER JOIN sales_dedup s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE r.Refund_Amount IS NOT NULL
  AND (
        r.Refund_Amount < 0
        OR r.Refund_Amount > s.Sales
      );
      
-- ============================================================
-- STEP 6.5.30
-- FINAL RETURNS TABLE STRUCTURE CHECK
-- ============================================================

DESCRIBE returns_valid;

-- ============================================================
-- STEP 6.5.31
-- CHECK ORDER_LINE BEFORE NUMERIC CONVERSION
-- Expected invalid_order_lines = 0
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    SUM(
        Order_Line IS NULL
        OR TRIM(Order_Line) = ''
    ) AS missing_order_lines,

    SUM(
        Order_Line IS NOT NULL
        AND TRIM(Order_Line) <> ''
        AND TRIM(Order_Line) NOT REGEXP '^[0-9]+$'
    ) AS invalid_order_lines,

    MIN(CAST(Order_Line AS UNSIGNED)) AS min_order_line,

    MAX(CAST(Order_Line AS UNSIGNED)) AS max_order_line

FROM returns_valid;

-- ============================================================
-- STEP 6.5.32
-- CONVERT ORDER_LINE FROM VARCHAR TO INT
-- ============================================================

ALTER TABLE returns_valid
MODIFY COLUMN Order_Line INT;

-- ============================================================
-- STEP 6.5.33
-- VERIFY ORDER_LINE DATA TYPE
-- ============================================================

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_TYPE
FROM information_schema.columns
WHERE table_schema = 'supermart_analytics'
  AND table_name = 'returns_valid'
  AND column_name = 'Order_Line';
  
-- ============================================================
-- STEP 6.5.34
-- CHECK RETURN_ID KEY READINESS
-- Expected:
-- total_rows = 799
-- unique_return_ids = 799
-- missing_return_ids = 0
-- duplicate_return_ids = 0
-- ============================================================

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT Return_ID) AS unique_return_ids,

    SUM(
        Return_ID IS NULL
        OR TRIM(Return_ID) = ''
    ) AS missing_return_ids,

    COUNT(*) - COUNT(DISTINCT Return_ID)
        AS duplicate_return_ids

FROM returns_valid;

-- ============================================================
-- STEP 6.5.35
-- ADD PRIMARY KEY TO CLEANED RETURNS TABLE
-- ============================================================

ALTER TABLE returns_valid
MODIFY COLUMN Return_ID VARCHAR(20) NOT NULL,
ADD CONSTRAINT pk_returns_valid
PRIMARY KEY (Return_ID);

-- ============================================================
-- STEP 6.5.36
-- VERIFY PRIMARY KEY ON RETURNS_VALID
-- Expected: Return_ID with Key_name = PRIMARY
-- ============================================================

SHOW INDEX
FROM returns_valid
WHERE Key_name = 'PRIMARY';

-- ============================================================
-- STEP 6.5.37
-- CHECK SALES_DEDUP INDEX / KEY STRUCTURE
-- Before creating Returns -> Sales foreign key
-- ============================================================

SHOW INDEX FROM sales_dedup;

-- ============================================================
-- STEP 6.5.38
-- VERIFY (ORDER_ID, ORDER_LINE) UNIQUENESS IN SALES_DEDUP
-- Required before creating composite key
-- Expected result: 0 rows
-- ============================================================

SELECT
    Order_ID,
    Order_Line,
    COUNT(*) AS duplicate_count
FROM sales_dedup
GROUP BY
    Order_ID,
    Order_Line
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- ============================================================
-- STEP 6.5.39
-- CHECK SALES vs RETURNS KEY DATA TYPES
-- Before creating composite key / foreign key
-- ============================================================

SELECT
    table_name,
    column_name,
    data_type,
    column_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'supermart_analytics'
  AND table_name IN ('sales_dedup', 'returns_valid')
  AND column_name IN ('Order_ID', 'Order_Line')
ORDER BY table_name, column_name;

-- ============================================================
-- STEP 6.5.40
-- CONVERT SALES_DEDUP ORDER_LINE FROM VARCHAR TO INT
-- Makes Sales and Returns key data types compatible
-- ============================================================

ALTER TABLE sales_dedup
MODIFY COLUMN Order_Line INT;

-- ============================================================
-- STEP 6.5.41
-- VERIFY SALES_DEDUP ORDER_LINE DATA TYPE
-- Expected: INT
-- ============================================================

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_TYPE
FROM information_schema.columns
WHERE table_schema = 'supermart_analytics'
  AND table_name = 'sales_dedup'
  AND column_name = 'Order_Line';
  
-- ============================================================
-- STEP 6.5.42
-- ADD COMPOSITE UNIQUE KEY TO SALES_DEDUP
-- One Order_ID can contain multiple Order_Line values
-- Together they uniquely identify each sales transaction
-- ============================================================

ALTER TABLE sales_dedup
ADD CONSTRAINT uq_sales_order_line
UNIQUE (Order_ID, Order_Line);

-- ============================================================
-- STEP 6.5.43
-- VERIFY COMPOSITE UNIQUE KEY
-- Expected: Order_ID + Order_Line under uq_sales_order_line
-- ============================================================

SHOW INDEX
FROM sales_dedup
WHERE Key_name = 'uq_sales_order_line';

-- ============================================================
-- STEP 6.5.44
-- FINAL DATA TYPE / COLLATION CHECK BEFORE FOREIGN KEY
-- RETURNS_VALID -> SALES_DEDUP
-- ============================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    COLUMN_TYPE,
    CHARACTER_SET_NAME,
    COLLATION_NAME
FROM information_schema.columns
WHERE table_schema = 'supermart_analytics'
  AND table_name IN ('sales_dedup', 'returns_valid')
  AND column_name IN ('Order_ID', 'Order_Line')
ORDER BY COLUMN_NAME, TABLE_NAME;

-- ============================================================
-- STEP 6.5.45
-- CREATE RETURNS -> SALES COMPOSITE FOREIGN KEY
--
-- Child  : returns_valid
-- Parent : sales_dedup
--
-- Relationship:
-- (Order_ID, Order_Line)
--        ->
-- (Order_ID, Order_Line)
-- ============================================================

ALTER TABLE returns_valid
ADD CONSTRAINT fk_returns_sales
FOREIGN KEY (Order_ID, Order_Line)
REFERENCES sales_dedup (Order_ID, Order_Line);

-- ============================================================
-- STEP 6.5.46
-- VERIFY RETURNS -> SALES FOREIGN KEY
-- ============================================================

SELECT
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME,
    ORDINAL_POSITION
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'supermart_analytics'
  AND TABLE_NAME = 'returns_valid'
  AND CONSTRAINT_NAME = 'fk_returns_sales'
ORDER BY ORDINAL_POSITION;