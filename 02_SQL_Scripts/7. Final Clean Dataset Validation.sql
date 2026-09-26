-- ============================================================
-- STEP 6.6.1
-- FINAL CLEAN TABLE ROW COUNTS
-- Purpose:
-- Confirm the final analytical tables and their row volumes
-- ============================================================

select 'customers_clean' as table_name,
	count(*) as row_count
from customers_clean

union all

select 'products_dedup', count(*) 
from products_dedup

union all

select 'sales_dedup', count(*) 
from sales_dedup

union all

select 'returns_valid', count(*) 
from returns_valid;

-- ============================================================
-- STEP 6.6.2
-- FINAL SALES -> CUSTOMER REFERENTIAL INTEGRITY CHECK
--
-- Expected:
-- total_sales_rows       = 10000
-- unmatched_customer_rows = 0
-- ============================================================

SELECT
    COUNT(*) AS total_sales_rows,

    SUM(
        CASE
            WHEN c.Customer_ID IS NULL THEN 1
            ELSE 0
        END
    ) AS unmatched_customer_rows

FROM sales_dedup s

LEFT JOIN customers_clean c
    ON TRIM(s.Customer_ID) = TRIM(c.Customer_ID);


-- ============================================================
-- STEP 6.6.3
-- INVESTIGATE UNMATCHED CUSTOMER IN FINAL SALES DATA
-- ============================================================

SELECT
    s.Order_ID,
    s.Order_Line,
    s.Customer_ID,
    s.Product_ID,
    s.Order_Date,
    s.Sales,
    s.Profit
FROM sales_dedup s

LEFT JOIN customers_clean c
    ON TRIM(s.Customer_ID) = TRIM(c.Customer_ID)

WHERE c.Customer_ID IS NULL;

-- ============================================================
-- STEP 6.6.4
-- VERIFY CUST9999 IN CUSTOMERS_CLEAN
-- ============================================================

SELECT
    Customer_ID,
    Customer_Name,
    Segment,
    Age,
    Country,
    City,
    State,
    Postal_Code,
    Region
FROM customers_clean
WHERE TRIM(Customer_ID) = 'CUST9999';

-- ============================================================
-- STEP 6.6.5
-- ADD UNKNOWN CUSTOMER PLACEHOLDER
-- Purpose:
-- Preserve valid sales transaction while restoring
-- referential integrity.
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

-- Then Verify

-- ============================================================
-- STEP 6.6.6
-- VERIFY UNKNOWN CUSTOMER PLACEHOLDER
-- Expected: 1 row
-- ============================================================

SELECT
    Customer_ID,
    Customer_Name,
    Segment,
    Age,
    Country,
    City,
    State,
    Postal_Code,
    Region
FROM customers_clean
WHERE Customer_ID = 'CUST9999';

-- ============================================================
-- STEP 6.6.7
-- RECHECK SALES -> CUSTOMER REFERENTIAL INTEGRITY
--
-- Expected:
-- total_sales_rows        = 10000
-- unmatched_customer_rows = 0
-- ============================================================

SELECT
    COUNT(*) AS total_sales_rows,

    SUM(
        CASE
            WHEN c.Customer_ID IS NULL THEN 1
            ELSE 0
        END
    ) AS unmatched_customer_rows

FROM sales_dedup s

LEFT JOIN customers_clean c
    ON TRIM(s.Customer_ID) = TRIM(c.Customer_ID);
    
-- ============================================================
-- STEP 6.6.8
-- VALIDATE SALES -> PRODUCT REFERENTIAL INTEGRITY
--
-- Expected:
-- total_sales_rows       = 10000
-- unmatched_product_rows = 0
-- ============================================================

select
	count(*) as total_sales_row,
    
    sum(
		case 
			when p.Product_ID is null then 1
            else 0
		end
	) as unmatched_product_rows

from sales_dedup s 

left join products_dedup p 
	on trim(s.Product_ID) = trim(p.Product_ID);
    
-- Step 6.6.9 — Validate Sales → Customer + Product Together

-- ============================================================
-- STEP 6.6.9
-- FINAL SALES REFERENTIAL INTEGRITY CHECK
--
-- Expected:
-- total_sales_rows         = 10000
-- unmatched_customer_rows  = 0
-- unmatched_product_rows   = 0
-- ============================================================

SELECT
    COUNT(*) AS total_sales_rows,

    SUM(
        CASE
            WHEN c.Customer_ID IS NULL THEN 1
            ELSE 0
        END
    ) AS unmatched_customer_rows,

    SUM(
        CASE
            WHEN p.Product_ID IS NULL THEN 1
            ELSE 0
        END
    ) AS unmatched_product_rows

FROM sales_dedup s

LEFT JOIN customers_clean c
    ON TRIM(s.Customer_ID) = TRIM(c.Customer_ID)

LEFT JOIN products_dedup p
    ON TRIM(s.Product_ID) = TRIM(p.Product_ID);
    
-- ============================================================
-- STEP 6.6.10
-- FINAL RETURNS -> SALES REFERENTIAL INTEGRITY VALIDATION
--
-- Expected:
-- total_returns        = 799
-- unmatched_sales_rows = 0
-- ============================================================

select
	count(*) as total_returns,
    
    sum( 
		case
			when s.Order_ID is null then 1
            else 0
		end
	) as unmatched_sales_rows

from returns_valid r

left join sales_dedup s 
	on r.Order_ID = s.Order_ID
    and r.Order_Line = s.Order_Line;

-- ============================================================
-- STEP 6.6.11
-- VALIDATE RETURN DATE >= ORDER DATE
--
-- Expected:
-- total_returns       = 799
-- return_before_order = 0
-- ============================================================

SELECT
    COUNT(*) AS total_returns,

    SUM(
        CASE
            WHEN r.Return_Date IS NOT NULL
             AND s.Order_Date IS NOT NULL
             AND r.Return_Date < s.Order_Date
            THEN 1
            ELSE 0
        END
    ) AS return_before_order

FROM returns_valid r

INNER JOIN sales_dedup s
    ON r.Order_ID = s.Order_ID
   AND r.Order_Line = s.Order_Line;
    
-- ============================================================
-- STEP 6.6.12
-- FINAL REFUND AMOUNT BUSINESS-RULE VALIDATION
--
-- Expected:
-- total_returns          = 799
-- missing_refund_amounts = 1
-- invalid_refund_amounts = 0
-- ============================================================

SELECT
    COUNT(*) AS total_returns,

    SUM(
        CASE
            WHEN r.Refund_Amount IS NULL THEN 1
            ELSE 0
        END
    ) AS missing_refund_amounts,

    SUM(
        CASE
            WHEN r.Refund_Amount IS NOT NULL
             AND (
                    r.Refund_Amount <= 0
                    OR r.Refund_Amount > s.Sales
                 )
            THEN 1
            ELSE 0
        END
    ) AS invalid_refund_amounts

FROM returns_valid r

INNER JOIN sales_dedup s
    ON r.Order_ID = s.Order_ID
   AND r.Order_Line = s.Order_Line;
   

-- ============================================================
-- STEP 6.6.13
-- FINAL RETURN REASON & STATUS VALIDATION
--
-- Expected:
-- total_returns          = 799
-- missing_return_reason  = 0
-- invalid_return_reason  = 0
-- missing_return_status  = 0
-- invalid_return_status  = 0
-- ============================================================

SELECT
    COUNT(*) AS total_returns,

    SUM(
        CASE
            WHEN Return_Reason IS NULL
              OR TRIM(Return_Reason) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_return_reason,

    SUM(
        CASE
            WHEN Return_Reason IS NOT NULL
             AND TRIM(Return_Reason) <> ''
             AND Return_Reason NOT IN (
                 'Changed Mind',
                 'Damaged',
                 'Defective',
                 'Late Delivery',
                 'Quality Issue',
                 'Wrong Item'
             )
            THEN 1 ELSE 0
        END
    ) AS invalid_return_reason,

    SUM(
        CASE
            WHEN Return_Status IS NULL
              OR TRIM(Return_Status) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_return_status,

    SUM(
        CASE
            WHEN Return_Status IS NOT NULL
             AND TRIM(Return_Status) <> ''
             AND Return_Status NOT IN (
                 'Approved',
                 'Completed',
                 'Pending'
             )
            THEN 1 ELSE 0
        END
    ) AS invalid_return_status

FROM returns_valid;

-- ============================================================
-- STEP 6.6.14
-- FINAL RETURN_ID UNIQUENESS & COMPLETENESS VALIDATION
--
-- Expected:
-- total_returns        = 799
-- unique_return_ids    = 799
-- missing_return_ids   = 0
-- duplicate_return_ids = 0
-- ============================================================

SELECT
    COUNT(*) AS total_returns,

    COUNT(DISTINCT Return_ID) AS unique_return_ids,

    SUM(
        CASE
            WHEN Return_ID IS NULL
              OR TRIM(Return_ID) = ''
            THEN 1
            ELSE 0
        END
    ) AS missing_return_ids,

    COUNT(*) - COUNT(DISTINCT Return_ID)
        AS duplicate_return_ids

FROM returns_valid;


-- ============================================================
-- STEP 6.6.15
-- FINAL CLEAN DATASET ROW-COUNT RECONCILIATION
--
-- Expected:
-- customers_clean = 1000
-- products_dedup   = 301
-- sales_dedup      = 10000
-- returns_valid    = 799
-- ============================================================

SELECT
    'customers_clean' AS table_name,
    COUNT(*) AS final_row_count
FROM customers_clean

UNION ALL

SELECT
    'products_dedup',
    COUNT(*)
FROM products_dedup

UNION ALL

SELECT
    'sales_dedup',
    COUNT(*)
FROM sales_dedup

UNION ALL

SELECT
    'returns_valid',
    COUNT(*)
FROM returns_valid;

-- ============================================================
-- STEP 6.6.16
-- FINAL CRITICAL DATA-TYPE VALIDATION
--
-- Purpose:
-- Verify cleaned analytical columns use appropriate data types
-- ============================================================

select
	table_name,
    column_name,
    data_type,
    column_type

from information_schema.columns

where table_schema = 'supermart_analytics'

  and (
		(table_name = 'sales_dedup'
         and column_name in (
			 'Order_Line',
             'Order_Date',
             'Ship_Date',
             'Quantity',
             'Unit_Price',
             'Discount',
             'Sales',
             'Profit'
		))
        
        or
        
        (table_name = 'returns_valid'
         and column_name in (
			 'Order_Line',
             'Return_Date',
             'Refund_Amount'
		))
	)

order by
	table_name,
    ordinal_position;
    
-- ============================================================
-- STEP 6.6.17
-- FINAL KEY / CONSTRAINT STRUCTURE AUDIT
--
-- Purpose:
-- Confirm PK, UNIQUE and FK constraints in final clean tables
-- ============================================================

SELECT
    tc.TABLE_NAME,
    tc.CONSTRAINT_NAME,
    tc.CONSTRAINT_TYPE,
    kcu.COLUMN_NAME,
    kcu.ORDINAL_POSITION,
    kcu.REFERENCED_TABLE_NAME,
    kcu.REFERENCED_COLUMN_NAME

FROM information_schema.TABLE_CONSTRAINTS tc

JOIN information_schema.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_SCHEMA = kcu.CONSTRAINT_SCHEMA
   AND tc.TABLE_NAME = kcu.TABLE_NAME
   AND tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME

WHERE tc.CONSTRAINT_SCHEMA = 'supermart_analytics'

  AND tc.TABLE_NAME IN (
      'customers_clean',
      'products_dedup',
      'sales_dedup',
      'returns_valid'
  )

ORDER BY
    tc.TABLE_NAME,
    tc.CONSTRAINT_TYPE,
    tc.CONSTRAINT_NAME,
    kcu.ORDINAL_POSITION;
    
-- ============================================================
-- STEP 6.6.18
-- FINAL CRITICAL NULL AUDIT
--
-- Expected:
-- Sales critical NULLs   = 0
-- Returns critical NULLs = 0
-- Refund NULLs           = 1  (accepted Pending return)
-- ============================================================

SELECT
    'sales_dedup' AS table_name,

    SUM(Order_ID IS NULL) AS null_order_id,
    SUM(Order_Line IS NULL) AS null_order_line,
    SUM(Customer_ID IS NULL) AS null_customer_id,
    SUM(Product_ID IS NULL) AS null_product_id,
    SUM(Order_Date IS NULL) AS null_order_date,
    SUM(Quantity IS NULL) AS null_quantity,
    SUM(Sales IS NULL) AS null_sales

FROM sales_dedup

UNION ALL

SELECT
    'returns_valid',

    SUM(Order_ID IS NULL),
    SUM(Order_Line IS NULL),

    -- Not applicable to returns table
    NULL,
    NULL,

    SUM(Return_Date IS NULL),

    -- Not applicable
    NULL,

    SUM(Refund_Amount IS NULL)

FROM returns_valid;

-- ============================================================
-- STEP 6.6.19
-- INVESTIGATE NULL ORDER_DATE IN SALES_DEDUP
--
-- Purpose:
-- Find the sales record whose cleaned Order_Date is NULL.
-- Do NOT modify anything yet.
-- ============================================================

SELECT
    Order_ID,
    Order_Line,
    Customer_ID,
    Product_ID,
    Order_Date,
    Ship_Date,
    Quantity,
    Unit_Price,
    Discount,
    Sales,
    Profit
FROM sales_dedup
WHERE Order_Date IS NULL;

-- ============================================================
-- STEP 6.6.20
-- TRACE ORIGINAL ORDER DATE FROM RAW SALES DATA
--
-- Problem record:
-- Order_ID   = ORD000050
-- Order_Line = 100
--
-- DO NOT UPDATE ANYTHING YET
-- ============================================================

select *
from sales_raw
where trim(Order_ID) = 'ORD000050'
  and cast(trim(Order_Line) as unsigned) = 100;
  
-- ============================================================
-- STEP 6.6.21
-- CONFIRM INVALID SOURCE ORDER DATE
--
-- Raw value: 31-02-2024
-- February 2024 has only 29 days
-- Therefore the source date is unrecoverable.
--
-- Cleaning decision:
-- Keep sales_dedup.Order_Date = NULL
-- Do NOT infer Order_Date from Ship_Date
-- ============================================================

SELECT
    Order_ID,
    Order_Line,
    Order_Date,
    Ship_Date,
    Customer_ID,
    Product_ID,
    Sales,
    Profit
FROM sales_dedup
WHERE Order_ID = 'ORD000050'
  AND Order_Line = 100;

-- ============================================================
-- STEP 6.6.22
-- CLASSIFY NULL ORDER DATE EXCEPTIONS
--
-- Known accepted exception:
-- ORD000050 / Order_Line 100
-- Raw source date = 31-02-2024 (invalid calendar date)
-- Cleaned Order_Date = NULL
-- ============================================================

SELECT
    COUNT(*) AS total_null_order_dates,

    SUM(
        CASE
            WHEN Order_ID = 'ORD000050'
             AND Order_Line = 100
            THEN 1
            ELSE 0
        END
    ) AS known_date_exceptions,

    SUM(
        CASE
            WHEN Order_Date IS NULL
             AND NOT (
                 Order_ID = 'ORD000050'
                 AND Order_Line = 100
             )
            THEN 1
            ELSE 0
        END
    ) AS unexpected_null_order_dates

FROM sales_dedup
WHERE Order_Date IS NULL;

-- ============================================================
-- STEP 6.6.23
-- VALIDATE ORDER DATE -> SHIP DATE CHRONOLOGY
--
-- Business rule:
-- Ship_Date should not be earlier than Order_Date
--
-- The known NULL Order_Date is excluded because
-- chronology cannot be evaluated for that record.
--
-- Expected:
-- ship_before_order = 0
-- ============================================================

SELECT
    COUNT(*) AS comparable_sales_rows,

    SUM(
        CASE
            WHEN Ship_Date < Order_Date
            THEN 1
            ELSE 0
        END
    ) AS ship_before_order

FROM sales_dedup

WHERE Order_Date IS NOT NULL
  AND Ship_Date IS NOT NULL;
  
-- ============================================================
-- STEP 6.6.24
-- FINAL SALES NUMERIC BUSINESS-RULE VALIDATION
--
-- Checks:
-- 1. Quantity must be > 0
-- 2. Unit_Price must be > 0
-- 3. Discount must be between 0 and 1
-- 4. Sales must be > 0
--
-- Expected:
-- All invalid counts = 0
-- ============================================================

SELECT
    COUNT(*) AS total_sales_rows,

    SUM(
        CASE
            WHEN Quantity IS NULL OR Quantity <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_quantity,

    SUM(
        CASE
            WHEN Unit_Price IS NULL OR Unit_Price <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_unit_price,

    SUM(
        CASE
            WHEN Discount IS NULL
              OR Discount < 0
              OR Discount > 1
            THEN 1 ELSE 0
        END
    ) AS invalid_discount,

    SUM(
        CASE
            WHEN Sales IS NULL OR Sales <= 0
            THEN 1 ELSE 0
        END
    ) AS invalid_sales

FROM sales_dedup;

-- ============================================================
-- STEP 6.6.25
-- FINAL PROFIT VALIDATION
--
-- Negative Profit is NOT automatically an error.
-- It represents a loss-making transaction.
--
-- Checks:
-- 1. Missing Profit
-- 2. Negative Profit transactions
-- 3. Zero Profit transactions
-- 4. Positive Profit transactions
-- 5. Profit range
--
-- Expected:
-- missing_profit = 0
-- ============================================================

SELECT
    COUNT(*) AS total_sales_rows,

    SUM(
        CASE
            WHEN Profit IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_profit,

    SUM(
        CASE
            WHEN Profit < 0
            THEN 1 ELSE 0
        END
    ) AS negative_profit_rows,

    SUM(
        CASE
            WHEN Profit = 0
            THEN 1 ELSE 0
        END
    ) AS zero_profit_rows,

    SUM(
        CASE
            WHEN Profit > 0
            THEN 1 ELSE 0
        END
    ) AS positive_profit_rows,

    MIN(Profit) AS minimum_profit,
    MAX(Profit) AS maximum_profit,
    ROUND(AVG(Profit), 2) AS average_profit

FROM sales_dedup;

-- ============================================================
-- STEP 6.6.26
-- FINAL DUPLICATE / KEY VALIDATION
--
-- Expected:
-- customers_clean duplicate IDs = 0
-- products_dedup duplicate IDs   = 0
-- sales_dedup duplicate keys     = 0
-- returns_valid duplicate IDs    = 0
-- ============================================================

SELECT
    'customers_clean' AS table_name,
    COUNT(*) AS duplicate_key_groups
FROM (
    SELECT Customer_ID
    FROM customers_clean
    GROUP BY Customer_ID
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'products_dedup',
    COUNT(*)
FROM (
    SELECT Product_ID
    FROM products_dedup
    GROUP BY Product_ID
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'sales_dedup',
    COUNT(*)
FROM (
    SELECT
        Order_ID,
        Order_Line
    FROM sales_dedup
    GROUP BY
        Order_ID,
        Order_Line
    HAVING COUNT(*) > 1
) x

UNION ALL

SELECT
    'returns_valid',
    COUNT(*)
FROM (
    SELECT Return_ID
    FROM returns_valid
    GROUP BY Return_ID
    HAVING COUNT(*) > 1
) x;

-- ============================================================
-- STEP 6.6.27
-- FINAL ROW-COUNT RECONCILIATION
--
-- Expected final counts:
-- customers_clean = 1001
--   (1000 original customers + 1 Unknown Customer)
--
-- products_dedup  = 301
-- sales_dedup     = 10000
-- returns_valid   = 799
--   (800 original returns - 1 orphan return)
-- ============================================================

select
	'customers_clean' as table_name,
    count(*) as final_row_count
from customers_clean

union all

select
	'products_dedup',
    count(*)
from products_dedup

union all

select 
	'sales_dedup',
	count(*)
from sales_dedup

union all

select
	'returns_valid',
    count(*) 
from returns_valid
	