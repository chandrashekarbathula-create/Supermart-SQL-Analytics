-- ============================================================
-- SUPERMART SQL ANALYTICS PROJECT
-- PHASE 8: BUSINESS ANALYSIS & KPI QUERIES
-- ============================================================

USE supermart_analytics;

-- ============================================================
-- STEP 8.1
-- EXECUTIVE SALES KPI SUMMARY
--
-- Business Question:
-- What is the overall performance of the business?
-- ============================================================

SELECT
    COUNT(*) AS total_order_lines,

    COUNT(DISTINCT Order_ID) AS total_orders,

    COUNT(DISTINCT Customer_ID) AS active_customers,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(SUM(Profit), 2) AS total_profit,

    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct,

    SUM(Quantity) AS total_units_sold,

    ROUND(
        SUM(Sales) / NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup;


-- ============================================================
-- STEP 8.2
-- CATEGORY PERFORMANCE ANALYSIS
--
-- Business Question:
-- Which product categories generate the most
-- sales, profit and units?
-- ============================================================

SELECT
    p.Category,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(SUM(s.Quantity), 0),
        2
    ) AS sales_per_unit

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

GROUP BY
    p.Category

ORDER BY
    total_sales DESC;
    

-- ============================================================
-- STEP 8.2.1
-- INVESTIGATE UNKNOWN PRODUCT CATEGORY
--
-- Purpose:
-- Identify which product and transaction are producing
-- the 'Unknown' category in category analysis.
--
-- DO NOT UPDATE ANYTHING YET
-- ============================================================

SELECT
    s.Order_ID,
    s.Order_Line,
    s.Order_Date,
    s.Customer_ID,
    s.Product_ID,
    p.Product_Name,
    p.Category,
   -- p.Sub-Category,
    s.Quantity,
    s.Sales,
    s.Profit

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

WHERE p.Category = 'Unknown'
   OR p.Category IS NULL
   OR TRIM(p.Category) = '';
   
-- ============================================================
-- STEP 8.2.2
-- UNKNOWN PRODUCT BUSINESS IMPACT
--
-- Business Question:
-- How much of total sales and profit is associated
-- with the Unknown Product?
--
-- Purpose:
-- Quantify the materiality of the known data-quality exception.
-- ============================================================

SELECT
    COUNT(*) AS unknown_product_rows,

    SUM(s.Quantity) AS unknown_units,

    ROUND(SUM(s.Sales), 2) AS unknown_sales,

    ROUND(
        SUM(s.Sales) /
        NULLIF((SELECT SUM(Sales) FROM sales_dedup), 0) * 100,
        4
    ) AS pct_of_total_sales,

    ROUND(SUM(s.Profit), 2) AS unknown_profit,

    ROUND(
        SUM(s.Profit) /
        NULLIF((SELECT SUM(Profit) FROM sales_dedup), 0) * 100,
        4
    ) AS pct_of_total_profit

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

WHERE p.Product_ID = 'PROD9999';

-- ============================================================
-- STEP 8.3
-- PRODUCT-LEVEL PERFORMANCE ANALYSIS
--
-- Business Question:
-- Which individual products generate the most sales and profit?
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(SUM(s.Quantity), 0),
        2
    ) AS sales_per_unit

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category

ORDER BY
    total_sales DESC;
    

-- ============================================================
-- STEP 8.4
-- TOP 10 PRODUCTS BY SALES
--
-- Business Question:
-- Which 10 products contribute the highest sales?
-- ============================================================

select
	p.Product_ID,
    p.Product_Name,
    p.Category,
    
    count(distinct s.Order_ID) as total_orders,
    
    sum(s.Quantity) as units_sold,
    
    round(sum(s.Sales), 2) as total_sales,
    
    round(sum(s.Profit), 2) as total_profit,
    
    round( 
		sum(s.Profit) / 
        nullif(sum(s.Sales), 0) * 100,
        2
	) as profit_margin_pct
    
from sales_dedup s

inner join products_dedup p
	on s.Product_ID = p.Product_ID

group by
	p.Product_ID,
    p.Product_Name,
    p.Category

order by
	total_sales desc

limit 10;

-- ============================================================
-- STEP 8.5
-- BOTTOM 10 PRODUCTS BY SALES
--
-- Business Question:
-- Which 10 products generate the lowest sales?
--
-- Purpose:
-- Identify low-performing products that may require
-- further investigation.
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category

ORDER BY
    total_sales ASC

LIMIT 10;

-- ============================================================
-- STEP 8.6
-- LOSS-MAKING PRODUCT ANALYSIS
--
-- Business Question:
-- Which products are generating an overall loss?
--
-- Important:
-- A product is classified as loss-making here only when
-- aggregated total profit for the product is below zero.
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category

HAVING SUM(s.Profit) < 0

ORDER BY
    total_profit ASC;
    
-- ============================================================
-- STEP 8.7
-- LOSS-MAKING PRODUCT ROOT-CAUSE ANALYSIS
--
-- Business Question:
-- Why are these products generating an overall loss?
--
-- Investigate:
-- 1. Average discount
-- 2. Maximum discount
-- 3. Number of loss-making transaction lines
-- 4. Total sales
-- 5. Total profit
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,

    COUNT(*) AS transaction_lines,

    SUM(s.Quantity) AS units_sold,

    ROUND(AVG(s.Discount) * 100, 2)
        AS avg_discount_pct,

    ROUND(MAX(s.Discount) * 100, 2)
        AS max_discount_pct,

    SUM(
        CASE
            WHEN s.Profit < 0 THEN 1
            ELSE 0
        END
    ) AS loss_making_lines,

    ROUND(
        SUM(
            CASE
                WHEN s.Profit < 0 THEN s.Profit
                ELSE 0
            END
        ),
        2
    ) AS loss_from_negative_lines,

    ROUND(SUM(s.Sales), 2)
        AS total_sales,

    ROUND(SUM(s.Profit), 2)
        AS total_profit,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

WHERE p.Product_ID IN (
    'PROD0026',
    'PROD0299',
    'PROD0173',
    'PROD0126'
)

GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category

ORDER BY
    total_profit ASC;

-- ============================================================
-- STEP 8.8
-- DISCOUNT VS PROFITABILITY ANALYSIS
--
-- Business Question:
-- How does discount level relate to profitability?
--
-- Purpose:
-- Compare sales, profit and margin across discount bands.
-- ============================================================

SELECT
    CASE
        WHEN Discount = 0
            THEN '0% - No Discount'

        WHEN Discount <= 0.05
            THEN '01-05%'

        WHEN Discount <= 0.10
            THEN '06-10%'

        WHEN Discount <= 0.15
            THEN '11-15%'

        WHEN Discount <= 0.20
            THEN '16-20%'

        ELSE '21-25%'
    END AS discount_band,

    COUNT(*) AS transaction_lines,

    SUM(Quantity) AS units_sold,

    ROUND(AVG(Discount) * 100, 2)
        AS avg_discount_pct,

    ROUND(SUM(Sales), 2)
        AS total_sales,

    ROUND(SUM(Profit), 2)
        AS total_profit,

    ROUND(
        SUM(Profit) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct,

    SUM(
        CASE
            WHEN Profit < 0 THEN 1
            ELSE 0
        END
    ) AS loss_making_lines

FROM sales_dedup

GROUP BY
    CASE
        WHEN Discount = 0
            THEN '0% - No Discount'
        WHEN Discount <= 0.05
            THEN '01-05%'
        WHEN Discount <= 0.10
            THEN '06-10%'
        WHEN Discount <= 0.15
            THEN '11-15%'
        WHEN Discount <= 0.20
            THEN '16-20%'
        ELSE '21-25%'
    END

ORDER BY
    MIN(Discount);
 
 
 -- ============================================================
-- STEP 8.9
-- HIGH-DISCOUNT BUSINESS IMPACT
--
-- Business Question:
-- What proportion of business is being sold at discounts
-- above 15%, and how profitable are those transactions?
-- ============================================================

SELECT
    CASE
        WHEN Discount > 0.15
            THEN 'High Discount (>15%)'
        ELSE 'Low/Moderate Discount (<=15%)'
    END AS discount_group,

    COUNT(*) AS transaction_lines,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_transactions,

    SUM(Quantity) AS units_sold,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(Sales) * 100.0 /
        SUM(SUM(Sales)) OVER (),
        2
    ) AS pct_of_total_sales,

    ROUND(SUM(Profit), 2) AS total_profit,

    ROUND(
        SUM(Profit) /
        NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS profit_margin_pct,

    SUM(
        CASE
            WHEN Profit < 0 THEN 1
            ELSE 0
        END
    ) AS loss_making_lines

FROM sales_dedup

GROUP BY
    CASE
        WHEN Discount > 0.15
            THEN 'High Discount (>15%)'
        ELSE 'Low/Moderate Discount (<=15%)'
    END

ORDER BY profit_margin_pct DESC;



-- ============================================================
-- STEP 8.10
-- TOP 10 CUSTOMERS BY SALES
--
-- Business Question:
-- Who are our highest-value customers based on sales?
--
-- KPIs:
-- Orders
-- Units Purchased
-- Total Sales
-- Total Profit
-- Average Order Value
-- Profit Margin %
-- ============================================================

SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,
    c.Region,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_purchased,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Sales) /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS average_order_value,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct

FROM sales_dedup s

INNER JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,
    c.Region

ORDER BY
    total_sales DESC

LIMIT 10;



-- ============================================================
-- STEP 8.11
-- CUSTOMER SEGMENT PERFORMANCE
--
-- Business Question:
-- Which customer segment contributes the most
-- sales, orders and profit?
-- ============================================================

SELECT
    c.Segment,

    COUNT(DISTINCT c.Customer_ID) AS total_customers,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_purchased,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(
        SUM(s.Sales) * 100.0 /
        SUM(SUM(s.Sales)) OVER (),
        2
    ) AS sales_contribution_pct,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        SUM(SUM(s.Profit)) OVER (),
        2
    ) AS profit_contribution_pct,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup s

INNER JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Segment

ORDER BY
    total_sales DESC;

-- ============================================================
-- STEP 8.12
-- REGIONAL PERFORMANCE ANALYSIS
--
-- Business Question:
-- Which regions generate the most sales and profit?
-- How does profitability vary across regions?
-- ============================================================

SELECT
    c.Region,

    COUNT(DISTINCT c.Customer_ID) AS total_customers,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(
        SUM(s.Sales) * 100.0 /
        SUM(SUM(s.Sales)) OVER (),
        2
    ) AS sales_contribution_pct,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        SUM(SUM(s.Profit)) OVER (),
        2
    ) AS profit_contribution_pct,

    ROUND(
        SUM(s.Profit) /
        NULLIF(SUM(s.Sales), 0) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup s

INNER JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Region

ORDER BY
    total_sales DESC;


-- ============================================================
-- STEP 8.13
-- REGION × CUSTOMER SEGMENT PERFORMANCE
--
-- Business Question:
-- Which customer segments drive sales and profitability
-- within each geographic region?
-- ============================================================

SELECT
    c.Region,
    c.Segment,

    COUNT(DISTINCT c.Customer_ID) AS total_customers,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(
        SUM(s.Sales) * 100.0 /
        SUM(SUM(s.Sales)) OVER (
            PARTITION BY c.Region
        ),
        2
    ) AS pct_of_region_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        SUM(SUM(s.Profit)) OVER (
            PARTITION BY c.Region
        ),
        2
    ) AS pct_of_region_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup s

INNER JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Region,
    c.Segment

ORDER BY
    c.Region,
    total_sales DESC;


-- ============================================================
-- STEP 8.14
-- STATE PERFORMANCE ANALYSIS
--
-- Business Questions:
-- 1. Which states generate the highest sales?
-- 2. Which states generate the highest profit?
-- 3. Which states have weak profit margins?
-- ============================================================

SELECT
    c.Region,
    c.State,

    COUNT(DISTINCT c.Customer_ID) AS total_customers,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(
        SUM(s.Sales) * 100.0 /
        SUM(SUM(s.Sales)) OVER (),
        2
    ) AS pct_of_company_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        SUM(SUM(s.Profit)) OVER (),
        2
    ) AS pct_of_company_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup s

INNER JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Region,
    c.State

ORDER BY
    total_sales DESC;
    

-- ============================================================
-- STEP 8.15
-- CITY PERFORMANCE ANALYSIS
--
-- Business Questions:
-- 1. Which cities generate the highest sales?
-- 2. Which cities generate the highest profit?
-- 3. Which high-sales cities have relatively weak margins?
-- ============================================================

SELECT
    c.Region,
    c.State,
    c.City,

    COUNT(DISTINCT c.Customer_ID) AS total_customers,

    COUNT(DISTINCT s.Order_ID) AS total_orders,

    SUM(s.Quantity) AS units_sold,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(
        SUM(s.Sales) * 100.0 /
        SUM(SUM(s.Sales)) OVER (),
        2
    ) AS pct_of_company_sales,

    ROUND(SUM(s.Profit), 2) AS total_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        SUM(SUM(s.Profit)) OVER (),
        2
    ) AS pct_of_company_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup s

INNER JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Region,
    c.State,
    c.City

ORDER BY
    total_sales DESC;
    
-- ============================================================
-- STEP 8.16
-- YEARLY BUSINESS PERFORMANCE
--
-- Business Questions:
-- 1. How are sales changing year over year?
-- 2. How is profit changing year over year?
-- 3. Is profitability improving or declining?
--
-- Note:
-- Known NULL Order_Date exception is excluded because
-- it cannot be assigned to a calendar year.
-- ============================================================

SELECT
    YEAR(Order_Date) AS sales_year,

    COUNT(DISTINCT Order_ID) AS total_orders,

    SUM(Quantity) AS units_sold,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(SUM(Profit), 2) AS total_profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(Sales) /
        NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS average_order_value,

    ROUND(
        SUM(Sales) * 100.0 /
        SUM(SUM(Sales)) OVER (),
        2
    ) AS pct_of_total_sales

FROM sales_dedup

WHERE Order_Date IS NOT NULL

GROUP BY
    YEAR(Order_Date)

ORDER BY
    sales_year;
    

-- ============================================================
-- STEP 8.17
-- YEAR-OVER-YEAR (YoY) BUSINESS GROWTH
--
-- Business Questions:
-- 1. How fast are sales growing/declining each year?
-- 2. How fast is profit growing/declining?
-- 3. How are orders and units changing?
--
-- Known invalid Order_Date record excluded.
-- ============================================================

WITH yearly_performance AS
(
    SELECT
        YEAR(Order_Date) AS sales_year,

        COUNT(DISTINCT Order_ID) AS total_orders,

        SUM(Quantity) AS units_sold,

        ROUND(SUM(Sales), 2) AS total_sales,

        ROUND(SUM(Profit), 2) AS total_profit

    FROM sales_dedup

    WHERE Order_Date IS NOT NULL

    GROUP BY
        YEAR(Order_Date)
)

SELECT
    sales_year,
    total_orders,
    units_sold,
    total_sales,
    total_profit,

    -- Previous year values
    LAG(total_orders) OVER (
        ORDER BY sales_year
    ) AS previous_year_orders,

    LAG(total_sales) OVER (
        ORDER BY sales_year
    ) AS previous_year_sales,

    LAG(total_profit) OVER (
        ORDER BY sales_year
    ) AS previous_year_profit,

    -- Order growth %
    ROUND(
        (
            total_orders -
            LAG(total_orders) OVER (ORDER BY sales_year)
        ) * 100.0 /
        NULLIF(
            LAG(total_orders) OVER (ORDER BY sales_year),
            0
        ),
        2
    ) AS order_growth_pct,

    -- Sales growth %
    ROUND(
        (
            total_sales -
            LAG(total_sales) OVER (ORDER BY sales_year)
        ) * 100.0 /
        NULLIF(
            LAG(total_sales) OVER (ORDER BY sales_year),
            0
        ),
        2
    ) AS sales_growth_pct,

    -- Profit growth %
    ROUND(
        (
            total_profit -
            LAG(total_profit) OVER (ORDER BY sales_year)
        ) * 100.0 /
        NULLIF(
            LAG(total_profit) OVER (ORDER BY sales_year),
            0
        ),
        2
    ) AS profit_growth_pct

FROM yearly_performance

ORDER BY
    sales_year;


-- ============================================================
-- STEP 8.18
-- MONTHLY SALES & PROFIT TREND
--
-- Business Questions:
-- 1. How do sales change month by month?
-- 2. How does monthly profit behave?
-- 3. Which months show unusually strong/weak performance?
--
-- Known invalid Order_Date record excluded.
-- ============================================================

SELECT
    YEAR(Order_Date) AS sales_year,

    MONTH(Order_Date) AS month_number,

    MONTHNAME(Order_Date) AS month_name,

    COUNT(DISTINCT Order_ID) AS total_orders,

    SUM(Quantity) AS units_sold,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(SUM(Profit), 2) AS total_profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(Sales) /
        NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup

WHERE Order_Date IS NOT NULL

GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_Date)

ORDER BY
    sales_year,
    month_number;
    
-- ============================================================
-- STEP 8.19
-- MONTH-OF-YEAR SEASONALITY ANALYSIS
--
-- Business Question:
-- Are there recurring strong or weak months across years?
--
-- Important:
-- We aggregate the same calendar month across all years.
-- ============================================================

SELECT
    MONTH(Order_Date) AS month_number,
    MONTHNAME(Order_Date) AS month_name,

    COUNT(DISTINCT CONCAT(
        YEAR(Order_Date), '-',
        Order_ID
    )) AS total_orders,

    SUM(Quantity) AS units_sold,

    ROUND(SUM(Sales), 2) AS total_sales,

    ROUND(
        SUM(Sales) /
        COUNT(DISTINCT YEAR(Order_Date)),
        2
    ) AS average_sales_per_year,

    ROUND(SUM(Profit), 2) AS total_profit,

    ROUND(
        SUM(Profit) /
        COUNT(DISTINCT YEAR(Order_Date)),
        2
    ) AS average_profit_per_year,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(Sales) /
        NULLIF(
            COUNT(DISTINCT CONCAT(
                YEAR(Order_Date), '-',
                Order_ID
            )),
            0
        ),
        2
    ) AS average_order_value

FROM sales_dedup

WHERE Order_Date IS NOT NULL

GROUP BY
    MONTH(Order_Date),
    MONTHNAME(Order_Date)

ORDER BY
    month_number;
    

-- ============================================================
-- STEP 8.20
-- MONTH-OVER-MONTH (MoM) PERFORMANCE & GROWTH
--
-- Business Question:
-- How did each month's sales, profit and orders perform
-- compared with the immediately previous month?
--
-- SQL Concepts:
-- CTE
-- LAG()
-- Window Functions
-- MoM Growth %
-- ============================================================

WITH monthly_performance AS
(
    SELECT
        YEAR(Order_Date) AS sales_year,
        MONTH(Order_Date) AS month_number,
        MONTHNAME(Order_Date) AS month_name,

        COUNT(DISTINCT Order_ID) AS total_orders,

        SUM(Quantity) AS units_sold,

        ROUND(SUM(Sales), 2) AS total_sales,

        ROUND(SUM(Profit), 2) AS total_profit

    FROM sales_dedup

    WHERE Order_Date IS NOT NULL

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date),
        MONTHNAME(Order_Date)
),

monthly_comparison AS
(
    SELECT
        sales_year,
        month_number,
        month_name,
        total_orders,
        units_sold,
        total_sales,
        total_profit,

        LAG(total_orders) OVER (
            ORDER BY sales_year, month_number
        ) AS previous_month_orders,

        LAG(total_sales) OVER (
            ORDER BY sales_year, month_number
        ) AS previous_month_sales,

        LAG(total_profit) OVER (
            ORDER BY sales_year, month_number
        ) AS previous_month_profit

    FROM monthly_performance
)

SELECT
    sales_year,
    month_number,
    month_name,

    total_orders,
    units_sold,
    total_sales,
    total_profit,

    previous_month_orders,
    previous_month_sales,
    previous_month_profit,

    ROUND(
        (total_orders - previous_month_orders)
        * 100.0 /
        NULLIF(previous_month_orders, 0),
        2
    ) AS order_growth_pct,

    ROUND(
        (total_sales - previous_month_sales)
        * 100.0 /
        NULLIF(previous_month_sales, 0),
        2
    ) AS sales_growth_pct,

    ROUND(
        (total_profit - previous_month_profit)
        * 100.0 /
        NULLIF(previous_month_profit, 0),
        2
    ) AS profit_growth_pct

FROM monthly_comparison

ORDER BY
    sales_year,
    month_number;
    
-- ============================================================
-- STEP 8.21
-- BEST & WORST MONTH PERFORMANCE
--
-- Business Question:
-- Which individual months were the strongest and weakest
-- in terms of sales and profit?
--
-- SQL Concepts:
-- CTE
-- ROW_NUMBER()
-- Window Functions
-- Ranking
-- ============================================================

WITH monthly_performance AS
(
    SELECT
        YEAR(Order_Date) AS sales_year,
        MONTH(Order_Date) AS month_number,
        MONTHNAME(Order_Date) AS month_name,

        COUNT(DISTINCT Order_ID) AS total_orders,

        SUM(Quantity) AS units_sold,

        ROUND(SUM(Sales), 2) AS total_sales,

        ROUND(SUM(Profit), 2) AS total_profit,

        ROUND(
            SUM(Profit) * 100.0 /
            NULLIF(SUM(Sales), 0),
            2
        ) AS profit_margin_pct

    FROM sales_dedup

    WHERE Order_Date IS NOT NULL

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date),
        MONTHNAME(Order_Date)
),

ranked_months AS
(
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY total_sales DESC
        ) AS sales_rank_high,

        ROW_NUMBER() OVER (
            ORDER BY total_sales ASC
        ) AS sales_rank_low,

        ROW_NUMBER() OVER (
            ORDER BY total_profit DESC
        ) AS profit_rank_high,

        ROW_NUMBER() OVER (
            ORDER BY total_profit ASC
        ) AS profit_rank_low

    FROM monthly_performance
)

SELECT
    sales_year,
    month_number,
    month_name,
    total_orders,
    units_sold,
    total_sales,
    total_profit,
    profit_margin_pct,

    CASE
        WHEN sales_rank_high = 1 THEN 'Highest Sales Month'
        WHEN sales_rank_low = 1 THEN 'Lowest Sales Month'
        ELSE NULL
    END AS sales_performance,

    CASE
        WHEN profit_rank_high = 1 THEN 'Highest Profit Month'
        WHEN profit_rank_low = 1 THEN 'Lowest Profit Month'
        ELSE NULL
    END AS profit_performance

FROM ranked_months

WHERE sales_rank_high = 1
   OR sales_rank_low = 1
   OR profit_rank_high = 1
   OR profit_rank_low = 1

ORDER BY
    sales_year,
    month_number;


-- ============================================================
-- STEP 8.22
-- QUARTERLY BUSINESS PERFORMANCE
--
-- Business Question:
-- How did orders, sales and profitability perform
-- by quarter across each year?
--
-- SQL Concepts:
-- YEAR()
-- QUARTER()
-- GROUP BY
-- Aggregation
-- KPI Calculation
-- ============================================================

WITH sales_base AS
(
    SELECT
        Order_ID,
        Quantity,
        Sales,
        Profit,
        YEAR(Order_Date) AS sales_year,
        QUARTER(Order_Date) AS quarter_number
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
)

SELECT
    sales_year,
    quarter_number,

    CONCAT('Q', quarter_number) AS sales_quarter,

    COUNT(DISTINCT Order_ID) AS total_orders,

    SUM(Quantity) AS units_sold,

    ROUND(
        SUM(Sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(Profit),
        2
    ) AS total_profit,

    ROUND(
        SUM(Profit) * 100.0 /
        NULLIF(SUM(Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(Sales) /
        NULLIF(COUNT(DISTINCT Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_base

GROUP BY
    sales_year,
    quarter_number

ORDER BY
    sales_year,
    quarter_number;
    

-- ============================================================
-- STEP 8.23
-- QUARTER-OVER-QUARTER (QoQ) GROWTH ANALYSIS
--
-- Business Question:
-- How did orders, sales and profit change compared
-- with the immediately previous quarter?
--
-- SQL Concepts:
-- CTE
-- LAG()
-- Window Functions
-- QoQ Growth %
-- ============================================================

WITH quarterly_performance AS
(
    SELECT
        YEAR(Order_Date) AS sales_year,
        QUARTER(Order_Date) AS quarter_number,

        COUNT(DISTINCT Order_ID) AS total_orders,

        SUM(Quantity) AS units_sold,

        ROUND(SUM(Sales), 2) AS total_sales,

        ROUND(SUM(Profit), 2) AS total_profit

    FROM sales_dedup

    WHERE Order_Date IS NOT NULL

    GROUP BY
        YEAR(Order_Date),
        QUARTER(Order_Date)
),

quarterly_comparison AS
(
    SELECT
        sales_year,
        quarter_number,

        CONCAT('Q', quarter_number) AS sales_quarter,

        total_orders,
        units_sold,
        total_sales,
        total_profit,

        LAG(total_orders) OVER (
            ORDER BY sales_year, quarter_number
        ) AS previous_quarter_orders,

        LAG(total_sales) OVER (
            ORDER BY sales_year, quarter_number
        ) AS previous_quarter_sales,

        LAG(total_profit) OVER (
            ORDER BY sales_year, quarter_number
        ) AS previous_quarter_profit

    FROM quarterly_performance
)

SELECT
    sales_year,
    quarter_number,
    sales_quarter,

    total_orders,
    units_sold,
    total_sales,
    total_profit,

    previous_quarter_orders,
    previous_quarter_sales,
    previous_quarter_profit,

    ROUND(
        (total_orders - previous_quarter_orders)
        * 100.0 /
        NULLIF(previous_quarter_orders, 0),
        2
    ) AS order_growth_pct,

    ROUND(
        (total_sales - previous_quarter_sales)
        * 100.0 /
        NULLIF(previous_quarter_sales, 0),
        2
    ) AS sales_growth_pct,

    ROUND(
        (total_profit - previous_quarter_profit)
        * 100.0 /
        NULLIF(previous_quarter_profit, 0),
        2
    ) AS profit_growth_pct

FROM quarterly_comparison

ORDER BY
    sales_year,
    quarter_number;
    

-- ============================================================
-- STEP 8.24
-- OVERALL RETURN RATE & FINANCIAL IMPACT
--
-- Business Question:
-- What percentage of sales lines were returned,
-- and what is the financial impact of those returns?
--
-- Important:
-- Join using the complete business key:
-- Order_ID + Order_Line
-- ============================================================

SELECT
    COUNT(*) AS total_sales_lines,

    COUNT(r.Return_ID) AS returned_lines,

    COUNT(*) - COUNT(r.Return_ID) AS non_returned_lines,

    ROUND(
        COUNT(r.Return_ID) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    ROUND(
        SUM(s.Sales),
        2
    ) AS gross_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN s.Sales
                ELSE 0
            END
        ),
        2
    ) AS sales_value_of_returned_lines,

    ROUND(
        SUM(COALESCE(r.Refund_Amount, 0)),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(COALESCE(r.Refund_Amount, 0))
        * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS refund_pct_of_gross_sales

FROM sales_dedup s

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line;
   
-- ============================================================
-- STEP 8.25
-- RETURN ANALYSIS BY PRODUCT CATEGORY
--
-- Business Question:
-- Which categories generate the most returns?
-- Which categories have the highest return rates?
-- What is the financial impact of returns by category?
--
-- Tables:
-- sales_dedup
-- products_dedup
-- returns_valid
--
-- Join Keys:
-- Product_ID
-- Order_ID + Order_Line
-- ============================================================

SELECT
    p.Category,

    COUNT(*) AS total_sales_lines,

    COUNT(r.Return_ID) AS returned_lines,

    ROUND(
        COUNT(r.Return_ID) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    ROUND(
        SUM(s.Sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN s.Sales
                ELSE 0
            END
        ),
        2
    ) AS returned_sales_value,

    ROUND(
        SUM(COALESCE(r.Refund_Amount, 0)),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(COALESCE(r.Refund_Amount, 0))
        * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS refund_pct_of_sales

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line

GROUP BY
    p.Category

ORDER BY
    return_rate_pct DESC;
    
-- ============================================================
-- STEP 8.26
-- RETURN REASON ANALYSIS
--
-- Business Question:
-- Why are products being returned?
-- Which return reasons create the largest financial impact?
--
-- ============================================================

SELECT
    Return_Reason,

    COUNT(*) AS total_returns,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_returns,

    ROUND(
        SUM(Refund_Amount),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(Refund_Amount) * 100.0 /
        NULLIF(
            SUM(SUM(Refund_Amount)) OVER (),
            0
        ),
        2
    ) AS pct_of_total_refunds,

    ROUND(
        AVG(Refund_Amount),
        2
    ) AS average_refund_amount,

    MIN(Refund_Amount) AS minimum_refund,

    MAX(Refund_Amount) AS maximum_refund

FROM returns_valid

GROUP BY
    Return_Reason

ORDER BY
    total_returns DESC;
    
-- ============================================================
-- STEP 8.27
-- RETURN STATUS ANALYSIS
--
-- Business Question:
-- What is the current status distribution of returns?
-- How much refund value is associated with each status?
-- ============================================================

SELECT
    Return_Status,

    COUNT(*) AS total_returns,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_returns,

    ROUND(
        SUM(Refund_Amount),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(Refund_Amount) * 100.0 /
        NULLIF(
            SUM(SUM(Refund_Amount)) OVER (),
            0
        ),
        2
    ) AS pct_of_total_refunds,

    ROUND(
        AVG(Refund_Amount),
        2
    ) AS average_refund_amount

FROM returns_valid

GROUP BY
    Return_Status

ORDER BY
    total_returns DESC;
    
-- ============================================================
-- STEP 8.28
-- YEARLY RETURN PERFORMANCE
--
-- Business Question:
-- How have return volume and refund amounts changed
-- year by year?
--
-- SQL Concepts:
-- YEAR()
-- COUNT()
-- SUM()
-- AVG()
-- Window Functions
-- LAG()
-- ============================================================

WITH yearly_returns AS
(
    SELECT
        YEAR(Return_Date) AS return_year,

        COUNT(*) AS total_returns,

        ROUND(
            SUM(Refund_Amount),
            2
        ) AS total_refund_amount,

        ROUND(
            AVG(Refund_Amount),
            2
        ) AS average_refund_amount

    FROM returns_valid

    WHERE Return_Date IS NOT NULL

    GROUP BY
        YEAR(Return_Date)
),

yearly_comparison AS
(
    SELECT
        return_year,
        total_returns,
        total_refund_amount,
        average_refund_amount,

        LAG(total_returns) OVER (
            ORDER BY return_year
        ) AS previous_year_returns,

        LAG(total_refund_amount) OVER (
            ORDER BY return_year
        ) AS previous_year_refund

    FROM yearly_returns
)

SELECT
    return_year,
    total_returns,
    total_refund_amount,
    average_refund_amount,

    previous_year_returns,
    previous_year_refund,

    ROUND(
        (total_returns - previous_year_returns)
        * 100.0 /
        NULLIF(previous_year_returns, 0),
        2
    ) AS return_growth_pct,

    ROUND(
        (total_refund_amount - previous_year_refund)
        * 100.0 /
        NULLIF(previous_year_refund, 0),
        2
    ) AS refund_growth_pct

FROM yearly_comparison

ORDER BY
    return_year;
    
-- ============================================================
-- STEP 8.29
-- MONTHLY RETURN TREND
--
-- Business Question:
-- Which calendar months have the highest return volume
-- and refund exposure?
--
-- Note:
-- This combines the same month across all years.
-- ============================================================

SELECT
    MONTH(Return_Date) AS month_number,
    MONTHNAME(Return_Date) AS month_name,

    COUNT(*) AS total_returns,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_dated_returns,

    ROUND(
        SUM(Refund_Amount),
        2
    ) AS total_refund_amount,

    ROUND(
        AVG(Refund_Amount),
        2
    ) AS average_refund_amount

FROM returns_valid

WHERE Return_Date IS NOT NULL

GROUP BY
    MONTH(Return_Date),
    MONTHNAME(Return_Date)

ORDER BY
    month_number;
    
-- ============================================================
-- STEP 8.30
-- YEAR + MONTH RETURN TREND
--
-- Business Question:
-- How did returns and refund amounts change
-- month by month over time?
--
-- SQL Concepts:
-- YEAR()
-- MONTH()
-- MONTHNAME()
-- COUNT()
-- SUM()
-- AVG()
-- GROUP BY
-- ============================================================

SELECT
    YEAR(Return_Date) AS return_year,
    MONTH(Return_Date) AS month_number,
    MONTHNAME(Return_Date) AS month_name,

    COUNT(*) AS total_returns,

    ROUND(
        SUM(Refund_Amount),
        2
    ) AS total_refund_amount,

    ROUND(
        AVG(Refund_Amount),
        2
    ) AS average_refund_amount

FROM returns_valid

WHERE Return_Date IS NOT NULL

GROUP BY
    YEAR(Return_Date),
    MONTH(Return_Date),
    MONTHNAME(Return_Date)

ORDER BY
    return_year,
    month_number;
    
-- ============================================================
-- STEP 8.31
-- MONTHLY RETURN RATE
--
-- Business Question:
-- What percentage of sales transaction lines were returned
-- for each monthly sales cohort?
--
-- IMPORTANT:
-- Return is matched using the complete business key:
-- Order_ID + Order_Line
--
-- Return rate is attributed to the original Order_Date.
-- ============================================================

SELECT
    YEAR(s.Order_Date) AS sales_year,
    MONTH(s.Order_Date) AS month_number,
    MONTHNAME(s.Order_Date) AS month_name,

    COUNT(*) AS total_sales_lines,

    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS returned_lines,

    COUNT(*) -
    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS non_returned_lines,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    ROUND(
        SUM(s.Sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN s.Sales
                ELSE 0
            END
        ),
        2
    ) AS returned_sales_value,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS total_refund_amount

FROM sales_dedup s

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line

WHERE s.Order_Date IS NOT NULL

GROUP BY
    YEAR(s.Order_Date),
    MONTH(s.Order_Date),
    MONTHNAME(s.Order_Date)

ORDER BY
    sales_year,
    month_number;
    
-- ============================================================
-- STEP 8.32
-- YEARLY RETURN RATE
--
-- Business Question:
-- How has the return rate changed year over year?
--
-- Return is attributed to original Order_Date.
-- Business Key:
-- Order_ID + Order_Line
-- ============================================================

SELECT
    YEAR(s.Order_Date) AS sales_year,

    COUNT(*) AS total_sales_lines,

    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS returned_lines,

    COUNT(*) -
    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS non_returned_lines,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    ROUND(
        SUM(s.Sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN s.Sales
                ELSE 0
            END
        ),
        2
    ) AS returned_sales_value,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS refund_pct_of_sales

FROM sales_dedup s

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line

WHERE s.Order_Date IS NOT NULL

GROUP BY
    YEAR(s.Order_Date)

ORDER BY
    sales_year;
    
-- ============================================================
-- STEP 8.33
-- CATEGORY RETURN RATE ANALYSIS
--
-- Business Question:
-- Which product categories have the highest return rates
-- and the greatest financial impact from returns?
--
-- Business Key:
-- Order_ID + Order_Line
-- ============================================================

SELECT
    p.Category,

    COUNT(*) AS total_sales_lines,

    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS returned_lines,

    COUNT(*) -
    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS non_returned_lines,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    ROUND(
        SUM(s.Sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN s.Sales
                ELSE 0
            END
        ),
        2
    ) AS returned_sales_value,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS refund_pct_of_sales

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line

GROUP BY
    p.Category

ORDER BY
    return_rate_pct DESC;
    
-- ============================================================
-- STEP 8.34
-- PRODUCT-LEVEL RETURN RATE ANALYSIS
--
-- Business Question:
-- Which products have the highest return rates
-- and meaningful sales exposure?
--
-- Business Key:
-- Order_ID + Order_Line
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,

    COUNT(*) AS total_sales_lines,

    SUM(s.Quantity) AS units_sold,

    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS returned_lines,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    ROUND(
        SUM(s.Sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN s.Sales
                ELSE 0
            END
        ),
        2
    ) AS returned_sales_value,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS total_refund_amount

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line

GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category

ORDER BY
    return_rate_pct DESC,
    total_sales_lines DESC;
    
-- ============================================================
-- STEP 8.35
-- HIGH-RISK PRODUCTS
-- MINIMUM SALES VOLUME THRESHOLD
--
-- Business Question:
-- Which products have high return rates after excluding
-- very-low-volume products?
--
-- Rule:
-- Minimum 25 sales transaction lines
-- ============================================================

SELECT
    p.Product_ID,
    p.Product_Name,
    p.Category,

    COUNT(*) AS total_sales_lines,

    SUM(s.Quantity) AS units_sold,

    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS returned_lines,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0),
        2
    ) AS return_rate_pct,

    ROUND(SUM(s.Sales), 2) AS total_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN s.Sales
                ELSE 0
            END
        ),
        2
    ) AS returned_sales_value,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS total_refund_amount

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line

GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Category

HAVING COUNT(*) >= 25

ORDER BY
    return_rate_pct DESC,
    total_refund_amount DESC;
    
-- ============================================================
-- STEP 8.36
-- RETURN REASONS BY PRODUCT CATEGORY
--
-- Business Question:
-- What are the main reasons for returns within each
-- product category?
--
-- SQL Concepts:
-- INNER JOIN
-- Composite Business Key
-- GROUP BY
-- COUNT()
-- SUM()
-- Window Function
-- ============================================================

WITH category_return_reasons AS
(
    SELECT
        p.Category,
        r.Return_Reason,

        COUNT(*) AS total_returns,

        ROUND(
            SUM(r.Refund_Amount),
            2
        ) AS total_refund_amount,

        ROUND(
            AVG(r.Refund_Amount),
            2
        ) AS average_refund_amount

    FROM returns_valid r

    INNER JOIN sales_dedup s
        ON r.Order_ID = s.Order_ID
       AND r.Order_Line = s.Order_Line

    INNER JOIN products_dedup p
        ON s.Product_ID = p.Product_ID

    GROUP BY
        p.Category,
        r.Return_Reason
)

SELECT
    Category,
    Return_Reason,
    total_returns,

    ROUND(
        total_returns * 100.0 /
        SUM(total_returns) OVER (
            PARTITION BY Category
        ),
        2
    ) AS pct_of_category_returns,

    total_refund_amount,
    average_refund_amount

FROM category_return_reasons

ORDER BY
    Category,
    total_returns DESC,
    total_refund_amount DESC;
    
-- ============================================================
-- STEP 8.37
-- TOP RETURN REASON FOR EACH PRODUCT CATEGORY
--
-- Business Question:
-- What is the most common return reason within each category?
--
-- SQL Concepts:
-- CTE
-- Multiple JOINs
-- GROUP BY
-- ROW_NUMBER()
-- PARTITION BY
-- Ranking
-- ============================================================

WITH category_return_reasons AS
(
    SELECT
        p.Category,
        r.Return_Reason,

        COUNT(*) AS total_returns,

        ROUND(
            SUM(r.Refund_Amount),
            2
        ) AS total_refund_amount,

        ROUND(
            AVG(r.Refund_Amount),
            2
        ) AS average_refund_amount

    FROM returns_valid r

    INNER JOIN sales_dedup s
        ON r.Order_ID = s.Order_ID
       AND r.Order_Line = s.Order_Line

    INNER JOIN products_dedup p
        ON s.Product_ID = p.Product_ID

    GROUP BY
        p.Category,
        r.Return_Reason
),

ranked_reasons AS
(
    SELECT
        Category,
        Return_Reason,
        total_returns,
        total_refund_amount,
        average_refund_amount,

        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY
                total_returns DESC,
                total_refund_amount DESC
        ) AS reason_rank

    FROM category_return_reasons
)

SELECT
    Category,
    Return_Reason AS top_return_reason,
    total_returns,
    total_refund_amount,
    average_refund_amount

FROM ranked_reasons

WHERE reason_rank = 1

ORDER BY
    total_returns DESC,
    total_refund_amount DESC;
    
-- ============================================================
-- STEP 8.38
-- RETURN REASON × RETURN STATUS ANALYSIS
--
-- Business Question:
-- How are different return reasons distributed across
-- Pending, Approved and Completed statuses?
--
-- SQL Concepts:
-- GROUP BY
-- Conditional Aggregation
-- CASE
-- COUNT()
-- SUM()
-- Percentage Calculation
-- ============================================================

SELECT
    Return_Reason,

    COUNT(*) AS total_returns,

    SUM(
        CASE
            WHEN Return_Status = 'Pending' THEN 1
            ELSE 0
        END
    ) AS pending_returns,

    SUM(
        CASE
            WHEN Return_Status = 'Approved' THEN 1
            ELSE 0
        END
    ) AS approved_returns,

    SUM(
        CASE
            WHEN Return_Status = 'Completed' THEN 1
            ELSE 0
        END
    ) AS completed_returns,

    ROUND(
        SUM(
            CASE
                WHEN Return_Status = 'Pending' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS pending_pct,

    ROUND(
        SUM(
            CASE
                WHEN Return_Status = 'Completed' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS completed_pct,

    ROUND(
        SUM(Refund_Amount),
        2
    ) AS total_refund_amount,

    ROUND(
        AVG(Refund_Amount),
        2
    ) AS average_refund_amount

FROM returns_valid

GROUP BY
    Return_Reason

ORDER BY
    total_returns DESC;
    
-- ============================================================
-- STEP 8.39
-- RETURN STATUS FINANCIAL IMPACT
--
-- Business Question:
-- How much refund value is associated with each
-- return status?
--
-- SQL Concepts:
-- GROUP BY
-- COUNT()
-- SUM()
-- AVG()
-- Percentage of Total
-- Window Functions
-- ============================================================

SELECT
    Return_Status,

    COUNT(*) AS total_returns,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_returns,

    ROUND(
        SUM(Refund_Amount),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(Refund_Amount) * 100.0 /
        SUM(SUM(Refund_Amount)) OVER (),
        2
    ) AS pct_of_total_refunds,

    ROUND(
        AVG(Refund_Amount),
        2
    ) AS average_refund_amount,

    ROUND(
        MIN(Refund_Amount),
        2
    ) AS minimum_refund,

    ROUND(
        MAX(Refund_Amount),
        2
    ) AS maximum_refund

FROM returns_valid

GROUP BY
    Return_Status

ORDER BY
    total_refund_amount DESC;
    
-- ============================================================
-- STEP 8.40
-- NET BUSINESS PERFORMANCE AFTER RETURNS
--
-- Business Question:
-- What is the financial impact of returns on overall
-- sales and profitability?
--
-- IMPORTANT:
-- Match returns using complete business key:
-- Order_ID + Order_Line
-- ============================================================

WITH business_performance AS
(
    SELECT
        SUM(s.Sales) AS gross_sales,
        SUM(s.Profit) AS gross_profit,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line
)

SELECT
    ROUND(gross_sales, 2) AS gross_sales,

    ROUND(total_refund_amount, 2) AS total_refund_amount,

    ROUND(
        gross_sales - total_refund_amount,
        2
    ) AS net_sales,

    ROUND(
        total_refund_amount * 100.0 /
        NULLIF(gross_sales, 0),
        2
    ) AS refund_impact_pct,

    ROUND(gross_profit, 2) AS gross_profit,

    ROUND(
        gross_profit - total_refund_amount,
        2
    ) AS adjusted_profit,

    ROUND(
        gross_profit * 100.0 /
        NULLIF(gross_sales, 0),
        2
    ) AS gross_profit_margin_pct,

    ROUND(
        (gross_profit - total_refund_amount) * 100.0 /
        NULLIF(gross_sales - total_refund_amount, 0),
        2
    ) AS adjusted_profit_margin_pct

FROM business_performance;

-- ============================================================
-- STEP 8.41
-- FINANCIAL IMPACT OF RETURNS BY CATEGORY
--
-- Business Question:
-- Which categories are most financially affected by returns?
--
-- SQL Concepts:
-- Multiple JOINs
-- Conditional Aggregation
-- GROUP BY
-- KPI Calculation
-- NULLIF()
-- ============================================================

SELECT
    p.Category,

    COUNT(*) AS total_sales_lines,

    SUM(
        CASE
            WHEN r.Return_ID IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS returned_lines,

    ROUND(
        SUM(s.Sales),
        2
    ) AS gross_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS total_refund_amount,

    ROUND(
        SUM(s.Sales)
        -
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS net_sales,

    ROUND(
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) * 100.0
        / NULLIF(SUM(s.Sales), 0),
        2
    ) AS refund_impact_pct,

    ROUND(
        SUM(s.Profit),
        2
    ) AS gross_profit,

    ROUND(
        SUM(s.Profit)
        -
        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ),
        2
    ) AS adjusted_profit

FROM sales_dedup s

INNER JOIN products_dedup p
    ON s.Product_ID = p.Product_ID

LEFT JOIN returns_valid r
    ON s.Order_ID = r.Order_ID
   AND s.Order_Line = r.Order_Line

GROUP BY
    p.Category

ORDER BY
    total_refund_amount DESC;
    
    
-- ============================================================
-- STEP 8.42
-- NET PERFORMANCE BY PRODUCT CATEGORY
--
-- Business Question:
-- After accounting for refunds, how does each category
-- perform in terms of net sales and adjusted profitability?
--
-- NOTE:
-- adjusted_profit is a simplified analytical KPI:
-- gross profit - refund amount
-- ============================================================

WITH category_performance AS
(
    SELECT
        p.Category,

        SUM(s.Sales) AS gross_sales,

        SUM(s.Profit) AS gross_profit,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount

    FROM sales_dedup s

    INNER JOIN products_dedup p
        ON s.Product_ID = p.Product_ID

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    GROUP BY
        p.Category
)

SELECT
    Category,

    ROUND(gross_sales, 2) AS gross_sales,

    ROUND(
        total_refund_amount,
        2
    ) AS total_refund_amount,

    ROUND(
        gross_sales - total_refund_amount,
        2
    ) AS net_sales,

    ROUND(
        total_refund_amount * 100.0 /
        NULLIF(gross_sales, 0),
        2
    ) AS refund_impact_pct,

    ROUND(
        gross_profit,
        2
    ) AS gross_profit,

    ROUND(
        gross_profit * 100.0 /
        NULLIF(gross_sales, 0),
        2
    ) AS gross_profit_margin_pct,

    ROUND(
        gross_profit - total_refund_amount,
        2
    ) AS adjusted_profit,

    ROUND(
        (gross_profit - total_refund_amount) * 100.0 /
        NULLIF(gross_sales - total_refund_amount, 0),
        2
    ) AS adjusted_profit_margin_pct

FROM category_performance

ORDER BY
    adjusted_profit DESC;
    

-- ============================================================
-- STEP 8.43
-- YEARLY NET BUSINESS PERFORMANCE AFTER RETURNS
--
-- Business Question:
-- How did returns affect sales and profitability
-- each year?
--
-- IMPORTANT:
-- Returns are attributed to the ORIGINAL ORDER YEAR.
--
-- Adjusted Profit is a simplified analytical KPI:
-- Gross Profit - Refund Amount
-- ============================================================

WITH yearly_performance AS
(
    SELECT
        YEAR(s.Order_Date) AS sales_year,

        COUNT(DISTINCT s.Order_ID) AS total_orders,

        SUM(s.Sales) AS gross_sales,

        SUM(s.Profit) AS gross_profit,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN 1
                ELSE 0
            END
        ) AS returned_lines,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        YEAR(s.Order_Date)
)

SELECT
    sales_year,
    total_orders,
    returned_lines,

    ROUND(gross_sales, 2) AS gross_sales,

    ROUND(
        total_refund_amount,
        2
    ) AS total_refund_amount,

    ROUND(
        total_refund_amount * 100.0 /
        NULLIF(gross_sales, 0),
        2
    ) AS refund_impact_pct,

    ROUND(
        gross_sales - total_refund_amount,
        2
    ) AS net_sales,

    ROUND(gross_profit, 2) AS gross_profit,

    ROUND(
        gross_profit * 100.0 /
        NULLIF(gross_sales, 0),
        2
    ) AS gross_profit_margin_pct,

    ROUND(
        gross_profit - total_refund_amount,
        2
    ) AS adjusted_profit,

    ROUND(
        (gross_profit - total_refund_amount) * 100.0 /
        NULLIF(gross_sales - total_refund_amount, 0),
        2
    ) AS adjusted_profit_margin_pct

FROM yearly_performance

ORDER BY
    sales_year;
    

-- ============================================================
-- STEP 8.44
-- YEAR-OVER-YEAR NET PERFORMANCE AFTER RETURNS
--
-- Business Question:
-- After accounting for refunds, how are net sales
-- and adjusted profit changing year over year?
--
-- SQL Concepts:
-- CTE
-- LAG()
-- Window Functions
-- YoY Growth
-- NULLIF()
-- ============================================================

WITH yearly_performance AS
(
    SELECT
        YEAR(s.Order_Date) AS sales_year,

        SUM(s.Sales) AS gross_sales,
        SUM(s.Profit) AS gross_profit,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        YEAR(s.Order_Date)
),

net_performance AS
(
    SELECT
        sales_year,
        gross_sales,
        total_refund_amount,

        gross_sales - total_refund_amount
            AS net_sales,

        gross_profit - total_refund_amount
            AS adjusted_profit

    FROM yearly_performance
),

yearly_comparison AS
(
    SELECT
        *,

        LAG(net_sales) OVER (
            ORDER BY sales_year
        ) AS previous_year_net_sales,

        LAG(adjusted_profit) OVER (
            ORDER BY sales_year
        ) AS previous_year_adjusted_profit

    FROM net_performance
)

SELECT
    sales_year,

    ROUND(gross_sales, 2)
        AS gross_sales,

    ROUND(total_refund_amount, 2)
        AS total_refund_amount,

    ROUND(net_sales, 2)
        AS net_sales,

    ROUND(previous_year_net_sales, 2)
        AS previous_year_net_sales,

    ROUND(
        (net_sales - previous_year_net_sales) * 100.0 /
        NULLIF(previous_year_net_sales, 0),
        2
    ) AS net_sales_growth_pct,

    ROUND(adjusted_profit, 2)
        AS adjusted_profit,

    ROUND(previous_year_adjusted_profit, 2)
        AS previous_year_adjusted_profit,

    ROUND(
        (adjusted_profit - previous_year_adjusted_profit) * 100.0 /
        NULLIF(previous_year_adjusted_profit, 0),
        2
    ) AS adjusted_profit_growth_pct

FROM yearly_comparison

ORDER BY
    sales_year;
    
    
-- ============================================================
-- STEP 8.45
-- MONTHLY NET SALES & REFUND IMPACT
--
-- Business Question:
-- How do refunds affect monthly sales and profitability?
--
-- IMPORTANT:
-- Refunds are attributed to the ORIGINAL ORDER MONTH.
--
-- Return matching key:
-- Order_ID + Order_Line
--
-- SQL Concepts:
-- YEAR()
-- MONTH()
-- MONTHNAME()
-- LEFT JOIN
-- Conditional Aggregation
-- GROUP BY
-- KPI Calculation
-- ============================================================

WITH monthly_performance AS
(
    SELECT
        YEAR(s.Order_Date) AS sales_year,
        MONTH(s.Order_Date) AS month_number,
        MONTHNAME(s.Order_Date) AS month_name,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        COUNT(*) AS total_sales_lines,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS returned_lines,

        SUM(s.Sales) AS gross_sales,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount,

        SUM(s.Profit) AS gross_profit

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        YEAR(s.Order_Date),
        MONTH(s.Order_Date),
        MONTHNAME(s.Order_Date)
)

SELECT
    sales_year,
    month_number,
    month_name,

    total_orders,
    total_sales_lines,
    returned_lines,

    ROUND(
        returned_lines * 100.0 /
        NULLIF(total_sales_lines, 0),
        2
    ) AS return_rate_pct,

    ROUND(gross_sales, 2)
        AS gross_sales,

    ROUND(total_refund_amount, 2)
        AS total_refund_amount,

    ROUND(
        total_refund_amount * 100.0 /
        NULLIF(gross_sales, 0),
        2
    ) AS refund_impact_pct,

    ROUND(
        gross_sales - total_refund_amount,
        2
    ) AS net_sales,

    ROUND(gross_profit, 2)
        AS gross_profit,

    ROUND(
        gross_profit - total_refund_amount,
        2
    ) AS adjusted_profit,

    ROUND(
        (gross_profit - total_refund_amount) * 100.0 /
        NULLIF(gross_sales - total_refund_amount, 0),
        2
    ) AS adjusted_profit_margin_pct

FROM monthly_performance

ORDER BY
    sales_year,
    month_number;
    
 
-- ============================================================
-- STEP 8.46
-- HIGHEST REFUND-IMPACT MONTHS
--
-- Business Question:
-- Which months created the greatest refund pressure?
--
-- SQL Concepts:
-- CTE
-- LEFT JOIN
-- Conditional Aggregation
-- ROW_NUMBER()
-- Window Functions
-- Ranking
-- ============================================================

WITH monthly_performance AS
(
    SELECT
        YEAR(s.Order_Date) AS sales_year,
        MONTH(s.Order_Date) AS month_number,
        MONTHNAME(s.Order_Date) AS month_name,

        COUNT(*) AS total_sales_lines,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS returned_lines,

        SUM(s.Sales) AS gross_sales,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount,

        SUM(s.Profit) AS gross_profit

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        YEAR(s.Order_Date),
        MONTH(s.Order_Date),
        MONTHNAME(s.Order_Date)
),

monthly_kpis AS
(
    SELECT
        sales_year,
        month_number,
        month_name,
        total_sales_lines,
        returned_lines,

        ROUND(
            returned_lines * 100.0 /
            NULLIF(total_sales_lines, 0),
            2
        ) AS return_rate_pct,

        ROUND(gross_sales, 2) AS gross_sales,

        ROUND(total_refund_amount, 2)
            AS total_refund_amount,

        ROUND(
            total_refund_amount * 100.0 /
            NULLIF(gross_sales, 0),
            2
        ) AS refund_impact_pct,

        ROUND(
            gross_sales - total_refund_amount,
            2
        ) AS net_sales,

        ROUND(
            gross_profit - total_refund_amount,
            2
        ) AS adjusted_profit,

        ROUND(
            (gross_profit - total_refund_amount) * 100.0 /
            NULLIF(gross_sales - total_refund_amount, 0),
            2
        ) AS adjusted_profit_margin_pct

    FROM monthly_performance
),

ranked_months AS
(
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY refund_impact_pct DESC
        ) AS refund_impact_rank

    FROM monthly_kpis
)

SELECT
    refund_impact_rank,
    sales_year,
    month_number,
    month_name,
    total_sales_lines,
    returned_lines,
    return_rate_pct,
    gross_sales,
    total_refund_amount,
    refund_impact_pct,
    net_sales,
    adjusted_profit,
    adjusted_profit_margin_pct

FROM ranked_months

WHERE refund_impact_rank <= 10

ORDER BY refund_impact_rank;


-- ============================================================
-- STEP 8.47
-- LOWEST REFUND-IMPACT MONTHS
--
-- Business Question:
-- Which months experienced the LOWEST financial
-- impact from refunds?
--
-- SQL Concepts:
-- CTE
-- Conditional Aggregation
-- ROW_NUMBER()
-- Window Functions
-- Ranking
-- ============================================================

WITH monthly_performance AS
(
    SELECT
        YEAR(s.Order_Date) AS sales_year,
        MONTH(s.Order_Date) AS month_number,
        MONTHNAME(s.Order_Date) AS month_name,

        COUNT(*) AS total_sales_lines,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS returned_lines,

        SUM(s.Sales) AS gross_sales,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount,

        SUM(s.Profit) AS gross_profit

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        YEAR(s.Order_Date),
        MONTH(s.Order_Date),
        MONTHNAME(s.Order_Date)
),

monthly_kpis AS
(
    SELECT
        sales_year,
        month_number,
        month_name,
        total_sales_lines,
        returned_lines,

        ROUND(
            returned_lines * 100.0 /
            NULLIF(total_sales_lines, 0),
            2
        ) AS return_rate_pct,

        ROUND(gross_sales, 2) AS gross_sales,
        ROUND(total_refund_amount, 2) AS total_refund_amount,

        ROUND(
            total_refund_amount * 100.0 /
            NULLIF(gross_sales, 0),
            2
        ) AS refund_impact_pct,

        ROUND(
            gross_sales - total_refund_amount,
            2
        ) AS net_sales,

        ROUND(
            gross_profit - total_refund_amount,
            2
        ) AS adjusted_profit,

        ROUND(
            (gross_profit - total_refund_amount) * 100.0 /
            NULLIF(gross_sales - total_refund_amount, 0),
            2
        ) AS adjusted_profit_margin_pct

    FROM monthly_performance
),

ranked_months AS
(
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY refund_impact_pct ASC
        ) AS low_refund_rank

    FROM monthly_kpis
)

SELECT
    low_refund_rank,
    sales_year,
    month_number,
    month_name,
    total_sales_lines,
    returned_lines,
    return_rate_pct,
    gross_sales,
    total_refund_amount,
    refund_impact_pct,
    net_sales,
    adjusted_profit,
    adjusted_profit_margin_pct

FROM ranked_months

WHERE low_refund_rank <= 10

ORDER BY low_refund_rank;

-- ============================================================
-- STEP 8.48
-- REFUND IMPACT vs PROFITABILITY
--
-- Business Question:
-- Do months with higher refund impact also show
-- weaker adjusted profitability?
--
-- Classification:
-- Low Refund Impact    : < 5%
-- Medium Refund Impact : 5% - 7%
-- High Refund Impact   : > 7%
--
-- SQL Concepts:
-- CTE
-- CASE
-- Conditional Classification
-- Aggregation
-- AVG()
-- KPI Comparison
-- ============================================================

WITH monthly_performance AS
(
    SELECT
        YEAR(s.Order_Date) AS sales_year,
        MONTH(s.Order_Date) AS month_number,

        COUNT(*) AS total_sales_lines,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL THEN 1
                ELSE 0
            END
        ) AS returned_lines,

        SUM(s.Sales) AS gross_sales,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount,

        SUM(s.Profit) AS gross_profit

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        YEAR(s.Order_Date),
        MONTH(s.Order_Date)
),

monthly_kpis AS
(
    SELECT
        *,

        returned_lines * 100.0 /
        NULLIF(total_sales_lines, 0)
            AS return_rate_pct,

        total_refund_amount * 100.0 /
        NULLIF(gross_sales, 0)
            AS refund_impact_pct,

        gross_sales - total_refund_amount
            AS net_sales,

        gross_profit - total_refund_amount
            AS adjusted_profit,

        (gross_profit - total_refund_amount) * 100.0 /
        NULLIF(gross_sales - total_refund_amount, 0)
            AS adjusted_profit_margin_pct

    FROM monthly_performance
),

classified_months AS
(
    SELECT
        *,

        CASE
            WHEN refund_impact_pct < 5
                THEN 'Low Refund Impact (<5%)'

            WHEN refund_impact_pct <= 7
                THEN 'Medium Refund Impact (5-7%)'

            ELSE 'High Refund Impact (>7%)'
        END AS refund_impact_group

    FROM monthly_kpis
)

SELECT
    refund_impact_group,

    COUNT(*) AS number_of_months,

    ROUND(AVG(return_rate_pct), 2)
        AS avg_return_rate_pct,

    ROUND(AVG(refund_impact_pct), 2)
        AS avg_refund_impact_pct,

    ROUND(AVG(gross_sales), 2)
        AS avg_monthly_gross_sales,

    ROUND(AVG(net_sales), 2)
        AS avg_monthly_net_sales,

    ROUND(AVG(gross_profit), 2)
        AS avg_monthly_gross_profit,

    ROUND(AVG(adjusted_profit), 2)
        AS avg_monthly_adjusted_profit,

    ROUND(AVG(adjusted_profit_margin_pct), 2)
        AS avg_adjusted_profit_margin_pct

FROM classified_months

GROUP BY
    refund_impact_group

ORDER BY
    avg_refund_impact_pct;
    

-- ============================================================
-- STEP 8.49
-- LOW vs HIGH REFUND IMPACT - PROFITABILITY GAP
--
-- Business Question:
-- How large is the profitability difference between
-- low-refund and high-refund months?
--
-- Low Refund  = refund impact < 5%
-- High Refund = refund impact > 7%
--
-- SQL Concepts:
-- CTE
-- CASE
-- Conditional Aggregation
-- AVG()
-- KPI Comparison
-- ============================================================

WITH monthly_performance AS
(
    SELECT
        YEAR(s.Order_Date) AS sales_year,
        MONTH(s.Order_Date) AS month_number,

        SUM(s.Sales) AS gross_sales,

        SUM(s.Profit) AS gross_profit,

        SUM(
            CASE
                WHEN r.Return_ID IS NOT NULL
                THEN r.Refund_Amount
                ELSE 0
            END
        ) AS total_refund_amount

    FROM sales_dedup s

    LEFT JOIN returns_valid r
        ON s.Order_ID = r.Order_ID
       AND s.Order_Line = r.Order_Line

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        YEAR(s.Order_Date),
        MONTH(s.Order_Date)
),

monthly_kpis AS
(
    SELECT
        *,

        total_refund_amount * 100.0 /
        NULLIF(gross_sales, 0)
            AS refund_impact_pct,

        gross_profit - total_refund_amount
            AS adjusted_profit,

        (gross_profit - total_refund_amount) * 100.0 /
        NULLIF(gross_sales - total_refund_amount, 0)
            AS adjusted_profit_margin_pct

    FROM monthly_performance
),

comparison AS
(
    SELECT

        AVG(
            CASE
                WHEN refund_impact_pct < 5
                THEN adjusted_profit
            END
        ) AS low_refund_avg_profit,

        AVG(
            CASE
                WHEN refund_impact_pct > 7
                THEN adjusted_profit
            END
        ) AS high_refund_avg_profit,

        AVG(
            CASE
                WHEN refund_impact_pct < 5
                THEN adjusted_profit_margin_pct
            END
        ) AS low_refund_avg_margin,

        AVG(
            CASE
                WHEN refund_impact_pct > 7
                THEN adjusted_profit_margin_pct
            END
        ) AS high_refund_avg_margin

    FROM monthly_kpis
)

SELECT
    ROUND(low_refund_avg_profit, 2)
        AS low_refund_avg_profit,

    ROUND(high_refund_avg_profit, 2)
        AS high_refund_avg_profit,

    ROUND(
        low_refund_avg_profit -
        high_refund_avg_profit,
        2
    ) AS avg_profit_gap,

    ROUND(
        (
            low_refund_avg_profit -
            high_refund_avg_profit
        ) * 100.0 /
        NULLIF(high_refund_avg_profit, 0),
        2
    ) AS low_vs_high_profit_lift_pct,

    ROUND(low_refund_avg_margin, 2)
        AS low_refund_avg_margin_pct,

    ROUND(high_refund_avg_margin, 2)
        AS high_refund_avg_margin_pct,

    ROUND(
        low_refund_avg_margin -
        high_refund_avg_margin,
        2
    ) AS margin_gap_percentage_points

FROM comparison;


-- ============================================================
-- STEP 8.50
-- CUSTOMER PROFITABILITY ANALYSIS
--
-- Business Question:
-- Which customers generate the most revenue and profit,
-- and which high-value customers have weak margins?
--
-- SQL Concepts:
-- INNER JOIN
-- GROUP BY
-- Aggregation
-- COUNT DISTINCT
-- KPI Calculation
-- ============================================================

SELECT
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,
    c.Region,

    COUNT(DISTINCT s.Order_ID)
        AS total_orders,

    SUM(s.Quantity)
        AS units_purchased,

    ROUND(SUM(s.Sales), 2)
        AS total_sales,

    ROUND(SUM(s.Profit), 2)
        AS total_profit,

    ROUND(
        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        SUM(s.Sales) /
        NULLIF(COUNT(DISTINCT s.Order_ID), 0),
        2
    ) AS average_order_value

FROM sales_dedup s

INNER JOIN customers_clean c
    ON s.Customer_ID = c.Customer_ID

GROUP BY
    c.Customer_ID,
    c.Customer_Name,
    c.Segment,
    c.Region

ORDER BY
    total_sales DESC;
    

-- ============================================================
-- STEP 8.51
-- CUSTOMER VALUE SEGMENTATION
--
-- Business Question:
-- Which customers generate above/below-average sales
-- and above/below-average profitability?
--
-- Segments:
-- 1. High Sales + High Margin
-- 2. High Sales + Low Margin
-- 3. Low Sales + High Margin
-- 4. Low Sales + Low Margin
--
-- SQL Concepts:
-- CTE
-- CROSS JOIN
-- CASE
-- Aggregation
-- Benchmarking
-- Customer Segmentation
-- ============================================================

WITH customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        COUNT(DISTINCT s.Order_ID) AS total_orders,

        SUM(s.Quantity) AS units_purchased,

        SUM(s.Sales) AS total_sales,

        SUM(s.Profit) AS total_profit,

        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0)
            AS profit_margin_pct

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_benchmarks AS
(
    SELECT
        AVG(total_sales) AS avg_customer_sales,
        AVG(profit_margin_pct) AS avg_customer_margin
    FROM customer_performance
)

SELECT
    cp.Customer_ID,
    cp.Customer_Name,
    cp.Segment,
    cp.Region,

    cp.total_orders,
    cp.units_purchased,

    ROUND(cp.total_sales, 2)
        AS total_sales,

    ROUND(cp.total_profit, 2)
        AS total_profit,

    ROUND(cp.profit_margin_pct, 2)
        AS profit_margin_pct,

    ROUND(cb.avg_customer_sales, 2)
        AS avg_customer_sales,

    ROUND(cb.avg_customer_margin, 2)
        AS avg_customer_margin,

    CASE
        WHEN cp.total_sales >= cb.avg_customer_sales
             AND cp.profit_margin_pct >= cb.avg_customer_margin
            THEN 'High Sales + High Margin'

        WHEN cp.total_sales >= cb.avg_customer_sales
             AND cp.profit_margin_pct < cb.avg_customer_margin
            THEN 'High Sales + Low Margin'

        WHEN cp.total_sales < cb.avg_customer_sales
             AND cp.profit_margin_pct >= cb.avg_customer_margin
            THEN 'Low Sales + High Margin'

        ELSE 'Low Sales + Low Margin'
    END AS customer_value_segment

FROM customer_performance cp

CROSS JOIN customer_benchmarks cb

ORDER BY
    cp.total_sales DESC;
    
    
-- ============================================================
-- STEP 8.52
-- CUSTOMER VALUE SEGMENT SUMMARY
--
-- Business Question:
-- How many customers fall into each customer value segment,
-- and how much sales and profit does each segment generate?
--
-- SQL Concepts:
-- CTE
-- CASE
-- Aggregation
-- CROSS JOIN
-- Customer Segmentation
-- Contribution Analysis
-- ============================================================

WITH customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        SUM(s.Quantity) AS units_purchased,
        SUM(s.Sales) AS total_sales,
        SUM(s.Profit) AS total_profit,

        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0) AS profit_margin_pct

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_benchmarks AS
(
    SELECT
        AVG(total_sales) AS avg_customer_sales,
        AVG(profit_margin_pct) AS avg_customer_margin
    FROM customer_performance
),

classified_customers AS
(
    SELECT
        cp.*,

        CASE
            WHEN cp.total_sales >= cb.avg_customer_sales
                 AND cp.profit_margin_pct >= cb.avg_customer_margin
                THEN 'High Sales + High Margin'

            WHEN cp.total_sales >= cb.avg_customer_sales
                 AND cp.profit_margin_pct < cb.avg_customer_margin
                THEN 'High Sales + Low Margin'

            WHEN cp.total_sales < cb.avg_customer_sales
                 AND cp.profit_margin_pct >= cb.avg_customer_margin
                THEN 'Low Sales + High Margin'

            ELSE 'Low Sales + Low Margin'
        END AS customer_value_segment

    FROM customer_performance cp

    CROSS JOIN customer_benchmarks cb
)

SELECT
    customer_value_segment,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_customers,

    SUM(total_orders) AS total_orders,

    SUM(units_purchased) AS units_purchased,

    ROUND(SUM(total_sales), 2) AS total_sales,

    ROUND(
        SUM(total_sales) * 100.0 /
        SUM(SUM(total_sales)) OVER (),
        2
    ) AS sales_contribution_pct,

    ROUND(SUM(total_profit), 2) AS total_profit,

    ROUND(
        SUM(total_profit) * 100.0 /
        SUM(SUM(total_profit)) OVER (),
        2
    ) AS profit_contribution_pct,

    ROUND(
        SUM(total_profit) * 100.0 /
        NULLIF(SUM(total_sales), 0),
        2
    ) AS segment_profit_margin_pct,

    ROUND(AVG(total_sales), 2) AS avg_sales_per_customer

FROM classified_customers

GROUP BY
    customer_value_segment

ORDER BY
    total_sales DESC;
    

-- ============================================================
-- STEP 8.53
-- CUSTOMER VALUE SEGMENT BY REGION
--
-- Business Question:
-- How are customer value segments distributed across regions,
-- and which regions contribute the most sales and profit
-- within each customer value segment?
--
-- SQL Concepts:
-- CTE
-- CASE
-- CROSS JOIN
-- GROUP BY
-- Aggregation
-- Window Functions
-- Contribution Analysis
-- ============================================================

WITH customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        SUM(s.Quantity) AS units_purchased,
        SUM(s.Sales) AS total_sales,
        SUM(s.Profit) AS total_profit,

        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0) AS profit_margin_pct

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_benchmarks AS
(
    SELECT
        AVG(total_sales) AS avg_customer_sales,
        AVG(profit_margin_pct) AS avg_customer_margin
    FROM customer_performance
),

classified_customers AS
(
    SELECT
        cp.*,

        CASE
            WHEN cp.total_sales >= cb.avg_customer_sales
             AND cp.profit_margin_pct >= cb.avg_customer_margin
                THEN 'High Sales + High Margin'

            WHEN cp.total_sales >= cb.avg_customer_sales
             AND cp.profit_margin_pct < cb.avg_customer_margin
                THEN 'High Sales + Low Margin'

            WHEN cp.total_sales < cb.avg_customer_sales
             AND cp.profit_margin_pct >= cb.avg_customer_margin
                THEN 'Low Sales + High Margin'

            ELSE 'Low Sales + Low Margin'
        END AS customer_value_segment

    FROM customer_performance cp

    CROSS JOIN customer_benchmarks cb
),

region_segment_summary AS
(
    SELECT
        Region,
        customer_value_segment,

        COUNT(*) AS total_customers,
        SUM(total_orders) AS total_orders,
        SUM(units_purchased) AS units_purchased,
        SUM(total_sales) AS total_sales,
        SUM(total_profit) AS total_profit

    FROM classified_customers

    GROUP BY
        Region,
        customer_value_segment
)

SELECT
    Region,
    customer_value_segment,

    total_customers,
    total_orders,
    units_purchased,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        total_sales * 100.0 /
        NULLIF(
            SUM(total_sales) OVER (
                PARTITION BY customer_value_segment
            ), 0
        ),
        2
    ) AS pct_of_segment_sales,

    ROUND(total_profit, 2) AS total_profit,

    ROUND(
        total_profit * 100.0 /
        NULLIF(
            SUM(total_profit) OVER (
                PARTITION BY customer_value_segment
            ), 0
        ),
        2
    ) AS pct_of_segment_profit,

    ROUND(
        total_profit * 100.0 /
        NULLIF(total_sales, 0),
        2
    ) AS profit_margin_pct

FROM region_segment_summary

ORDER BY
    customer_value_segment,
    total_sales DESC;
    
    
-- ============================================================
-- STEP 8.54
-- CUSTOMER CONCENTRATION ANALYSIS
--
-- Business Question:
-- How dependent is the company on its highest-value customers?
--
-- We will classify customers into:
-- Top 10%
-- Next 20%
-- Remaining 70%
--
-- SQL Concepts:
-- CTE
-- Aggregation
-- Window Functions
-- NTILE()
-- CASE
-- Contribution Analysis
-- ============================================================

WITH customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        SUM(s.Quantity) AS units_purchased,
        SUM(s.Sales) AS total_sales,
        SUM(s.Profit) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

ranked_customers AS
(
    SELECT
        *,

        NTILE(10) OVER (
            ORDER BY total_sales DESC
        ) AS sales_decile

    FROM customer_performance
),

classified_customers AS
(
    SELECT
        *,

        CASE
            WHEN sales_decile = 1
                THEN 'Top 10% Customers'

            WHEN sales_decile IN (2,3)
                THEN 'Next 20% Customers'

            ELSE 'Remaining 70% Customers'
        END AS customer_concentration_group

    FROM ranked_customers
),

concentration_summary AS
(
    SELECT
        customer_concentration_group,

        COUNT(*) AS total_customers,
        SUM(total_orders) AS total_orders,
        SUM(units_purchased) AS units_purchased,
        SUM(total_sales) AS total_sales,
        SUM(total_profit) AS total_profit

    FROM classified_customers

    GROUP BY
        customer_concentration_group
)

SELECT
    customer_concentration_group,

    total_customers,

    ROUND(
        total_customers * 100.0 /
        SUM(total_customers) OVER (),
        2
    ) AS pct_of_customers,

    total_orders,

    units_purchased,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (),
        2
    ) AS sales_contribution_pct,

    ROUND(total_profit, 2) AS total_profit,

    ROUND(
        total_profit * 100.0 /
        SUM(total_profit) OVER (),
        2
    ) AS profit_contribution_pct,

    ROUND(
        total_profit * 100.0 /
        NULLIF(total_sales, 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        total_sales /
        NULLIF(total_customers, 0),
        2
    ) AS avg_sales_per_customer

FROM concentration_summary

ORDER BY
    CASE customer_concentration_group
        WHEN 'Top 10% Customers' THEN 1
        WHEN 'Next 20% Customers' THEN 2
        ELSE 3
    END;
    
-- ============================================================
-- STEP 8.55
-- TOP CUSTOMER RANKING
--
-- Business Question:
-- Who are the company's highest-value customers,
-- and how do they rank by sales and profit?
--
-- SQL Concepts:
-- CTE
-- Aggregation
-- RANK()
-- DENSE_RANK()
-- Window Functions
-- Customer Ranking
-- ============================================================

WITH customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        SUM(s.Quantity) AS units_purchased,

        ROUND(SUM(s.Sales), 2) AS total_sales,
        ROUND(SUM(s.Profit), 2) AS total_profit,

        ROUND(
            SUM(s.Profit) * 100.0 /
            NULLIF(SUM(s.Sales), 0),
            2
        ) AS profit_margin_pct,

        ROUND(
            SUM(s.Sales) /
            NULLIF(COUNT(DISTINCT s.Order_ID), 0),
            2
        ) AS average_order_value

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

ranked_customers AS
(
    SELECT
        *,

        RANK() OVER (
            ORDER BY total_sales DESC
        ) AS sales_rank,

        RANK() OVER (
            ORDER BY total_profit DESC
        ) AS profit_rank,

        DENSE_RANK() OVER (
            ORDER BY profit_margin_pct DESC
        ) AS margin_rank

    FROM customer_performance
)

SELECT
    sales_rank,
    Customer_ID,
    Customer_Name,
    Segment,
    Region,

    total_orders,
    units_purchased,
    total_sales,
    total_profit,
    profit_margin_pct,
    average_order_value,

    profit_rank,
    margin_rank

FROM ranked_customers

WHERE sales_rank <= 20

ORDER BY
    sales_rank;
    

-- ============================================================
-- STEP 8.56
-- CUSTOMER PURCHASE FREQUENCY ANALYSIS
--
-- Business Question:
-- How frequently do customers purchase,
-- and how much sales and profit are generated
-- by each purchase-frequency group?
--
-- SQL Concepts:
-- CTE
-- CASE
-- Aggregation
-- GROUP BY
-- Window Functions
-- Customer Behaviour Analysis
-- ============================================================

WITH customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        SUM(s.Quantity) AS units_purchased,

        SUM(s.Sales) AS total_sales,
        SUM(s.Profit) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

classified_customers AS
(
    SELECT
        *,

        CASE
            WHEN total_orders <= 5
                THEN 'Low Frequency (1-5 Orders)'

            WHEN total_orders <= 10
                THEN 'Medium Frequency (6-10 Orders)'

            WHEN total_orders <= 15
                THEN 'High Frequency (11-15 Orders)'

            ELSE 'Very High Frequency (16+ Orders)'
        END AS purchase_frequency_group

    FROM customer_performance
),

frequency_summary AS
(
    SELECT
        purchase_frequency_group,

        COUNT(*) AS total_customers,
        SUM(total_orders) AS total_orders,
        SUM(units_purchased) AS units_purchased,
        SUM(total_sales) AS total_sales,
        SUM(total_profit) AS total_profit

    FROM classified_customers

    GROUP BY
        purchase_frequency_group
)

SELECT
    purchase_frequency_group,

    total_customers,

    ROUND(
        total_customers * 100.0 /
        SUM(total_customers) OVER (),
        2
    ) AS pct_of_customers,

    total_orders,

    units_purchased,

    ROUND(
        total_orders * 1.0 /
        NULLIF(total_customers, 0),
        2
    ) AS avg_orders_per_customer,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (),
        2
    ) AS sales_contribution_pct,

    ROUND(total_profit, 2) AS total_profit,

    ROUND(
        total_profit * 100.0 /
        SUM(total_profit) OVER (),
        2
    ) AS profit_contribution_pct,

    ROUND(
        total_profit * 100.0 /
        NULLIF(total_sales, 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        total_sales /
        NULLIF(total_orders, 0),
        2
    ) AS average_order_value

FROM frequency_summary

ORDER BY
    CASE purchase_frequency_group
        WHEN 'Low Frequency (1-5 Orders)' THEN 1
        WHEN 'Medium Frequency (6-10 Orders)' THEN 2
        WHEN 'High Frequency (11-15 Orders)' THEN 3
        ELSE 4
    END;
    
-- ============================================================
-- STEP 8.57
-- PURCHASE FREQUENCY × CUSTOMER VALUE ANALYSIS
--
-- Business Question:
-- How does purchase frequency relate to customer value,
-- sales contribution and profitability?
--
-- SQL Concepts:
-- CTE
-- CASE
-- CROSS JOIN
-- Aggregation
-- Multi-Dimensional Segmentation
-- ============================================================

WITH customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        SUM(s.Quantity) AS units_purchased,
        SUM(s.Sales) AS total_sales,
        SUM(s.Profit) AS total_profit,

        SUM(s.Profit) * 100.0 /
        NULLIF(SUM(s.Sales), 0) AS profit_margin_pct

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_benchmarks AS
(
    SELECT
        AVG(total_sales) AS avg_customer_sales,
        AVG(profit_margin_pct) AS avg_customer_margin
    FROM customer_performance
),

customer_classification AS
(
    SELECT
        cp.*,

        -- Purchase Frequency Classification
        CASE
            WHEN cp.total_orders <= 5
                THEN 'Low Frequency (1-5 Orders)'

            WHEN cp.total_orders <= 10
                THEN 'Medium Frequency (6-10 Orders)'

            WHEN cp.total_orders <= 15
                THEN 'High Frequency (11-15 Orders)'

            ELSE 'Very High Frequency (16+ Orders)'
        END AS purchase_frequency_group,

        -- Customer Value Classification
        CASE
            WHEN cp.total_sales >= cb.avg_customer_sales
                 AND cp.profit_margin_pct >= cb.avg_customer_margin
                THEN 'High Sales + High Margin'

            WHEN cp.total_sales >= cb.avg_customer_sales
                 AND cp.profit_margin_pct < cb.avg_customer_margin
                THEN 'High Sales + Low Margin'

            WHEN cp.total_sales < cb.avg_customer_sales
                 AND cp.profit_margin_pct >= cb.avg_customer_margin
                THEN 'Low Sales + High Margin'

            ELSE 'Low Sales + Low Margin'
        END AS customer_value_segment

    FROM customer_performance cp

    CROSS JOIN customer_benchmarks cb
)

SELECT
    purchase_frequency_group,
    customer_value_segment,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (
            PARTITION BY purchase_frequency_group
        ),
        2
    ) AS pct_of_frequency_group,

    SUM(total_orders) AS total_orders,
    SUM(units_purchased) AS units_purchased,

    ROUND(SUM(total_sales), 2) AS total_sales,

    ROUND(
        SUM(total_profit),
        2
    ) AS total_profit,

    ROUND(
        SUM(total_profit) * 100.0 /
        NULLIF(SUM(total_sales), 0),
        2
    ) AS profit_margin_pct,

    ROUND(
        AVG(total_sales),
        2
    ) AS avg_sales_per_customer

FROM customer_classification

GROUP BY
    purchase_frequency_group,
    customer_value_segment

ORDER BY

    CASE purchase_frequency_group
        WHEN 'Low Frequency (1-5 Orders)' THEN 1
        WHEN 'Medium Frequency (6-10 Orders)' THEN 2
        WHEN 'High Frequency (11-15 Orders)' THEN 3
        ELSE 4
    END,

    total_sales DESC;
    
-- ============================================================
-- STEP 8.58
-- CUSTOMER RECENCY ANALYSIS
--
-- Business Question:
-- How recently did customers purchase,
-- and how much historical value comes from
-- active vs inactive customers?
--
-- IMPORTANT:
-- Recency is measured relative to the maximum Order_Date
-- in the dataset, NOT today's system date.
--
-- SQL Concepts:
-- CTE
-- MAX()
-- DATEDIFF()
-- CASE
-- CROSS JOIN
-- Aggregation
-- Customer Lifecycle Analysis
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MIN(s.Order_Date) AS first_order_date,
        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS total_orders,
        SUM(s.Quantity) AS units_purchased,
        SUM(s.Sales) AS total_sales,
        SUM(s.Profit) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_recency AS
(
    SELECT
        cp.*,
        ad.max_order_date,

        DATEDIFF(
            ad.max_order_date,
            cp.last_order_date
        ) AS recency_days

    FROM customer_performance cp

    CROSS JOIN analysis_date ad
),

classified_customers AS
(
    SELECT
        *,

        CASE
            WHEN recency_days <= 30
                THEN 'Active (0-30 Days)'

            WHEN recency_days <= 90
                THEN 'Recent (31-90 Days)'

            WHEN recency_days <= 180
                THEN 'At Risk (91-180 Days)'

            ELSE 'Inactive (181+ Days)'
        END AS recency_group

    FROM customer_recency
)

SELECT
    recency_group,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS pct_of_customers,

    ROUND(
        AVG(recency_days),
        2
    ) AS avg_recency_days,

    SUM(total_orders) AS total_orders,
    SUM(units_purchased) AS units_purchased,

    ROUND(
        SUM(total_sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(total_sales) * 100.0 /
        SUM(SUM(total_sales)) OVER (),
        2
    ) AS sales_contribution_pct,

    ROUND(
        SUM(total_profit),
        2
    ) AS total_profit,

    ROUND(
        SUM(total_profit) * 100.0 /
        SUM(SUM(total_profit)) OVER (),
        2
    ) AS profit_contribution_pct,

    ROUND(
        SUM(total_profit) * 100.0 /
        NULLIF(SUM(total_sales), 0),
        2
    ) AS profit_margin_pct

FROM classified_customers

GROUP BY
    recency_group

ORDER BY
    CASE recency_group
        WHEN 'Active (0-30 Days)' THEN 1
        WHEN 'Recent (31-90 Days)' THEN 2
        WHEN 'At Risk (91-180 Days)' THEN 3
        ELSE 4
    END;
    
    
    -- ============================================================
-- STEP 8.59
-- RECENCY × PURCHASE FREQUENCY ANALYSIS
--
-- Business Question:
-- How does customer purchase frequency vary across
-- Active, Recent, At Risk and Inactive customers?
--
-- This combines:
-- R = Recency
-- F = Frequency
--
-- SQL Concepts:
-- CTE
-- CASE
-- DATEDIFF()
-- CROSS JOIN
-- Aggregation
-- Customer Behaviour Segmentation
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS total_orders,

        SUM(s.Quantity) AS units_purchased,

        SUM(s.Sales) AS total_sales,

        SUM(s.Profit) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_behavior AS
(
    SELECT
        cp.*,

        DATEDIFF(
            ad.max_order_date,
            cp.last_order_date
        ) AS recency_days

    FROM customer_performance cp

    CROSS JOIN analysis_date ad
),

classified_customers AS
(
    SELECT
        *,

        CASE
            WHEN recency_days <= 30
                THEN 'Active (0-30 Days)'

            WHEN recency_days <= 90
                THEN 'Recent (31-90 Days)'

            WHEN recency_days <= 180
                THEN 'At Risk (91-180 Days)'

            ELSE 'Inactive (181+ Days)'
        END AS recency_group,

        CASE
            WHEN total_orders <= 5
                THEN 'Low Frequency (1-5 Orders)'

            WHEN total_orders <= 10
                THEN 'Medium Frequency (6-10 Orders)'

            WHEN total_orders <= 15
                THEN 'High Frequency (11-15 Orders)'

            ELSE 'Very High Frequency (16+ Orders)'
        END AS purchase_frequency_group

    FROM customer_behavior
),

behavior_summary AS
(
    SELECT
        recency_group,
        purchase_frequency_group,

        COUNT(*) AS total_customers,

        SUM(total_orders) AS total_orders,

        SUM(units_purchased) AS units_purchased,

        SUM(total_sales) AS total_sales,

        SUM(total_profit) AS total_profit

    FROM classified_customers

    GROUP BY
        recency_group,
        purchase_frequency_group
)

SELECT
    recency_group,
    purchase_frequency_group,

    total_customers,

    ROUND(
        total_customers * 100.0 /
        SUM(total_customers) OVER (
            PARTITION BY recency_group
        ),
        2
    ) AS pct_of_recency_group,

    total_orders,
    units_purchased,

    ROUND(
        total_sales,
        2
    ) AS total_sales,

    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (
            PARTITION BY recency_group
        ),
        2
    ) AS pct_of_recency_sales,

    ROUND(
        total_profit,
        2
    ) AS total_profit,

    ROUND(
        total_profit * 100.0 /
        SUM(total_profit) OVER (
            PARTITION BY recency_group
        ),
        2
    ) AS pct_of_recency_profit,

    ROUND(
        total_profit * 100.0 /
        NULLIF(total_sales, 0),
        2
    ) AS profit_margin_pct

FROM behavior_summary

ORDER BY

    CASE recency_group
        WHEN 'Active (0-30 Days)' THEN 1
        WHEN 'Recent (31-90 Days)' THEN 2
        WHEN 'At Risk (91-180 Days)' THEN 3
        ELSE 4
    END,

    CASE purchase_frequency_group
        WHEN 'Low Frequency (1-5 Orders)' THEN 1
        WHEN 'Medium Frequency (6-10 Orders)' THEN 2
        WHEN 'High Frequency (11-15 Orders)' THEN 3
        ELSE 4
    END;
    
-- ============================================================
-- STEP 8.60
-- RFM CUSTOMER SCORING
--
-- Business Question:
-- How can customers be scored based on:
-- Recency, Frequency and Monetary Value?
--
-- R = Recency
-- F = Frequency
-- M = Monetary Value
--
-- Score:
-- 5 = Best
-- 1 = Lowest
--
-- SQL Concepts:
-- CTE
-- MAX()
-- COUNT(DISTINCT)
-- SUM()
-- DATEDIFF()
-- NTILE()
-- Window Functions
-- CONCAT()
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_rfm_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        ROUND(
            SUM(s.Sales),
            2
        ) AS monetary_value

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

rfm_metrics AS
(
    SELECT
        r.*,

        DATEDIFF(
            a.max_order_date,
            r.last_order_date
        ) AS recency_days

    FROM customer_rfm_base r

    CROSS JOIN analysis_date a
),

rfm_scores AS
(
    SELECT
        *,

        -- Lower recency is better.
        -- DESC means largest recency gets score 1
        -- and smallest recency gets score 5.
        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        -- Higher frequency is better.
        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        -- Higher monetary value is better.
        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
)

SELECT
    Customer_ID,
    Customer_Name,
    Segment,
    Region,

    last_order_date,
    recency_days,
    frequency,
    monetary_value,

    r_score,
    f_score,
    m_score,

    CONCAT(
        r_score,
        f_score,
        m_score
    ) AS rfm_score,

    r_score + f_score + m_score AS total_rfm_score

FROM rfm_scores

ORDER BY
    total_rfm_score DESC,
    monetary_value DESC;
    

-- ============================================================
-- STEP 8.61
-- RFM CUSTOMER SEGMENTATION
--
-- Business Question:
-- Which customers are Champions, Loyal, Potential Loyalists,
-- At Risk, Need Attention or Lost?
--
-- SQL Concepts:
-- CTE
-- NTILE()
-- Window Functions
-- CASE
-- RFM Segmentation
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_rfm_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        ROUND(SUM(s.Sales), 2) AS monetary_value

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

rfm_metrics AS
(
    SELECT
        b.*,

        DATEDIFF(
            a.max_order_date,
            b.last_order_date
        ) AS recency_days

    FROM customer_rfm_base b

    CROSS JOIN analysis_date a
),

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),

rfm_segments AS
(
    SELECT
        *,

        CONCAT(
            r_score,
            f_score,
            m_score
        ) AS rfm_score,

        r_score + f_score + m_score AS total_rfm_score,

        CASE

            -- Very recent + frequent
            WHEN r_score >= 4
                 AND f_score >= 4
                THEN 'Champions'

            -- Frequent customers with reasonable recency
            WHEN r_score >= 3
                 AND f_score >= 4
                THEN 'Loyal Customers'

            -- Very recent but frequency still developing
            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            -- Very recent but low frequency
            WHEN r_score = 5
                 AND f_score = 1
                THEN 'New Customers'

            -- Middle recency/frequency
            WHEN r_score = 3
                 AND f_score BETWEEN 2 AND 3
                THEN 'Need Attention'

            -- Historically frequent but becoming inactive
            WHEN r_score <= 2
                 AND f_score >= 4
                THEN 'At Risk'

            -- Low recency and moderate frequency
            WHEN r_score <= 2
                 AND f_score BETWEEN 2 AND 3
                THEN 'Hibernating'

            -- Low recency + low frequency
            ELSE 'Lost Customers'

        END AS rfm_segment

    FROM rfm_scores
)

SELECT
    Customer_ID,
    Customer_Name,
    Segment,
    Region,

    last_order_date,
    recency_days,
    frequency,
    monetary_value,

    r_score,
    f_score,
    m_score,

    rfm_score,
    total_rfm_score,
    rfm_segment

FROM rfm_segments

ORDER BY
    CASE rfm_segment
        WHEN 'Champions' THEN 1
        WHEN 'Loyal Customers' THEN 2
        WHEN 'Potential Loyalists' THEN 3
        WHEN 'New Customers' THEN 4
        WHEN 'Need Attention' THEN 5
        WHEN 'At Risk' THEN 6
        WHEN 'Hibernating' THEN 7
        ELSE 8
    END,
    monetary_value DESC;
    

-- ============================================================
-- STEP 8.62
-- RFM CUSTOMER SEGMENT BUSINESS SUMMARY
--
-- Business Question:
-- How large and valuable is each RFM customer segment?
--
-- SQL Concepts:
-- CTE
-- NTILE()
-- CASE
-- Window Functions
-- Aggregation
-- Contribution Analysis
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_rfm_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS units_purchased,

        ROUND(SUM(s.Sales), 2) AS monetary_value,

        ROUND(SUM(s.Profit), 2) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

rfm_metrics AS
(
    SELECT
        b.*,

        DATEDIFF(
            a.max_order_date,
            b.last_order_date
        ) AS recency_days

    FROM customer_rfm_base b

    CROSS JOIN analysis_date a
),

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),

rfm_classified AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 4
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score = 1
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score BETWEEN 2 AND 3
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 4
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score BETWEEN 2 AND 3
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM rfm_scores
),

segment_summary AS
(
    SELECT
        rfm_segment,

        COUNT(*) AS total_customers,

        SUM(frequency) AS total_orders,

        SUM(units_purchased) AS units_purchased,

        SUM(monetary_value) AS total_sales,

        SUM(total_profit) AS total_profit,

        AVG(recency_days) AS avg_recency_days,

        AVG(frequency) AS avg_orders_per_customer,

        AVG(monetary_value) AS avg_sales_per_customer

    FROM rfm_classified

    GROUP BY
        rfm_segment
)

SELECT
    rfm_segment,

    total_customers,

    ROUND(
        total_customers * 100.0 /
        SUM(total_customers) OVER (),
        2
    ) AS pct_of_customers,

    total_orders,

    units_purchased,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (),
        2
    ) AS sales_contribution_pct,

    ROUND(total_profit, 2) AS total_profit,

    ROUND(
        total_profit * 100.0 /
        SUM(total_profit) OVER (),
        2
    ) AS profit_contribution_pct,

    ROUND(
        total_profit * 100.0 /
        NULLIF(total_sales, 0),
        2
    ) AS profit_margin_pct,

    ROUND(avg_recency_days, 2) AS avg_recency_days,

    ROUND(avg_orders_per_customer, 2)
        AS avg_orders_per_customer,

    ROUND(avg_sales_per_customer, 2)
        AS avg_sales_per_customer

FROM segment_summary

ORDER BY
    CASE rfm_segment
        WHEN 'Champions' THEN 1
        WHEN 'Loyal Customers' THEN 2
        WHEN 'Potential Loyalists' THEN 3
        WHEN 'New Customers' THEN 4
        WHEN 'Need Attention' THEN 5
        WHEN 'At Risk' THEN 6
        WHEN 'Hibernating' THEN 7
        ELSE 8
    END;
    

-- ============================================================
-- STEP 8.63
-- RFM SEGMENT × REGION ANALYSIS
--
-- Business Question:
-- How are RFM customer segments distributed across regions?
--
-- SQL Concepts:
-- CTE
-- NTILE()
-- CASE
-- Window Functions
-- Aggregation
-- Regional Customer Analysis
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_rfm_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS units_purchased,

        SUM(s.Sales) AS monetary_value,

        SUM(s.Profit) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Region
),

rfm_metrics AS
(
    SELECT
        b.*,

        DATEDIFF(
            a.max_order_date,
            b.last_order_date
        ) AS recency_days

    FROM customer_rfm_base b

    CROSS JOIN analysis_date a
),

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),

rfm_classified AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 4
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score = 1
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score BETWEEN 2 AND 3
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 4
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score BETWEEN 2 AND 3
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM rfm_scores
),

region_rfm_summary AS
(
    SELECT
        Region,
        rfm_segment,

        COUNT(*) AS total_customers,

        SUM(frequency) AS total_orders,

        SUM(units_purchased) AS units_purchased,

        SUM(monetary_value) AS total_sales,

        SUM(total_profit) AS total_profit

    FROM rfm_classified

    GROUP BY
        Region,
        rfm_segment
)

SELECT
    Region,
    rfm_segment,

    total_customers,

    ROUND(
        total_customers * 100.0 /
        SUM(total_customers) OVER (
            PARTITION BY rfm_segment
        ),
        2
    ) AS pct_of_segment_customers,

    total_orders,
    units_purchased,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (
            PARTITION BY rfm_segment
        ),
        2
    ) AS pct_of_segment_sales,

    ROUND(total_profit, 2) AS total_profit,

    ROUND(
        total_profit * 100.0 /
        SUM(total_profit) OVER (
            PARTITION BY rfm_segment
        ),
        2
    ) AS pct_of_segment_profit,

    ROUND(
        total_profit * 100.0 /
        NULLIF(total_sales, 0),
        2
    ) AS profit_margin_pct

FROM region_rfm_summary

ORDER BY

    CASE rfm_segment
        WHEN 'Champions' THEN 1
        WHEN 'Loyal Customers' THEN 2
        WHEN 'Potential Loyalists' THEN 3
        WHEN 'New Customers' THEN 4
        WHEN 'Need Attention' THEN 5
        WHEN 'At Risk' THEN 6
        WHEN 'Hibernating' THEN 7
        ELSE 8
    END,

    total_sales DESC;
    
    
-- ============================================================
-- STEP 8.64
-- RFM SEGMENT × CUSTOMER SEGMENT ANALYSIS
--
-- Business Question:
-- Which customer segments contain our strongest and
-- weakest RFM customer groups?
--
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_rfm_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS units_purchased,

        SUM(s.Sales) AS monetary_value,

        SUM(s.Profit) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

rfm_metrics AS
(
    SELECT
        b.*,

        DATEDIFF(
            a.max_order_date,
            b.last_order_date
        ) AS recency_days

    FROM customer_rfm_base b

    CROSS JOIN analysis_date a
),

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),

rfm_classified AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 4
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score = 1
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score BETWEEN 2 AND 3
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 4
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score BETWEEN 2 AND 3
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM rfm_scores
),

segment_rfm_summary AS
(
    SELECT
        Segment,
        rfm_segment,

        COUNT(*) AS total_customers,

        SUM(frequency) AS total_orders,

        SUM(units_purchased) AS units_purchased,

        SUM(monetary_value) AS total_sales,

        SUM(total_profit) AS total_profit

    FROM rfm_classified

    GROUP BY
        Segment,
        rfm_segment
)

SELECT
    Segment,
    rfm_segment,

    total_customers,

    ROUND(
        total_customers * 100.0 /
        SUM(total_customers) OVER (
            PARTITION BY rfm_segment
        ),
        2
    ) AS pct_of_rfm_customers,

    total_orders,
    units_purchased,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(
        total_sales * 100.0 /
        SUM(total_sales) OVER (
            PARTITION BY rfm_segment
        ),
        2
    ) AS pct_of_rfm_sales,

    ROUND(total_profit, 2) AS total_profit,

    ROUND(
        total_profit * 100.0 /
        SUM(total_profit) OVER (
            PARTITION BY rfm_segment
        ),
        2
    ) AS pct_of_rfm_profit,

    ROUND(
        total_profit * 100.0 /
        NULLIF(total_sales, 0),
        2
    ) AS profit_margin_pct

FROM segment_rfm_summary

ORDER BY

    CASE rfm_segment
        WHEN 'Champions' THEN 1
        WHEN 'Loyal Customers' THEN 2
        WHEN 'Potential Loyalists' THEN 3
        WHEN 'New Customers' THEN 4
        WHEN 'Need Attention' THEN 5
        WHEN 'At Risk' THEN 6
        WHEN 'Hibernating' THEN 7
        ELSE 8
    END,

    total_sales DESC;
    
-- ============================================================
-- STEP 8.65
-- AT-RISK & HIBERNATING CUSTOMER RECOVERY OPPORTUNITY
--
-- Business Question:
-- Which historically valuable customers are becoming inactive
-- and represent the strongest reactivation opportunities?
--
-- SQL Concepts:
-- CTE
-- NTILE()
-- CASE
-- Window Functions
-- RFM
-- Ranking
-- Customer Retention Analysis
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS units_purchased,

        ROUND(SUM(s.Sales), 2) AS monetary_value,

        ROUND(SUM(s.Profit), 2) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

rfm_metrics AS
(
    SELECT
        cb.*,

        DATEDIFF(
            ad.max_order_date,
            cb.last_order_date
        ) AS recency_days

    FROM customer_base cb

    CROSS JOIN analysis_date ad
),

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),

rfm_classified AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 4
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score = 1
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score BETWEEN 2 AND 3
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 4
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score BETWEEN 2 AND 3
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM rfm_scores
),

recovery_candidates AS
(
    SELECT
        *,

        ROUND(
            total_profit * 100.0 /
            NULLIF(monetary_value, 0),
            2
        ) AS historical_profit_margin_pct,

        RANK() OVER (
            ORDER BY monetary_value DESC
        ) AS recovery_value_rank

    FROM rfm_classified

    WHERE rfm_segment IN (
        'At Risk',
        'Hibernating'
    )
)

SELECT
    recovery_value_rank,

    Customer_ID,
    Customer_Name,
    Segment,
    Region,

    rfm_segment,

    last_order_date,
    recency_days,

    frequency AS historical_orders,
    units_purchased AS historical_units,

    ROUND(
        monetary_value,
        2
    ) AS historical_sales,

    ROUND(
        total_profit,
        2
    ) AS historical_profit,

    historical_profit_margin_pct,

    r_score,
    f_score,
    m_score,

    CONCAT(
        r_score,
        f_score,
        m_score
    ) AS rfm_score,

    CASE
        WHEN m_score >= 4
             AND f_score >= 4
            THEN 'Priority 1 - High Value'

        WHEN m_score >= 4
            THEN 'Priority 2 - High Spend'

        WHEN f_score >= 3
            THEN 'Priority 3 - Frequent Buyer'

        ELSE 'Priority 4 - Standard'
    END AS recovery_priority

FROM recovery_candidates

ORDER BY
    recovery_value_rank;
    
    
-- ============================================================
-- STEP 8.66
-- CUSTOMER RECOVERY OPPORTUNITY KPI SUMMARY
--
-- Business Question:
-- How large is the customer recovery opportunity,
-- and what historical business value is associated
-- with At Risk and Hibernating customers?
--
-- SQL Concepts:
-- CTE
-- RFM
-- CASE
-- Aggregation
-- KPI Calculation
-- Contribution Analysis
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS units_purchased,

        ROUND(SUM(s.Sales), 2) AS monetary_value,

        ROUND(SUM(s.Profit), 2) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

rfm_metrics AS
(
    SELECT
        cb.*,

        DATEDIFF(
            ad.max_order_date,
            cb.last_order_date
        ) AS recency_days

    FROM customer_base cb

    CROSS JOIN analysis_date ad
),

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),

rfm_classified AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 4
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score = 1
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score BETWEEN 2 AND 3
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 4
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score BETWEEN 2 AND 3
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM rfm_scores
),

recovery_base AS
(
    SELECT
        *
    FROM rfm_classified

    WHERE rfm_segment IN (
        'At Risk',
        'Hibernating'
    )
),

recovery_summary AS
(
    SELECT
        rfm_segment,

        COUNT(*) AS recovery_customers,

        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (),
            2
        ) AS pct_of_recovery_customers,

        SUM(frequency) AS historical_orders,

        SUM(units_purchased) AS historical_units,

        ROUND(
            SUM(monetary_value),
            2
        ) AS historical_sales,

        ROUND(
            SUM(total_profit),
            2
        ) AS historical_profit,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM recovery_base

    GROUP BY
        rfm_segment
)

SELECT
    rfm_segment,

    recovery_customers,

    pct_of_recovery_customers,

    historical_orders,

    historical_units,

    historical_sales,

    ROUND(
        historical_sales * 100.0 /
        SUM(historical_sales) OVER (),
        2
    ) AS pct_of_recovery_sales,

    historical_profit,

    ROUND(
        historical_profit * 100.0 /
        SUM(historical_profit) OVER (),
        2
    ) AS pct_of_recovery_profit,

    ROUND(
        historical_profit * 100.0 /
        NULLIF(historical_sales, 0),
        2
    ) AS historical_profit_margin_pct,

    avg_recency_days

FROM recovery_summary

ORDER BY
    CASE rfm_segment
        WHEN 'At Risk' THEN 1
        WHEN 'Hibernating' THEN 2
        ELSE 3
    END;
    

-- ============================================================
-- STEP 8.67
-- CUSTOMER RECOVERY PRIORITY MATRIX
--
-- Business Question:
-- How many inactive customers belong to each recovery
-- priority group, and what historical business value
-- does each priority represent?
--
-- Priority Logic:
-- Priority 1 = Highest-value recovery opportunity
-- Priority 2 = High-value inactive customer
-- Priority 3 = Frequent historical buyer
-- Priority 4 = Standard recovery candidate
--
-- SQL Concepts:
-- CTE
-- RFM
-- CASE
-- Window Functions
-- Aggregation
-- Contribution Analysis
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        ROUND(SUM(s.Sales), 2) AS monetary_value,

        ROUND(SUM(s.Profit), 2) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

rfm_metrics AS
(
    SELECT
        cb.*,

        DATEDIFF(
            ad.max_order_date,
            cb.last_order_date
        ) AS recency_days

    FROM customer_base cb
    CROSS JOIN analysis_date ad
),

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),

rfm_classified AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4 AND f_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3 AND f_score >= 4
                THEN 'Loyal Customers'

            WHEN r_score >= 4 AND f_score BETWEEN 2 AND 3
                THEN 'Potential Loyalists'

            WHEN r_score = 5 AND f_score = 1
                THEN 'New Customers'

            WHEN r_score = 3 AND f_score BETWEEN 2 AND 3
                THEN 'Need Attention'

            WHEN r_score <= 2 AND f_score >= 4
                THEN 'At Risk'

            WHEN r_score <= 2 AND f_score BETWEEN 2 AND 3
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM rfm_scores
),

recovery_candidates AS
(
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY
                monetary_value DESC,
                frequency DESC,
                recency_days ASC
        ) AS recovery_value_rank

    FROM rfm_classified

    WHERE rfm_segment IN (
        'At Risk',
        'Hibernating'
    )
),

priority_customers AS
(
    SELECT
        *,

        CASE
            WHEN recovery_value_rank <= 25
                THEN 'Priority 1 - Highest Value'

            WHEN recovery_value_rank <= 75
                THEN 'Priority 2 - High Value'

            WHEN frequency >= 12
                THEN 'Priority 3 - Frequent Buyer'

            ELSE 'Priority 4 - Standard'
        END AS recovery_priority

    FROM recovery_candidates
),

priority_summary AS
(
    SELECT
        recovery_priority,

        COUNT(*) AS total_customers,

        ROUND(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER (),
            2
        ) AS pct_of_recovery_customers,

        SUM(frequency) AS historical_orders,

        ROUND(
            SUM(monetary_value),
            2
        ) AS historical_sales,

        ROUND(
            SUM(total_profit),
            2
        ) AS historical_profit,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM priority_customers

    GROUP BY recovery_priority
)

SELECT
    recovery_priority,

    total_customers,

    pct_of_recovery_customers,

    historical_orders,

    historical_sales,

    ROUND(
        historical_sales * 100.0 /
        SUM(historical_sales) OVER (),
        2
    ) AS pct_of_recovery_sales,

    historical_profit,

    ROUND(
        historical_profit * 100.0 /
        SUM(historical_profit) OVER (),
        2
    ) AS pct_of_recovery_profit,

    avg_recency_days

FROM priority_summary

ORDER BY
    CASE recovery_priority
        WHEN 'Priority 1 - Highest Value' THEN 1
        WHEN 'Priority 2 - High Value' THEN 2
        WHEN 'Priority 3 - Frequent Buyer' THEN 3
        WHEN 'Priority 4 - Standard' THEN 4
        ELSE 5
    END;
    
    
-- ============================================================
-- STEP 8.68
-- CUSTOMER RECOVERY PRIORITY BY REGION
-- ============================================================
--
-- Business Question:
-- Which regions contain the largest customer recovery
-- opportunities and highest historical customer value?
--
-- Recovery Population:
-- At Risk + Hibernating customers
--
-- SQL Concepts:
-- CTE
-- JOIN
-- Aggregation
-- RFM Analysis
-- NTILE()
-- ROW_NUMBER()
-- CASE
-- Window Functions
-- Regional Analysis
-- ============================================================


-- ============================================================
-- 1. ANALYSIS DATE
-- Use the latest sales order date as the reference date
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date

    FROM sales_dedup

    WHERE Order_Date IS NOT NULL
),


-- ============================================================
-- 2. CUSTOMER-LEVEL PERFORMANCE
-- ============================================================

customer_base AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS units_purchased,

        ROUND(
            SUM(s.Sales),
            2
        ) AS monetary_value,

        ROUND(
            SUM(s.Profit),
            2
        ) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),


-- ============================================================
-- 3. CALCULATE RECENCY
-- ============================================================

rfm_metrics AS
(
    SELECT
        cb.*,

        DATEDIFF(
            ad.max_order_date,
            cb.last_order_date
        ) AS recency_days

    FROM customer_base cb

    CROSS JOIN analysis_date ad
),


-- ============================================================
-- 4. CREATE RFM SCORES
--
-- Recency:
-- Lower number of days = better customer
--
-- Frequency:
-- More orders = better customer
--
-- Monetary:
-- Higher historical sales = better customer
-- ============================================================

rfm_scores AS
(
    SELECT
        *,

        NTILE(5) OVER
        (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER
        (
            ORDER BY frequency ASC
        ) AS f_score,

        NTILE(5) OVER
        (
            ORDER BY monetary_value ASC
        ) AS m_score

    FROM rfm_metrics
),


-- ============================================================
-- 5. CLASSIFY CUSTOMERS INTO RFM SEGMENTS
-- ============================================================

rfm_classified AS
(
    SELECT
        *,

        CASE

            WHEN r_score >= 4
                 AND f_score >= 4
            THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 4
            THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score = 1
            THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score BETWEEN 2 AND 3
            THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 4
            THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score BETWEEN 2 AND 3
            THEN 'Hibernating'

            ELSE 'Lost Customers'

        END AS rfm_segment

    FROM rfm_scores
),


-- ============================================================
-- 6. SELECT RECOVERY CANDIDATES
--
-- Only:
-- At Risk
-- Hibernating
--
-- Rank higher historical-value customers first
-- ============================================================

recovery_candidates AS
(
    SELECT
        *,

        ROW_NUMBER() OVER
        (
            ORDER BY
                monetary_value DESC,
                frequency DESC,
                recency_days ASC
        ) AS recovery_value_rank

    FROM rfm_classified

    WHERE rfm_segment IN
    (
        'At Risk',
        'Hibernating'
    )
),


-- ============================================================
-- 7. ASSIGN RECOVERY PRIORITY
-- ============================================================

priority_customers AS
(
    SELECT
        *,

        CASE

            WHEN recovery_value_rank <= 25
            THEN 'Priority 1 - Highest Value'

            WHEN recovery_value_rank <= 75
            THEN 'Priority 2 - High Value'

            WHEN frequency >= 12
            THEN 'Priority 3 - Frequent Buyer'

            ELSE 'Priority 4 - Standard'

        END AS recovery_priority

    FROM recovery_candidates
)


-- ============================================================
-- 8. FINAL REGIONAL RECOVERY ANALYSIS
-- ============================================================

SELECT
    Region,

    recovery_priority,

    COUNT(*) AS recovery_customers,


    -- Percentage of customers within each priority group

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER
        (
            PARTITION BY recovery_priority
        ),
        2
    ) AS pct_of_priority_customers,


    -- Historical number of orders

    SUM(frequency) AS historical_orders,


    -- Historical sales

    ROUND(
        SUM(monetary_value),
        2
    ) AS historical_sales,


    -- Percentage of sales within each priority group

    ROUND(
        SUM(monetary_value) * 100.0 /
        NULLIF(
            SUM(SUM(monetary_value)) OVER
            (
                PARTITION BY recovery_priority
            ),
            0
        ),
        2
    ) AS pct_of_priority_sales,


    -- Historical profit

    ROUND(
        SUM(total_profit),
        2
    ) AS historical_profit,


    -- Historical profit margin

    ROUND(
        SUM(total_profit) * 100.0 /
        NULLIF(
            SUM(monetary_value),
            0
        ),
        2
    ) AS historical_profit_margin_pct,


    -- Average inactivity

    ROUND(
        AVG(recency_days),
        2
    ) AS avg_recency_days


FROM priority_customers


GROUP BY
    Region,
    recovery_priority


ORDER BY

    CASE recovery_priority

        WHEN 'Priority 1 - Highest Value'
        THEN 1

        WHEN 'Priority 2 - High Value'
        THEN 2

        WHEN 'Priority 3 - Frequent Buyer'
        THEN 3

        WHEN 'Priority 4 - Standard'
        THEN 4

        ELSE 5

    END,

    historical_sales DESC;
    

-- ============================================================
-- STEP 8.69
-- CUSTOMER RECOVERY PRIORITY BY CUSTOMER SEGMENT
-- ============================================================
--
-- Business Question:
-- Which customer segments contain the largest recovery
-- opportunities and highest historical customer value?
--
-- IMPORTANT:
-- Execute this COMPLETE query from WITH to the final ;
-- Do NOT execute only the final SELECT.
-- ============================================================


WITH analysis_date AS
(
    -- --------------------------------------------------------
    -- 1. Find latest valid order date
    -- --------------------------------------------------------

    SELECT
        MAX(Order_Date) AS max_order_date

    FROM sales_dedup

    WHERE Order_Date IS NOT NULL
),


customer_base AS
(
    -- --------------------------------------------------------
    -- 2. Build customer-level historical performance
    -- --------------------------------------------------------

    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS units_purchased,

        ROUND(
            SUM(s.Sales),
            2
        ) AS monetary_value,

        ROUND(
            SUM(s.Profit),
            2
        ) AS total_profit

    FROM sales_dedup s

    INNER JOIN customers_clean c
        ON s.Customer_ID = c.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),


rfm_metrics AS
(
    -- --------------------------------------------------------
    -- 3. Calculate customer recency
    -- --------------------------------------------------------

    SELECT
        cb.*,

        DATEDIFF(
            ad.max_order_date,
            cb.last_order_date
        ) AS recency_days

    FROM customer_base cb

    CROSS JOIN analysis_date ad
),


rfm_scores AS
(
    -- --------------------------------------------------------
    -- 4. Calculate RFM scores
    -- --------------------------------------------------------

    SELECT
        rm.*,

        NTILE(5) OVER
        (
            ORDER BY rm.recency_days DESC
        ) AS r_score,

        NTILE(5) OVER
        (
            ORDER BY rm.frequency ASC
        ) AS f_score,

        NTILE(5) OVER
        (
            ORDER BY rm.monetary_value ASC
        ) AS m_score

    FROM rfm_metrics rm
),


rfm_classified AS
(
    -- --------------------------------------------------------
    -- 5. Create RFM customer segments
    -- --------------------------------------------------------

    SELECT
        rs.*,

        CASE

            WHEN rs.r_score >= 4
                 AND rs.f_score >= 4
            THEN 'Champions'

            WHEN rs.r_score >= 3
                 AND rs.f_score >= 4
            THEN 'Loyal Customers'

            WHEN rs.r_score >= 4
                 AND rs.f_score BETWEEN 2 AND 3
            THEN 'Potential Loyalists'

            WHEN rs.r_score = 5
                 AND rs.f_score = 1
            THEN 'New Customers'

            WHEN rs.r_score = 3
                 AND rs.f_score BETWEEN 2 AND 3
            THEN 'Need Attention'

            WHEN rs.r_score <= 2
                 AND rs.f_score >= 4
            THEN 'At Risk'

            WHEN rs.r_score <= 2
                 AND rs.f_score BETWEEN 2 AND 3
            THEN 'Hibernating'

            ELSE 'Lost Customers'

        END AS rfm_segment

    FROM rfm_scores rs
),


recovery_candidates AS
(
    -- --------------------------------------------------------
    -- 6. Keep only customers requiring recovery
    -- --------------------------------------------------------

    SELECT
        rc.*,

        ROW_NUMBER() OVER
        (
            ORDER BY
                rc.monetary_value DESC,
                rc.frequency DESC,
                rc.recency_days ASC
        ) AS recovery_value_rank

    FROM rfm_classified rc

    WHERE rc.rfm_segment IN
    (
        'At Risk',
        'Hibernating'
    )
),


priority_customers AS
(
    -- --------------------------------------------------------
    -- 7. Assign recovery priority
    -- --------------------------------------------------------

    SELECT
        rc.*,

        CASE

            WHEN rc.recovery_value_rank <= 25
            THEN 'Priority 1 - Highest Value'

            WHEN rc.recovery_value_rank <= 75
            THEN 'Priority 2 - High Value'

            WHEN rc.frequency >= 12
            THEN 'Priority 3 - Frequent Buyer'

            ELSE 'Priority 4 - Standard'

        END AS recovery_priority

    FROM recovery_candidates rc
),


segment_recovery_summary AS
(
    -- --------------------------------------------------------
    -- 8. Aggregate recovery customers by
    --    Customer Segment + Recovery Priority
    -- --------------------------------------------------------

    SELECT
        Segment,
        recovery_priority,

        COUNT(*) AS recovery_customers,

        SUM(frequency) AS historical_orders,

        SUM(units_purchased) AS historical_units,

        ROUND(
            SUM(monetary_value),
            2
        ) AS historical_sales,

        ROUND(
            SUM(total_profit),
            2
        ) AS historical_profit,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM priority_customers

    GROUP BY
        Segment,
        recovery_priority
)


-- ============================================================
-- 9. FINAL RESULT
-- ============================================================

SELECT
    Segment,

    recovery_priority,

    recovery_customers,


    -- Percentage of customers within each recovery priority

    ROUND(
        recovery_customers * 100.0 /
        NULLIF(
            SUM(recovery_customers) OVER
            (
                PARTITION BY recovery_priority
            ),
            0
        ),
        2
    ) AS pct_of_priority_customers,


    historical_orders,

    historical_units,

    historical_sales,


    -- Historical sales contribution within priority

    ROUND(
        historical_sales * 100.0 /
        NULLIF(
            SUM(historical_sales) OVER
            (
                PARTITION BY recovery_priority
            ),
            0
        ),
        2
    ) AS pct_of_priority_sales,


    historical_profit,


    -- Historical profit margin

    ROUND(
        historical_profit * 100.0 /
        NULLIF(
            historical_sales,
            0
        ),
        2
    ) AS historical_profit_margin_pct,


    avg_recency_days

FROM segment_recovery_summary


ORDER BY

    CASE recovery_priority

        WHEN 'Priority 1 - Highest Value'
            THEN 1

        WHEN 'Priority 2 - High Value'
            THEN 2

        WHEN 'Priority 3 - Frequent Buyer'
            THEN 3

        WHEN 'Priority 4 - Standard'
            THEN 4

        ELSE 5

    END,

    historical_sales DESC;


-- ============================================================
-- STEP 8.70
-- CUSTOMER RECOVERY PRIORITY BY REGION + SEGMENT
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        DATEDIFF(
            (SELECT max_order_date FROM analysis_date),
            MAX(s.Order_Date)
        ) AS recency_days,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS historical_units,

        ROUND(SUM(s.Sales), 2) AS historical_sales

    FROM customers_clean c

    INNER JOIN sales_dedup s
        ON c.Customer_ID = s.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY historical_sales
        ) AS m_score

    FROM customer_performance
),

rfm_customers AS
(
    SELECT
        *,

        CASE

            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score >= 2
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score >= 2
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Lost Customers'

        END AS rfm_segment

    FROM customer_scores
),

recovery_candidates AS
(
    SELECT
        *
    FROM rfm_customers

    WHERE rfm_segment IN (
        'At Risk',
        'Hibernating'
    )
),

ranked_recovery AS
(
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY
                historical_sales DESC,
                frequency DESC
        ) AS recovery_value_rank

    FROM recovery_candidates
),

priority_customers AS
(
    SELECT
        *,

        CASE

            WHEN recovery_value_rank <= 25
                THEN 'Priority 1 - Highest Value'

            WHEN recovery_value_rank <= 75
                THEN 'Priority 2 - High Value'

            WHEN frequency >= 10
                THEN 'Priority 3 - Frequent Buyer'

            ELSE 'Priority 4 - Standard'

        END AS recovery_priority

    FROM ranked_recovery
),

region_segment_summary AS
(
    SELECT
        Region,
        Segment,
        recovery_priority,

        COUNT(*) AS recovery_customers,

        SUM(frequency) AS historical_orders,

        SUM(historical_units) AS historical_units,

        ROUND(
            SUM(historical_sales),
            2
        ) AS historical_sales,

        ROUND(
            AVG(historical_sales),
            2
        ) AS avg_sales_per_customer,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM priority_customers

    GROUP BY
        Region,
        Segment,
        recovery_priority
),

priority_totals AS
(
    SELECT
        recovery_priority,

        SUM(recovery_customers) AS priority_customers,

        SUM(historical_sales) AS priority_sales

    FROM region_segment_summary

    GROUP BY
        recovery_priority
)

SELECT
    rss.Region,
    rss.Segment,
    rss.recovery_priority,

    rss.recovery_customers,

    ROUND(
        rss.recovery_customers * 100.0 /
        NULLIF(pt.priority_customers, 0),
        2
    ) AS pct_of_priority_customers,

    rss.historical_orders,

    rss.historical_units,

    rss.historical_sales,

    ROUND(
        rss.historical_sales * 100.0 /
        NULLIF(pt.priority_sales, 0),
        2
    ) AS pct_of_priority_sales,

    rss.avg_sales_per_customer,

    rss.avg_recency_days

FROM region_segment_summary rss

INNER JOIN priority_totals pt
    ON rss.recovery_priority = pt.recovery_priority

ORDER BY

    CASE rss.recovery_priority

        WHEN 'Priority 1 - Highest Value' THEN 1
        WHEN 'Priority 2 - High Value' THEN 2
        WHEN 'Priority 3 - Frequent Buyer' THEN 3
        WHEN 'Priority 4 - Standard' THEN 4

        ELSE 5

    END,

    rss.historical_sales DESC;
    

-- ============================================================
-- STEP 8.71
-- CUSTOMER RECOVERY CAMPAIGN ACTION PLAN
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        DATEDIFF(
            (SELECT max_order_date FROM analysis_date),
            MAX(s.Order_Date)
        ) AS recency_days,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS historical_units,

        ROUND(SUM(s.Sales), 2) AS historical_sales

    FROM customers_clean c

    INNER JOIN sales_dedup s
        ON c.Customer_ID = s.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY historical_sales
        ) AS m_score

    FROM customer_performance
),

rfm_customers AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score >= 2
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score >= 2
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM customer_scores
),

recovery_candidates AS
(
    SELECT
        *
    FROM rfm_customers

    WHERE rfm_segment IN (
        'At Risk',
        'Hibernating'
    )
),

ranked_recovery AS
(
    SELECT
        *,

        ROW_NUMBER() OVER (
            ORDER BY
                historical_sales DESC,
                frequency DESC
        ) AS recovery_value_rank

    FROM recovery_candidates
),

priority_customers AS
(
    SELECT
        *,

        CASE
            WHEN recovery_value_rank <= 25
                THEN 'Priority 1 - Highest Value'

            WHEN recovery_value_rank <= 75
                THEN 'Priority 2 - High Value'

            WHEN frequency >= 10
                THEN 'Priority 3 - Frequent Buyer'

            ELSE 'Priority 4 - Standard'
        END AS recovery_priority

    FROM ranked_recovery
),

campaign_summary AS
(
    SELECT
        recovery_priority,

        COUNT(*) AS recovery_customers,

        SUM(frequency) AS historical_orders,

        SUM(historical_units) AS historical_units,

        ROUND(
            SUM(historical_sales),
            2
        ) AS historical_sales,

        ROUND(
            AVG(historical_sales),
            2
        ) AS avg_sales_per_customer,

        ROUND(
            AVG(frequency),
            2
        ) AS avg_orders_per_customer,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM priority_customers

    GROUP BY
        recovery_priority
),

campaign_totals AS
(
    SELECT
        SUM(recovery_customers) AS total_recovery_customers,
        SUM(historical_sales) AS total_recovery_sales

    FROM campaign_summary
)

SELECT
    cs.recovery_priority,

    cs.recovery_customers,

    ROUND(
        cs.recovery_customers * 100.0 /
        NULLIF(ct.total_recovery_customers, 0),
        2
    ) AS pct_of_recovery_customers,

    cs.historical_orders,

    cs.historical_units,

    cs.historical_sales,

    ROUND(
        cs.historical_sales * 100.0 /
        NULLIF(ct.total_recovery_sales, 0),
        2
    ) AS pct_of_recovery_sales,

    cs.avg_sales_per_customer,

    cs.avg_orders_per_customer,

    cs.avg_recency_days,

    CASE cs.recovery_priority

        WHEN 'Priority 1 - Highest Value'
            THEN 'Immediate Personal Outreach'

        WHEN 'Priority 2 - High Value'
            THEN 'High-Value Win-Back Campaign'

        WHEN 'Priority 3 - Frequent Buyer'
            THEN 'Loyalty / Reactivation Offer'

        WHEN 'Priority 4 - Standard'
            THEN 'Automated Re-Engagement'

        ELSE 'Review Customer'

    END AS recommended_action

FROM campaign_summary cs

CROSS JOIN campaign_totals ct

ORDER BY
    CASE cs.recovery_priority
        WHEN 'Priority 1 - Highest Value' THEN 1
        WHEN 'Priority 2 - High Value' THEN 2
        WHEN 'Priority 3 - Frequent Buyer' THEN 3
        WHEN 'Priority 4 - Standard' THEN 4
        ELSE 5
    END;
    

-- ============================================================
-- STEP 8.72
-- RECOVERY OPPORTUNITY BY RFM SEGMENT
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        DATEDIFF(
            (SELECT max_order_date FROM analysis_date),
            MAX(s.Order_Date)
        ) AS recency_days,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS historical_units,

        ROUND(SUM(s.Sales), 2) AS historical_sales

    FROM customers_clean c

    INNER JOIN sales_dedup s
        ON c.Customer_ID = s.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY historical_sales
        ) AS m_score

    FROM customer_performance
),

rfm_customers AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score >= 2
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score >= 2
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM customer_scores
),

recovery_customers AS
(
    SELECT
        *
    FROM rfm_customers

    WHERE rfm_segment IN
    (
        'At Risk',
        'Hibernating'
    )
),

recovery_summary AS
(
    SELECT
        rfm_segment,

        COUNT(*) AS recovery_customers,

        SUM(frequency) AS historical_orders,

        SUM(historical_units) AS historical_units,

        ROUND(
            SUM(historical_sales),
            2
        ) AS historical_sales,

        ROUND(
            AVG(historical_sales),
            2
        ) AS avg_sales_per_customer,

        ROUND(
            AVG(frequency),
            2
        ) AS avg_orders_per_customer,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM recovery_customers

    GROUP BY
        rfm_segment
),

recovery_totals AS
(
    SELECT
        SUM(recovery_customers) AS total_recovery_customers,
        SUM(historical_sales) AS total_recovery_sales

    FROM recovery_summary
)

SELECT
    rs.rfm_segment,

    rs.recovery_customers,

    ROUND(
        rs.recovery_customers * 100.0 /
        NULLIF(rt.total_recovery_customers, 0),
        2
    ) AS pct_of_recovery_customers,

    rs.historical_orders,

    rs.historical_units,

    rs.historical_sales,

    ROUND(
        rs.historical_sales * 100.0 /
        NULLIF(rt.total_recovery_sales, 0),
        2
    ) AS pct_of_recovery_sales,

    rs.avg_sales_per_customer,

    rs.avg_orders_per_customer,

    rs.avg_recency_days

FROM recovery_summary rs

CROSS JOIN recovery_totals rt

ORDER BY
    CASE rs.rfm_segment
        WHEN 'At Risk' THEN 1
        WHEN 'Hibernating' THEN 2
        ELSE 3
    END;
    

-- ============================================================
-- STEP 8.73
-- CUSTOMER RECOVERY OPPORTUNITY BY REGION
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        DATEDIFF(
            (SELECT max_order_date FROM analysis_date),
            MAX(s.Order_Date)
        ) AS recency_days,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS historical_units,

        ROUND(
            SUM(s.Sales),
            2
        ) AS historical_sales

    FROM customers_clean c

    INNER JOIN sales_dedup s
        ON c.Customer_ID = s.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY historical_sales
        ) AS m_score

    FROM customer_performance
),

rfm_customers AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score >= 2
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score >= 2
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM customer_scores
),

recovery_customers AS
(
    SELECT
        *
    FROM rfm_customers

    WHERE rfm_segment IN
    (
        'At Risk',
        'Hibernating'
    )
),

region_recovery AS
(
    SELECT
        Region,

        COUNT(*) AS recovery_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'At Risk'
                THEN 1
                ELSE 0
            END
        ) AS at_risk_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'Hibernating'
                THEN 1
                ELSE 0
            END
        ) AS hibernating_customers,

        SUM(frequency) AS historical_orders,

        SUM(historical_units) AS historical_units,

        ROUND(
            SUM(historical_sales),
            2
        ) AS historical_sales,

        ROUND(
            AVG(historical_sales),
            2
        ) AS avg_sales_per_customer,

        ROUND(
            AVG(frequency),
            2
        ) AS avg_orders_per_customer,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM recovery_customers

    GROUP BY
        Region
),

recovery_totals AS
(
    SELECT
        SUM(recovery_customers)
            AS total_recovery_customers,

        SUM(historical_sales)
            AS total_recovery_sales

    FROM region_recovery
)

SELECT
    rr.Region,

    rr.recovery_customers,

    ROUND(
        rr.recovery_customers * 100.0 /
        NULLIF(rt.total_recovery_customers, 0),
        2
    ) AS pct_of_recovery_customers,

    rr.at_risk_customers,

    rr.hibernating_customers,

    rr.historical_orders,

    rr.historical_units,

    rr.historical_sales,

    ROUND(
        rr.historical_sales * 100.0 /
        NULLIF(rt.total_recovery_sales, 0),
        2
    ) AS pct_of_recovery_sales,

    rr.avg_sales_per_customer,

    rr.avg_orders_per_customer,

    rr.avg_recency_days

FROM region_recovery rr

CROSS JOIN recovery_totals rt

ORDER BY
    rr.historical_sales DESC;
    

-- ============================================================
-- STEP 8.74
-- CUSTOMER RECOVERY OPPORTUNITY BY CUSTOMER SEGMENT
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        DATEDIFF(
            (SELECT max_order_date FROM analysis_date),
            MAX(s.Order_Date)
        ) AS recency_days,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS historical_units,

        ROUND(
            SUM(s.Sales),
            2
        ) AS historical_sales

    FROM customers_clean c

    INNER JOIN sales_dedup s
        ON c.Customer_ID = s.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY historical_sales
        ) AS m_score

    FROM customer_performance
),

rfm_customers AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score >= 2
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score >= 2
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM customer_scores
),

recovery_customers AS
(
    SELECT
        *
    FROM rfm_customers

    WHERE rfm_segment IN
    (
        'At Risk',
        'Hibernating'
    )
),

segment_recovery AS
(
    SELECT
        Segment,

        COUNT(*) AS recovery_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'At Risk'
                THEN 1
                ELSE 0
            END
        ) AS at_risk_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'Hibernating'
                THEN 1
                ELSE 0
            END
        ) AS hibernating_customers,

        SUM(frequency) AS historical_orders,

        SUM(historical_units) AS historical_units,

        ROUND(
            SUM(historical_sales),
            2
        ) AS historical_sales,

        ROUND(
            AVG(historical_sales),
            2
        ) AS avg_sales_per_customer,

        ROUND(
            AVG(frequency),
            2
        ) AS avg_orders_per_customer,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM recovery_customers

    GROUP BY
        Segment
),

recovery_totals AS
(
    SELECT
        SUM(recovery_customers)
            AS total_recovery_customers,

        SUM(historical_sales)
            AS total_recovery_sales

    FROM segment_recovery
)

SELECT
    sr.Segment,

    sr.recovery_customers,

    ROUND(
        sr.recovery_customers * 100.0 /
        NULLIF(rt.total_recovery_customers, 0),
        2
    ) AS pct_of_recovery_customers,

    sr.at_risk_customers,

    sr.hibernating_customers,

    sr.historical_orders,

    sr.historical_units,

    sr.historical_sales,

    ROUND(
        sr.historical_sales * 100.0 /
        NULLIF(rt.total_recovery_sales, 0),
        2
    ) AS pct_of_recovery_sales,

    sr.avg_sales_per_customer,

    sr.avg_orders_per_customer,

    sr.avg_recency_days

FROM segment_recovery sr

CROSS JOIN recovery_totals rt

ORDER BY
    sr.historical_sales DESC;
    

-- ============================================================
-- STEP 8.75
-- RECOVERY OPPORTUNITY BY REGION + CUSTOMER SEGMENT
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        DATEDIFF(
            (SELECT max_order_date FROM analysis_date),
            MAX(s.Order_Date)
        ) AS recency_days,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS historical_units,

        ROUND(SUM(s.Sales), 2) AS historical_sales

    FROM customers_clean c

    INNER JOIN sales_dedup s
        ON c.Customer_ID = s.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY historical_sales
        ) AS m_score

    FROM customer_performance
),

rfm_customers AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score >= 2
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score >= 2
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM customer_scores
),

recovery_customers AS
(
    SELECT
        *
    FROM rfm_customers

    WHERE rfm_segment IN
    (
        'At Risk',
        'Hibernating'
    )
),

region_segment_recovery AS
(
    SELECT
        Region,
        Segment,

        COUNT(*) AS recovery_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'At Risk'
                THEN 1
                ELSE 0
            END
        ) AS at_risk_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'Hibernating'
                THEN 1
                ELSE 0
            END
        ) AS hibernating_customers,

        SUM(frequency) AS historical_orders,

        SUM(historical_units) AS historical_units,

        ROUND(
            SUM(historical_sales),
            2
        ) AS historical_sales,

        ROUND(
            AVG(historical_sales),
            2
        ) AS avg_sales_per_customer,

        ROUND(
            AVG(frequency),
            2
        ) AS avg_orders_per_customer,

        ROUND(
            AVG(recency_days),
            2
        ) AS avg_recency_days

    FROM recovery_customers

    GROUP BY
        Region,
        Segment
),

recovery_totals AS
(
    SELECT
        SUM(recovery_customers)
            AS total_recovery_customers,

        SUM(historical_sales)
            AS total_recovery_sales

    FROM region_segment_recovery
)

SELECT
    rsr.Region,

    rsr.Segment,

    rsr.recovery_customers,

    ROUND(
        rsr.recovery_customers * 100.0 /
        NULLIF(rt.total_recovery_customers, 0),
        2
    ) AS pct_of_recovery_customers,

    rsr.at_risk_customers,

    rsr.hibernating_customers,

    rsr.historical_orders,

    rsr.historical_units,

    rsr.historical_sales,

    ROUND(
        rsr.historical_sales * 100.0 /
        NULLIF(rt.total_recovery_sales, 0),
        2
    ) AS pct_of_recovery_sales,

    rsr.avg_sales_per_customer,

    rsr.avg_orders_per_customer,

    rsr.avg_recency_days

FROM region_segment_recovery rsr

CROSS JOIN recovery_totals rt

ORDER BY
    rsr.historical_sales DESC;
    
    
-- ============================================================
-- STEP 8.76
-- RECOVERY ACTION MATRIX
-- Region + Segment + Business Priority
-- ============================================================

WITH analysis_date AS
(
    SELECT
        MAX(Order_Date) AS max_order_date
    FROM sales_dedup
    WHERE Order_Date IS NOT NULL
),

customer_performance AS
(
    SELECT
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region,

        MAX(s.Order_Date) AS last_order_date,

        DATEDIFF(
            (SELECT max_order_date FROM analysis_date),
            MAX(s.Order_Date)
        ) AS recency_days,

        COUNT(DISTINCT s.Order_ID) AS frequency,

        SUM(s.Quantity) AS historical_units,

        ROUND(SUM(s.Sales), 2) AS historical_sales

    FROM customers_clean c

    INNER JOIN sales_dedup s
        ON c.Customer_ID = s.Customer_ID

    WHERE s.Order_Date IS NOT NULL

    GROUP BY
        c.Customer_ID,
        c.Customer_Name,
        c.Segment,
        c.Region
),

customer_scores AS
(
    SELECT
        *,

        NTILE(5) OVER (
            ORDER BY recency_days DESC
        ) AS r_score,

        NTILE(5) OVER (
            ORDER BY frequency
        ) AS f_score,

        NTILE(5) OVER (
            ORDER BY historical_sales
        ) AS m_score

    FROM customer_performance
),

rfm_customers AS
(
    SELECT
        *,

        CASE
            WHEN r_score >= 4
                 AND f_score >= 4
                 AND m_score >= 4
                THEN 'Champions'

            WHEN r_score >= 3
                 AND f_score >= 3
                 AND m_score >= 3
                THEN 'Loyal Customers'

            WHEN r_score >= 4
                 AND f_score >= 2
                THEN 'Potential Loyalists'

            WHEN r_score = 5
                 AND f_score <= 2
                THEN 'New Customers'

            WHEN r_score = 3
                 AND f_score >= 2
                THEN 'Need Attention'

            WHEN r_score <= 2
                 AND f_score >= 3
                THEN 'At Risk'

            WHEN r_score <= 2
                 AND f_score <= 2
                THEN 'Hibernating'

            ELSE 'Lost Customers'
        END AS rfm_segment

    FROM customer_scores
),

recovery_customers AS
(
    SELECT
        *
    FROM rfm_customers
    WHERE rfm_segment IN ('At Risk', 'Hibernating')
),

region_segment_summary AS
(
    SELECT
        Region,
        Segment,

        COUNT(*) AS recovery_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'At Risk'
                THEN 1 ELSE 0
            END
        ) AS at_risk_customers,

        SUM(
            CASE
                WHEN rfm_segment = 'Hibernating'
                THEN 1 ELSE 0
            END
        ) AS hibernating_customers,

        SUM(frequency) AS historical_orders,

        SUM(historical_units) AS historical_units,

        ROUND(SUM(historical_sales), 2)
            AS historical_sales,

        ROUND(AVG(historical_sales), 2)
            AS avg_sales_per_customer,

        ROUND(AVG(frequency), 2)
            AS avg_orders_per_customer,

        ROUND(AVG(recency_days), 2)
            AS avg_recency_days

    FROM recovery_customers

    GROUP BY
        Region,
        Segment
),

benchmarks AS
(
    SELECT
        AVG(historical_sales)
            AS avg_group_sales,

        AVG(avg_sales_per_customer)
            AS avg_customer_value

    FROM region_segment_summary
),

action_matrix AS
(
    SELECT
        rss.*,

        CASE

            WHEN rss.historical_sales >= b.avg_group_sales
                 AND rss.avg_sales_per_customer >= b.avg_customer_value
            THEN 'Priority 1 - Personal Win-Back'

            WHEN rss.historical_sales >= b.avg_group_sales
            THEN 'Priority 2 - High Revenue Recovery'

            WHEN rss.avg_sales_per_customer >= b.avg_customer_value
            THEN 'Priority 3 - High Value Target'

            ELSE 'Priority 4 - Automated Recovery'

        END AS recovery_action

    FROM region_segment_summary rss

    CROSS JOIN benchmarks b
)

SELECT
    Region,
    Segment,

    recovery_customers,

    at_risk_customers,

    hibernating_customers,

    historical_orders,

    historical_units,

    historical_sales,

    avg_sales_per_customer,

    avg_orders_per_customer,

    avg_recency_days,

    recovery_action

FROM action_matrix

ORDER BY

    CASE recovery_action
        WHEN 'Priority 1 - Personal Win-Back' THEN 1
        WHEN 'Priority 2 - High Revenue Recovery' THEN 2
        WHEN 'Priority 3 - High Value Target' THEN 3
        WHEN 'Priority 4 - Automated Recovery' THEN 4
        ELSE 5
    END,

    historical_sales DESC;
    

