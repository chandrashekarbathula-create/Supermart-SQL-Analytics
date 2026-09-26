-- ============================================================
-- DATA PROFILING: returns_raw
-- ============================================================

-- 1. Basic profile

select 
	count(*) as total_rows,
    count(distinct Return_ID) as unique_return_ids,
    count(distinct Order_ID ) as unique_orders_returned,
    count(distinct Order_Line) as unique_order_lines_returned,
    count(distinct Return_Reason) as unique_reasons,
    count(distinct Return_Status) as return_statuses
from returns_raw;

-- 2. Duplicate Return IDs

select 
	return_ID,
    count(*) as occurrence_count
from returns_raw
group by Return_ID
having count(*) > 1
order by occurrence_count desc, Return_ID;

-- 3. Count extra duplicate records

select
	count(*) - count(distinct Return_ID) as duplicate_return_rows
from returns_raw;

-- 4. Missing values

select
	sum(Return_ID is null or trim(Return_ID) = '') as missing_return_id,
    sum(Order_ID is null or trim(Order_ID) = '') as missing_order_id,
    sum(Order_Line is null or trim(Order_Line) = '') as missing_order_line,
    sum(Return_Date is null or trim(Return_Date) = '') as missing_return_date,
    sum(Return_Reason is null or trim(Return_Reason) = '') as missing_return_reason,
    sum(Refund_Amount is null or trim(Refund_Amount) = '') as missing_refund_reason,
    sum(Return_Status is null or trim(Return_Status) = '') as missing_return_status
from returns_raw;

-- 5. Return reason distribution

select
	Return_reason,
    count(*) as total
from returns_raw
group by Return_Reason
order by Return_Reason;

-- 6. Return status distribution

select
	Return_Status,
    count(*) as total
from returns_raw
group by Return_status
order by Return_Status;

-- 7. Refund amount profiling

select 
	min(cast(nullif(trim(Refund_Amount), '') as decimal(12,2))) as min_refund,
    max(cast(nullif(trim(Refund_Amount), '') as decimal(12,2))) as max_refund,
    round(avg(cast(nullif(trim(Refund_amount), '') as decimal(12,2))), 2) as avg_refund
from returns_raw;

-- 8. Invalid refund amounts

select
	Return_ID,
    Order_ID,
    Order_Line,
    Refund_Amount
from returns_raw
where cast(nullif(trim(Refund_Amount), '') as decimal(12,2)) < 0;

-- 9. Invalid Return Dates

select
	Return_ID,
    Order_ID,
    Return_Date
from returns_raw
where trim(Return_Date) <> '' and str_to_date(Return_Date, '%d-%m-%Y') is null;

-- 10. Whitespace problems

select
	Return_ID,
    Return_Reason,
    Return_Status
from returns_raw
where Return_Reason <> trim(Return_Reason)
   or Return_Status <> trim(Return_Status);