-- ============================================================
-- STEP 9.1
-- CREATE REUSABLE SALES DETAIL VIEW
-- ============================================================

USE supermart_analytics;

show tables;



DESCRIBE sales_clean;

DESCRIBE customers_clean;

DESCRIBE products_clean;


-- ============================================================
-- STEP 9.1
-- REUSABLE SALES DETAIL VIEW
--
-- Grain:
-- One row = one sales transaction line
--
-- Sources:
-- sales_clean
-- customers_clean
-- unique cleaned product dimension
-- ============================================================

USE supermart_analytics;

DROP VIEW IF EXISTS vw_sales_detail;


CREATE VIEW vw_sales_detail AS

WITH customer_dimension AS
(
    SELECT
        Customer_ID,
        MAX(Customer_Name) AS Customer_Name,
        MAX(Segment) AS Segment,
        MAX(Age) AS Age,
        MAX(Country) AS Country,
        MAX(City) AS City,
        MAX(State) AS State,
        MAX(Postal_Code) AS Postal_Code,
        MAX(Region) AS Region

    FROM customers_clean

    WHERE Customer_ID IS NOT NULL

    GROUP BY
        Customer_ID
),


product_dimension AS
(
    SELECT
        Product_ID,
        MAX(Product_Name) AS Product_Name,
        MAX(Category) AS Category,
        MAX(Sub_Category) AS Sub_Category,
        MAX(Brand) AS Brand,
        MAX(Unit_Cost) AS Unit_Cost,
        MAX(Unit_Price) AS Product_Unit_Price

    FROM products_clean

    WHERE Product_ID IS NOT NULL

    GROUP BY
        Product_ID
)


SELECT

    -- ========================================================
    -- TRANSACTION KEY
    -- ========================================================

    s.Order_ID,
    s.Order_Line,


    -- ========================================================
    -- DATE INFORMATION
    -- ========================================================

    STR_TO_DATE(s.Order_Date, '%Y-%m-%d')
        AS Order_Date,

    STR_TO_DATE(s.Ship_Date, '%Y-%m-%d')
        AS Ship_Date,

    s.Ship_Mode,


    -- ========================================================
    -- CUSTOMER INFORMATION
    -- ========================================================

    s.Customer_ID,

    COALESCE(
        c.Customer_Name,
        'Unknown'
    ) AS Customer_Name,

    COALESCE(
        c.Segment,
        'Unknown'
    ) AS Segment,

    c.Age,

    COALESCE(
        c.Country,
        'Unknown'
    ) AS Country,

    COALESCE(
        c.City,
        'Unknown'
    ) AS City,

    COALESCE(
        c.State,
        'Unknown'
    ) AS State,

    c.Postal_Code,

    COALESCE(
        c.Region,
        'Unknown'
    ) AS Region,


    -- ========================================================
    -- PRODUCT INFORMATION
    -- ========================================================

    s.Product_ID,

    COALESCE(
        p.Product_Name,
        'Unknown'
    ) AS Product_Name,

    COALESCE(
        p.Category,
        'Unknown'
    ) AS Category,

    COALESCE(
        p.Sub_Category,
        'Unknown'
    ) AS Sub_Category,

    COALESCE(
        p.Brand,
        'Unknown'
    ) AS Brand,

    p.Unit_Cost,


    -- ========================================================
    -- SALES MEASURES
    -- ========================================================

    CAST(
        s.Quantity AS UNSIGNED
    ) AS Quantity,

    CAST(
        s.Unit_Price AS DECIMAL(14,2)
    ) AS Unit_Price,

    CAST(
        s.Discount AS DECIMAL(10,4)
    ) AS Discount,

    CAST(
        s.Sales AS DECIMAL(14,2)
    ) AS Sales,

    CAST(
        s.Profit AS DECIMAL(14,2)
    ) AS Profit,


    -- ========================================================
    -- DERIVED KPIs
    -- ========================================================

    ROUND(
        CAST(s.Sales AS DECIMAL(14,2))
        /
        NULLIF(
            CAST(s.Quantity AS UNSIGNED),
            0
        ),
        2
    ) AS Sales_Per_Unit,


    ROUND(
        CAST(s.Profit AS DECIMAL(14,2))
        * 100.0
        /
        NULLIF(
            CAST(s.Sales AS DECIMAL(14,2)),
            0
        ),
        2
    ) AS Profit_Margin_Pct,


    -- ========================================================
    -- DATE ATTRIBUTES
    -- ========================================================

    YEAR(
        STR_TO_DATE(s.Order_Date, '%Y-%m-%d')
    ) AS Sales_Year,


    QUARTER(
        STR_TO_DATE(s.Order_Date, '%Y-%m-%d')
    ) AS Sales_Quarter,


    MONTH(
        STR_TO_DATE(s.Order_Date, '%Y-%m-%d')
    ) AS Sales_Month_Number,


    MONTHNAME(
        STR_TO_DATE(s.Order_Date, '%Y-%m-%d')
    ) AS Sales_Month_Name


FROM sales_clean s


LEFT JOIN customer_dimension c
    ON TRIM(s.Customer_ID) = TRIM(c.Customer_ID)


LEFT JOIN product_dimension p
    ON TRIM(s.Product_ID) = TRIM(p.Product_ID);
    

-- Run the Validation 

SELECT

    (SELECT COUNT(*)
     FROM sales_clean)
        AS source_sales_rows,

    (SELECT COUNT(*)
     FROM vw_sales_detail)
        AS view_sales_rows,

    (SELECT
        ROUND(
            SUM(CAST(Sales AS DECIMAL(14,2))),
            2
        )
     FROM sales_clean)
        AS source_total_sales,

    (SELECT
        ROUND(SUM(Sales), 2)
     FROM vw_sales_detail)
        AS view_total_sales,

    (SELECT
        ROUND(
            SUM(CAST(Profit AS DECIMAL(14,2))),
            2
        )
     FROM sales_clean)
        AS source_total_profit,

    (SELECT
        ROUND(SUM(Profit), 2)
     FROM vw_sales_detail)
        AS view_total_profit;

-- One more validation
-- Because we intentionally convert orphan dimension values to Unknown, run:

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN Customer_Name = 'Unknown'
            THEN 1
            ELSE 0
        END
    ) AS unknown_customer_rows,

    SUM(
        CASE
            WHEN Product_Name = 'Unknown'
            THEN 1
            ELSE 0
        END
    ) AS unknown_product_rows

FROM vw_sales_detail;


-- ============================================================
-- STEP 9.2
-- REUSABLE CUSTOMER PERFORMANCE VIEW
--
-- Grain:
-- One row = One Customer
--
-- Source:
-- Validated vw_sales_detail
-- ============================================================

USE supermart_analytics;

DROP VIEW IF EXISTS vw_customer_performance;


CREATE VIEW vw_customer_performance AS

SELECT

    -- ========================================================
    -- CUSTOMER INFORMATION
    -- ========================================================

    Customer_ID,

    MAX(Customer_Name) AS Customer_Name,

    MAX(Segment) AS Segment,

    MAX(Age) AS Age,

    MAX(Country) AS Country,

    MAX(City) AS City,

    MAX(State) AS State,

    MAX(Postal_Code) AS Postal_Code,

    MAX(Region) AS Region,


    -- ========================================================
    -- CUSTOMER ACTIVITY
    -- ========================================================

    MIN(Order_Date) AS First_Order_Date,

    MAX(Order_Date) AS Last_Order_Date,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    COUNT(*) AS Total_Sales_Lines,

    SUM(Quantity) AS Units_Purchased,


    -- ========================================================
    -- CUSTOMER FINANCIAL PERFORMANCE
    -- ========================================================

    ROUND(
        SUM(Sales),
        2
    ) AS Total_Sales,

    ROUND(
        SUM(Profit),
        2
    ) AS Total_Profit,


    -- ========================================================
    -- AVERAGE ORDER VALUE
    --
    -- Total customer sales / distinct orders
    -- ========================================================

    ROUND(
        SUM(Sales)
        /
        NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Average_Order_Value,


    -- ========================================================
    -- CUSTOMER PROFIT MARGIN
    -- ========================================================

    ROUND(
        SUM(Profit) * 100.0
        /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Pct,


    -- ========================================================
    -- AVERAGE UNITS PER ORDER
    -- ========================================================

    ROUND(
        SUM(Quantity) * 1.0
        /
        NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS Avg_Units_Per_Order


FROM vw_sales_detail

GROUP BY
    Customer_ID;


-- 9.2B — Inspect the customer view

SELECT *
FROM vw_customer_performance
ORDER BY Total_Sales DESC
LIMIT 20;
    
-- 9.2C — Customer-count validation

SELECT

    (SELECT COUNT(DISTINCT Customer_ID)
     FROM vw_sales_detail)
        AS source_unique_customers,

    (SELECT COUNT(*)
     FROM vw_customer_performance)
        AS customer_view_rows;
        
-- 9.2D — Critical financial reconciliation

SELECT

    -- SOURCE SALES
    (
        SELECT ROUND(SUM(Sales), 2)
        FROM vw_sales_detail
    ) AS source_total_sales,


    -- CUSTOMER VIEW SALES
    (
        SELECT ROUND(SUM(Total_Sales), 2)
        FROM vw_customer_performance
    ) AS customer_total_sales,


    -- SOURCE PROFIT
    (
        SELECT ROUND(SUM(Profit), 2)
        FROM vw_sales_detail
    ) AS source_total_profit,


    -- CUSTOMER VIEW PROFIT
    (
        SELECT ROUND(SUM(Total_Profit), 2)
        FROM vw_customer_performance
    ) AS customer_total_profit;
    
-- 9.2E — Order and unit reconciliation

SELECT

    (
        SELECT COUNT(DISTINCT Order_ID)
        FROM vw_sales_detail
    ) AS source_orders,

    (
        SELECT SUM(Total_Orders)
        FROM vw_customer_performance
    ) AS customer_view_orders,

    (
        SELECT SUM(Quantity)
        FROM vw_sales_detail
    ) AS source_units,

    (
        SELECT SUM(Units_Purchased)
        FROM vw_customer_performance
    ) AS customer_view_units;
    

-- 9.2F — Data-quality validation

SELECT

    COUNT(*) AS Total_Customers,

    SUM(
        CASE
            WHEN Total_Orders <= 0 THEN 1
            ELSE 0
        END
    ) AS Customers_With_No_Orders,

    SUM(
        CASE
            WHEN Total_Sales <= 0 THEN 1
            ELSE 0
        END
    ) AS Customers_With_Nonpositive_Sales,

    SUM(
        CASE
            WHEN Customer_Name = 'Unknown' THEN 1
            ELSE 0
        END
    ) AS Unknown_Customers

FROM vw_customer_performance;


-- ============================================================
-- STEP 9.2G
-- CHECK WHETHER ONE ORDER BELONGS TO MULTIPLE CUSTOMERS
-- ============================================================

SELECT
    Order_ID,
    COUNT(DISTINCT Customer_ID) AS customer_count,
    COUNT(*) AS sales_lines
FROM vw_sales_detail
GROUP BY Order_ID
HAVING COUNT(DISTINCT Customer_ID) > 1
ORDER BY customer_count DESC, Order_ID;

-- ============================================================
-- STEP 9.2H
-- ORDER-CUSTOMER RELATIONSHIP SUMMARY
-- ============================================================

WITH order_customer_check AS
(
    SELECT
        Order_ID,
        COUNT(DISTINCT Customer_ID) AS customer_count
    FROM vw_sales_detail
    GROUP BY Order_ID
)

SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN customer_count = 1 THEN 1
            ELSE 0
        END
    ) AS single_customer_orders,

    SUM(
        CASE
            WHEN customer_count > 1 THEN 1
            ELSE 0
        END
    ) AS multi_customer_orders,

    MAX(customer_count) AS max_customers_per_order

FROM order_customer_check;

-- But from now on, we will never sum Total_Orders from the customer view to calculate overall orders.
-- For company-level total orders, use:

SELECT COUNT(DISTINCT Order_ID) AS Total_Orders
FROM vw_sales_detail;


-- ============================================================
-- STEP 9.3A
-- CREATE REUSABLE PRODUCT PERFORMANCE VIEW
-- ============================================================

USE supermart_analytics;

DROP VIEW IF EXISTS vw_product_performance;

CREATE VIEW vw_product_performance AS

SELECT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    Brand,

    -- Number of distinct orders containing the product
    COUNT(DISTINCT Order_ID) AS Total_Orders,

    -- Number of sales lines
    COUNT(*) AS Total_Sales_Lines,

    -- Units sold
    SUM(Quantity) AS Units_Sold,

    -- Revenue
    ROUND(SUM(Sales), 2) AS Total_Sales,

    -- Profit
    ROUND(SUM(Profit), 2) AS Total_Profit,

    -- Average selling price per unit
    ROUND(
        SUM(Sales) / NULLIF(SUM(Quantity), 0),
        2
    ) AS Avg_Selling_Price,

    -- Average revenue per sales line
    ROUND(
        AVG(Sales),
        2
    ) AS Avg_Line_Sales,

    -- Average units per sales line
    ROUND(
        AVG(Quantity),
        2
    ) AS Avg_Units_Per_Line,

    -- Overall product profit margin
    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS Profit_Margin_Pct

FROM vw_sales_detail

GROUP BY
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    Brand;
    

-- ============================================================
-- STEP 9.3B
-- INSPECT PRODUCT PERFORMANCE VIEW
-- ============================================================

SELECT *
FROM vw_product_performance
ORDER BY Total_Sales DESC
LIMIT 20;


-- ============================================================
-- STEP 9.3C
-- PRODUCT COUNT RECONCILIATION
-- ============================================================

SELECT

    (
        SELECT COUNT(DISTINCT Product_ID)
        FROM vw_sales_detail
    ) AS source_unique_products,

    (
        SELECT COUNT(*)
        FROM vw_product_performance
    ) AS product_view_rows;
    

-- ============================================================
-- STEP 9.3D
-- PRODUCT VIEW FINANCIAL RECONCILIATION
-- ============================================================

SELECT

    -- SOURCE SALES
    (
        SELECT ROUND(SUM(Sales), 2)
        FROM vw_sales_detail
    ) AS source_total_sales,

    -- PRODUCT VIEW SALES
    (
        SELECT ROUND(SUM(Total_Sales), 2)
        FROM vw_product_performance
    ) AS product_total_sales,

    -- SOURCE PROFIT
    (
        SELECT ROUND(SUM(Profit), 2)
        FROM vw_sales_detail
    ) AS source_total_profit,

    -- PRODUCT VIEW PROFIT
    (
        SELECT ROUND(SUM(Total_Profit), 2)
        FROM vw_product_performance
    ) AS product_total_profit,

    -- SOURCE UNITS
    (
        SELECT SUM(Quantity)
        FROM vw_sales_detail
    ) AS source_units,

    -- PRODUCT VIEW UNITS
    (
        SELECT SUM(Units_Sold)
        FROM vw_product_performance
    ) AS product_view_units;
    
-- ============================================================
-- STEP 9.3E
-- PRODUCT VIEW DATA QUALITY CHECK
-- ============================================================

SELECT
    COUNT(*) AS Total_Products,

    SUM(
        CASE
            WHEN Product_Name = 'Unknown'
                 OR Product_Name IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Unknown_Products,

    SUM(
        CASE
            WHEN Category = 'Unknown'
                 OR Category IS NULL
            THEN 1
            ELSE 0
        END
    ) AS Unknown_Categories,

    SUM(
        CASE
            WHEN Total_Sales <= 0
            THEN 1
            ELSE 0
        END
    ) AS Products_With_Nonpositive_Sales,

    SUM(
        CASE
            WHEN Units_Sold <= 0
            THEN 1
            ELSE 0
        END
    ) AS Products_With_Nonpositive_Units

FROM vw_product_performance;


-- ============================================================
-- STEP 9.3F
-- INSPECT UNKNOWN / UNMATCHED PRODUCT
-- ============================================================

SELECT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    Brand,
    Total_Orders,
    Total_Sales_Lines,
    Units_Sold,
    Total_Sales,
    Total_Profit,
    Profit_Margin_Pct

FROM vw_product_performance

WHERE Product_Name = 'Unknown'
   OR Product_Name IS NULL
   OR Category = 'Unknown'
   OR Category IS NULL;
   

-- ============================================================
-- STEP 9.4A
-- CREATE REUSABLE RETURNS ANALYSIS VIEW
-- ============================================================

USE supermart_analytics;

DROP VIEW IF EXISTS vw_returns_analysis;

CREATE VIEW vw_returns_analysis AS

SELECT

    -- ========================================================
    -- RETURN / ORDER IDENTIFIERS
    -- ========================================================

    r.Order_ID,
    r.Order_Line,

    r.Return_Date,
    r.Return_Status,
    r.Refund_Amount,


    -- ========================================================
    -- ORIGINAL SALES INFORMATION
    -- ========================================================

    s.Order_Date,
    s.Ship_Date,
    s.Ship_Mode,


    -- ========================================================
    -- CUSTOMER INFORMATION
    -- ========================================================

    s.Customer_ID,
    s.Customer_Name,
    s.Segment,
    s.Region,


    -- ========================================================
    -- PRODUCT INFORMATION
    -- ========================================================

    s.Product_ID,
    s.Product_Name,
    s.Category,
    s.Sub_Category,
    s.Brand,


    -- ========================================================
    -- ORIGINAL TRANSACTION VALUES
    -- ========================================================

    s.Quantity,

    s.Sales AS Original_Sales,

    s.Profit AS Original_Profit,


    -- ========================================================
    -- REFUND IMPACT
    -- ========================================================

    ROUND(
        r.Refund_Amount * 100.0 /
        NULLIF(s.Sales, 0),
        2
    ) AS Refund_Impact_Pct,


    -- ========================================================
    -- SALES AFTER REFUND
    -- ========================================================

    ROUND(
        s.Sales - r.Refund_Amount,
        2
    ) AS Adjusted_Sales,


    -- ========================================================
    -- PROFIT AFTER REFUND
    -- ========================================================

    ROUND(
        s.Profit - r.Refund_Amount,
        2
    ) AS Adjusted_Profit,


    -- ========================================================
    -- ORIGINAL PROFIT MARGIN
    -- ========================================================

    ROUND(
        s.Profit * 100.0 /
        NULLIF(s.Sales, 0),
        2
    ) AS Original_Profit_Margin_Pct,


    -- ========================================================
    -- ADJUSTED PROFIT MARGIN
    -- ========================================================

    ROUND(
        (s.Profit - r.Refund_Amount) * 100.0 /
        NULLIF(s.Sales - r.Refund_Amount, 0),
        2
    ) AS Adjusted_Profit_Margin_Pct,


    -- ========================================================
    -- SALES DATE ATTRIBUTES
    -- ========================================================

    YEAR(s.Order_Date) AS Sales_Year,

    QUARTER(s.Order_Date) AS Sales_Quarter,

    MONTH(s.Order_Date) AS Sales_Month_Number,

    MONTHNAME(s.Order_Date) AS Sales_Month_Name,


    -- ========================================================
    -- RETURN DATE ATTRIBUTES
    -- ========================================================

    YEAR(r.Return_Date) AS Return_Year,

    QUARTER(r.Return_Date) AS Return_Quarter,

    MONTH(r.Return_Date) AS Return_Month_Number,

    MONTHNAME(r.Return_Date) AS Return_Month_Name,


    -- ========================================================
    -- DAYS BETWEEN ORDER AND RETURN
    -- ========================================================

    DATEDIFF(
        r.Return_Date,
        s.Order_Date
    ) AS Days_To_Return


FROM returns_valid r

LEFT JOIN vw_sales_detail s

    ON r.Order_ID = s.Order_ID

    AND r.Order_Line = s.Order_Line;
    

-- ============================================================
-- STEP 9.4B
-- INSPECT RETURNS ANALYSIS VIEW
-- ============================================================

SELECT *
FROM vw_returns_analysis
ORDER BY Refund_Amount DESC
LIMIT 20;


-- ============================================================
-- STEP 9.4C
-- RETURNS ANALYSIS VIEW - RECONCILIATION & QA
-- ============================================================

USE supermart_analytics;

SELECT

    -- Source return rows
    (
        SELECT COUNT(*)
        FROM returns_valid
    ) AS source_return_rows,

    -- View return rows
    (
        SELECT COUNT(*)
        FROM vw_returns_analysis
    ) AS view_return_rows,

    -- Source refund amount
    (
        SELECT ROUND(SUM(Refund_Amount), 2)
        FROM returns_valid
    ) AS source_refund_amount,

    -- View refund amount
    (
        SELECT ROUND(SUM(Refund_Amount), 2)
        FROM vw_returns_analysis
    ) AS view_refund_amount,

    -- Missing sales matches
    (
        SELECT COUNT(*)
        FROM vw_returns_analysis
        WHERE Customer_ID IS NULL
    ) AS missing_sales_matches,

    -- Invalid negative return timing
    (
        SELECT COUNT(*)
        FROM vw_returns_analysis
        WHERE Days_To_Return < 0
    ) AS negative_days_to_return,

    -- Same-day returns
    (
        SELECT COUNT(*)
        FROM vw_returns_analysis
        WHERE Days_To_Return = 0
    ) AS same_day_returns,

    -- Valid positive return timing
    (
        SELECT COUNT(*)
        FROM vw_returns_analysis
        WHERE Days_To_Return > 0
    ) AS positive_days_to_return;
    

-- ============================================================
-- STEP 9.4D
-- INVESTIGATE INVALID RETURN DATES
-- ============================================================

SELECT
    Order_ID,
    Order_Line,
    Customer_ID,
    Customer_Name,
    Product_ID,
    Product_Name,
    Order_Date,
    Return_Date,
    Days_To_Return,
    Original_Sales,
    Refund_Amount,
    Return_Status
FROM vw_returns_analysis
WHERE Days_To_Return < 0
ORDER BY Days_To_Return ASC;

-- ============================================================
-- STEP 9.4E
-- FIND DUPLICATED RETURNS CREATED BY THE VIEW JOIN
-- ============================================================

SELECT
    Order_ID,
    Order_Line,
    COUNT(*) AS view_row_count,
    ROUND(SUM(Refund_Amount), 2) AS total_refund_in_view
FROM vw_returns_analysis
GROUP BY
    Order_ID,
    Order_Line
HAVING COUNT(*) > 1
ORDER BY view_row_count DESC;

---------------
SELECT
    Order_ID,
    Order_Line,
    Customer_ID,
    Product_ID,
    Order_Date,
    Quantity,
    Sales,
    Profit
FROM sales_clean
WHERE Order_ID = 'ORD004924'
  AND Order_Line = '9848';
  
-----------------


SELECT
    Order_ID,
    Order_Line,
    Customer_ID,
    Product_ID,
    Order_Date,
    Quantity,
    Sales,
    Profit
FROM sales_clean
WHERE Order_ID = 'ORD004924'
  AND Order_Line = '9848';


-- ============================================================
-- STEP 9.4F
-- VERIFY DUPLICATE IS REMOVED IN SALES_DEDUP
-- ============================================================

SELECT
    Order_ID,
    Order_Line,
    Customer_ID,
    Product_ID,
    Order_Date,
    Quantity,
    Sales,
    Profit
FROM sales_dedup
WHERE Order_ID = 'ORD004924'
  AND Order_Line = '9848';
  
--------------


-- ============================================================
-- STEP 9.4G
-- TEST DEDUPLICATED SALES SOURCE
-- ============================================================

WITH sales_for_returns AS
(
    SELECT *
    FROM
    (
        SELECT
            sc.*,

            ROW_NUMBER() OVER
            (
                PARTITION BY
                    sc.Order_ID,
                    sc.Order_Line
                ORDER BY
                    sc.Order_ID,
                    sc.Order_Line
            ) AS rn

        FROM sales_clean sc

    ) x

    WHERE rn = 1
)

SELECT
    COUNT(*) AS dedup_sales_rows,

    COUNT(
        DISTINCT CONCAT(
            Order_ID,
            '|',
            Order_Line
        )
    ) AS unique_order_lines

FROM sales_for_returns;

----------------

WITH sales_for_returns AS
(
    SELECT *
    FROM
    (
        SELECT
            sc.*,
            ROW_NUMBER() OVER
            (
                PARTITION BY sc.Order_ID, sc.Order_Line
                ORDER BY sc.Order_ID, sc.Order_Line
            ) AS rn
        FROM sales_clean sc
    ) x
    WHERE rn = 1
)

SELECT *
FROM sales_for_returns
WHERE Order_ID = 'ORD004924'
  AND Order_Line = '9848';
  
-- ============================================================
-- STEP 9.4H
-- REBUILD RETURNS ANALYSIS VIEW
-- DEDUPLICATED SALES GRAIN
-- ============================================================

USE supermart_analytics;

DROP VIEW IF EXISTS vw_returns_analysis;

CREATE VIEW vw_returns_analysis AS

WITH sales_for_returns AS
(
    SELECT *
    FROM
    (
        SELECT
            sc.*,

            ROW_NUMBER() OVER
            (
                PARTITION BY
                    sc.Order_ID,
                    sc.Order_Line
                ORDER BY
                    sc.Order_ID,
                    sc.Order_Line
            ) AS rn

        FROM sales_clean sc
    ) x

    WHERE rn = 1
)

SELECT

    -- ========================================================
    -- RETURN INFORMATION
    -- ========================================================

    r.Order_ID,
    r.Order_Line,
    r.Return_Date,
    r.Return_Status,
    r.Refund_Amount,


    -- ========================================================
    -- SALES INFORMATION
    -- ========================================================

    s.Order_Date,
    s.Ship_Date,
    s.Ship_Mode,

    s.Customer_ID,
    c.Customer_Name,
    c.Segment,
    c.Region,

    s.Product_ID,
    p.Product_Name,
    p.Category,
    p.Sub_Category,
    p.Brand,

    s.Quantity,

    s.Sales AS Original_Sales,

    s.Profit AS Original_Profit,


    -- ========================================================
    -- REFUND IMPACT
    -- ========================================================

    ROUND(
        r.Refund_Amount * 100.0 /
        NULLIF(s.Sales, 0),
        2
    ) AS Refund_Impact_Pct,


    -- ========================================================
    -- ADJUSTED SALES
    -- ========================================================

    ROUND(
        s.Sales - r.Refund_Amount,
        2
    ) AS Adjusted_Sales,


    -- ========================================================
    -- ADJUSTED PROFIT
    -- ========================================================

    ROUND(
        s.Profit - r.Refund_Amount,
        2
    ) AS Adjusted_Profit,


    -- ========================================================
    -- ORIGINAL PROFIT MARGIN
    -- ========================================================

    ROUND(
        s.Profit * 100.0 /
        NULLIF(s.Sales, 0),
        2
    ) AS Original_Profit_Margin_Pct,


    -- ========================================================
    -- ADJUSTED PROFIT MARGIN
    -- ========================================================

    ROUND(
        (s.Profit - r.Refund_Amount) * 100.0 /
        NULLIF(
            s.Sales - r.Refund_Amount,
            0
        ),
        2
    ) AS Adjusted_Profit_Margin_Pct,


    -- ========================================================
    -- SALES DATE ATTRIBUTES
    -- ========================================================

    YEAR(s.Order_Date) AS Sales_Year,

    QUARTER(s.Order_Date) AS Sales_Quarter,

    MONTH(s.Order_Date) AS Sales_Month_Number,

    MONTHNAME(s.Order_Date) AS Sales_Month_Name,


    -- ========================================================
    -- RETURN DATE ATTRIBUTES
    -- ========================================================

    YEAR(r.Return_Date) AS Return_Year,

    QUARTER(r.Return_Date) AS Return_Quarter,

    MONTH(r.Return_Date) AS Return_Month_Number,

    MONTHNAME(r.Return_Date) AS Return_Month_Name,


    -- ========================================================
    -- RETURN TIMING
    -- ========================================================

    DATEDIFF(
        r.Return_Date,
        s.Order_Date
    ) AS Days_To_Return,


    -- ========================================================
    -- DATA QUALITY FLAG
    -- ========================================================

    CASE

        WHEN s.Order_Date IS NULL
            THEN 'Missing Sales Match'

        WHEN r.Return_Date IS NULL
            THEN 'Missing Return Date'

        WHEN r.Return_Date < s.Order_Date
            THEN 'Invalid - Return Before Order'

        WHEN r.Return_Date = s.Order_Date
            THEN 'Same Day Return'

        ELSE 'Valid Return'

    END AS Return_Date_Quality,


    -- ========================================================
    -- RETURN AGE BAND
    -- ========================================================

    CASE

        WHEN s.Order_Date IS NULL
            THEN 'Unknown'

        WHEN r.Return_Date < s.Order_Date
            THEN 'Invalid Date'

        WHEN DATEDIFF(r.Return_Date, s.Order_Date) = 0
            THEN 'Same Day'

        WHEN DATEDIFF(r.Return_Date, s.Order_Date)
             BETWEEN 1 AND 30
            THEN '1-30 Days'

        WHEN DATEDIFF(r.Return_Date, s.Order_Date)
             BETWEEN 31 AND 90
            THEN '31-90 Days'

        WHEN DATEDIFF(r.Return_Date, s.Order_Date) > 90
            THEN '90+ Days'

        ELSE 'Unknown'

    END AS Return_Timing_Group

FROM returns_valid r

LEFT JOIN sales_for_returns s
    ON r.Order_ID = s.Order_ID
   AND r.Order_Line = s.Order_Line

LEFT JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

LEFT JOIN products_clean p
    ON s.Product_ID = p.Product_ID;
    

-- ============================================================
-- STEP 9.4I
-- FINAL RETURNS VIEW RECONCILIATION
-- ============================================================

SELECT

    (SELECT COUNT(*)
     FROM returns_valid)
        AS source_return_rows,

    (SELECT COUNT(*)
     FROM vw_returns_analysis)
        AS view_return_rows,

    (SELECT ROUND(SUM(Refund_Amount),2)
     FROM returns_valid)
        AS source_refund_amount,

    (SELECT ROUND(SUM(Refund_Amount),2)
     FROM vw_returns_analysis)
        AS view_refund_amount,

    (SELECT COUNT(*)
     FROM vw_returns_analysis
     WHERE Return_Date_Quality =
           'Invalid - Return Before Order')
        AS invalid_return_dates,

    (SELECT COUNT(*)
     FROM vw_returns_analysis
     WHERE Return_Date_Quality =
           'Valid Return')
        AS valid_returns,

    (SELECT COUNT(*)
     FROM vw_returns_analysis
     WHERE Return_Date_Quality =
           'Missing Sales Match')
        AS missing_sales_matches;