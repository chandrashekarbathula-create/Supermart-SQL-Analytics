-- ============================================================
-- SECTION 11
-- INDEXING & PERFORMANCE OPTIMIZATION
--
-- STEP 11.1
-- AUDIT EXISTING INDEXES
-- ============================================================

USE supermart_analytics;

SELECT
    TABLE_NAME,
    INDEX_NAME,
    NON_UNIQUE,
    SEQ_IN_INDEX,
    COLUMN_NAME,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'supermart_analytics'
  AND TABLE_NAME IN
  (
      'sales_dedup',
      'customers_clean',
      'products_dedup',
      'returns_valid'
  )
ORDER BY
    TABLE_NAME,
    INDEX_NAME,
    SEQ_IN_INDEX;
    

-- ============================================================
-- STEP 11.2
-- BASELINE QUERY PERFORMANCE / EXECUTION PLAN
-- DO NOT CREATE INDEXES YET
-- ============================================================

USE supermart_analytics;

EXPLAIN
SELECT
    Region,
    Segment,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    SUM(Quantity) AS Total_Units,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM vw_sales_detail
WHERE Region = 'West'
GROUP BY
    Region,
    Segment;