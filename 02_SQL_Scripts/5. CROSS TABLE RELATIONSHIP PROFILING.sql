-- ============================================================
-- STEP 5.5: CROSS-TABLE RELATIONSHIP PROFILING
-- ============================================================

-- 1. Sales records with Customer_ID not found in customers_raw

select
	s.Customer_ID,
    count(*) as sales_rows
from sales_raw s 
left join customers_raw c 
	on trim(s.Customer_ID) = trim(c.Customer_ID)
where c.Customer_ID is null
group by s.Customer_ID
order by sales_rows desc;

-- 2. Sales Product_IDs not found in products_raw

select
	s.Product_ID,
    count(*) as sales_rows
from sales_raw s 
left join products_raw p 
	on trim(s.Product_ID) = trim(p.Product_ID)
where p.Product_ID is null
group by s.Product_ID
order by sales_rows desc;

-- 3. Returns not matching an actual sales order line

select
	r.Return_ID,
    r.Order_ID,
    r.Order_Line
from returns_raw r 
left join sales_raw s 
	on trim(r.Order_ID) = trim(s.Order_ID)
    and cast(r.Order_Line as unsigned)
		= cast(s.Order_Line as unsigned)
where s.Order_ID is null
order by r.Return_ID;

-- 4. Check whether orphan return Order_ID exists anywhere in sales

select 
	r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    count(s.Order_ID) as matching_order_rows
from returns_raw r 
left join sales_raw s 
	on trim(r.Order_ID) = trim(s.Order_ID)
where r.Return_ID = 'RET0356'
group by
	r.Return_ID,
    r.Order_ID,
    r.Order_Line;

-- 5. Returns occurring before the original Order_Date

-- 5. Returns occurring before the original Order_Date

SELECT
    r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    s.Order_Date,
    r.Return_Date
FROM returns_raw r
INNER JOIN sales_raw s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE STR_TO_DATE(TRIM(s.Order_Date), '%d-%m-%Y') IS NOT NULL
  AND STR_TO_DATE(TRIM(r.Return_Date), '%d-%m-%Y') IS NOT NULL

  AND STR_TO_DATE(TRIM(r.Return_Date), '%d-%m-%Y')
      < STR_TO_DATE(TRIM(s.Order_Date), '%d-%m-%Y')

ORDER BY r.Return_ID;

-- 6. Check refunds greater than original sales amount

-- 6. Check refunds greater than original sales amount

SELECT
    r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    s.Sales AS original_sales,
    r.Refund_Amount,
    ROUND(
        CAST(r.Refund_Amount AS DECIMAL(12,2))
        - CAST(s.Sales AS DECIMAL(12,2)),
        2
    ) AS excess_refund
FROM returns_raw r
INNER JOIN sales_raw s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE NULLIF(TRIM(r.Refund_Amount), '') IS NOT NULL
  AND NULLIF(TRIM(s.Sales), '') IS NOT NULL

  AND CAST(r.Refund_Amount AS DECIMAL(12,2))
      > CAST(s.Sales AS DECIMAL(12,2))

ORDER BY excess_refund DESC;

-- 7. Returns occurring before the Ship_Date

-- 7. Returns occurring before the Ship_Date

SELECT
    r.Return_ID,
    r.Order_ID,
    r.Order_Line,
    s.Order_Date,
    s.Ship_Date,
    r.Return_Date
FROM returns_raw r
INNER JOIN sales_raw s
    ON TRIM(r.Order_ID) = TRIM(s.Order_ID)
   AND CAST(r.Order_Line AS UNSIGNED)
       = CAST(s.Order_Line AS UNSIGNED)

WHERE STR_TO_DATE(TRIM(s.Ship_Date), '%d-%m-%Y') IS NOT NULL
  AND STR_TO_DATE(TRIM(r.Return_Date), '%d-%m-%Y') IS NOT NULL

  AND STR_TO_DATE(TRIM(r.Return_Date), '%d-%m-%Y')
      < STR_TO_DATE(TRIM(s.Ship_Date), '%d-%m-%Y')

ORDER BY r.Return_ID;