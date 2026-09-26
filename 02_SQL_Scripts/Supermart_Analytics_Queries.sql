create DATABASE supermart_analytics;

use supermart_analytics;

select database();
show databases;

-- ============================================
-- 1. RAW CUSTOMER TABLE
-- ============================================
create table customers_raw (
	Customer_ID		varchar(20),
    Customer_Name	varchar(150),
    Segment			varchar(50),
    Age				varchar(10),
    Country			varchar(50),
    City			varchar(50),
    State			varchar(50),
    Postal_Code		varchar(20),
    Region			varchar(20),
    Email			varchar(150)
);

-- ============================================
-- 2. RAW PRODUCT TABLE
-- ============================================

create table products_raw (
	Product_ID		varchar(20),
    Category		varchar(50),
    Sub_Category 	varchar(100),
    Product_Name	varchar(200),
    Brand			varchar(100),
    Unit_Cost		varchar(30),
    Unit_Price		varchar(30)
);

-- ============================================
-- 3. RAW SALES TABLE
-- ============================================

create table sales_raw (
	Order_Line		varchar(20),
    Order_ID		varchar(30),
    Order_Date		varchar(30),
    Ship_Date		varchar(30),
    Ship_Mode		varchar(50),
    Customer_ID		varchar(20),
    Product_ID		varchar(20),
    Quantity		varchar(20),
    Unit_Price		varchar(30),
    Discount		varchar(30),
    Sales			varchar(30),
    Profit			varchar(30),
    Payment_Mode	varchar(50)
);

-- ============================================
-- 4. RAW RETURNS TABLE
-- ============================================

create table returns_raw (
	Return_ID		varchar(20),
    Order_ID		varchar(30),
    Order_Line		varchar(20),
    Return_Date		varchar(30),
    Return_Reason	varchar(100),
    Refund_Amount	varchar(30),
    Return_Status	varchar(30)
);

show tables;    

describe customers_raw;
describe products_raw;
describe sales_raw;
describe returns_raw;    

use supermart_analytics;

select count(*) as total_rows
from customers_raw;

-- To select some actual records:
select *
from customers_raw
limit 20;

select count(*) as total_rows
from products_raw;

select *
from Products_raw
limit 20;

select count(*) as total_rows
from sales_raw;

select *
from sales_raw
limit 20;

select 
	min(Order_Line) as min_order_line,
    max(cast(Order_Line as unsigned))
as max_order_line,
	count(*) as total_rows
from sales_raw;

select count(*) as total_rows
from returns_raw;

select *
from returns_raw
limit 20;

-- Combined ingestion check 

select 'customers_raw' as table_name,
count(*) as total_rows
from customers_raw
union all
select 'products_raw' , count(*)
from products_raw
union all 
select 'sales_raw' , count(*)
from sales_raw
union all
select 'returns_raw' , count(*)
from returns_raw;

-- 1. Basic customer profile

select 
	count(*) as total_rows,
    count(distinct Customer_ID) as 
unique_customer_ids,
	count(distinct Segment) as 
unique_segments,
	count(distinct City) as
unique_cities,
	count(distinct State) as
unique_states,
	count(distinct Region) as 
unique_regions
from customers_raw;

-- 2. Find duplicate Customer IDs

select
	Customer_ID,
	count(*) as occurrence_count
from customers_raw
group by Customer_ID
having count(*) > 1
order by occurrence_count desc, Customer_ID;

-- 3. Count how many duplicate rows exist

select
	count(*) - count(distinct Customer_ID) as duplicate_customer_rows
from customers_raw;

-- 4. Find NULL and blank values
select
	sum(Customer_ID is null or trim(Customer_ID) = '') as missing_customer_id,
    sum(Customer_Name is null or trim(Customer_Name) = '') as missing_customer_name,
    sum(Segment is null or trim(Segment) = '') as missing_segment,
    sum(Age is null or trim(Age) = '') as missing_age,
    sum(Country is null or trim(Country) = '') as missing_country,
    sum(City is null or trim(City) = '') as missing_city,
    sum(State is null or trim(State) = '') as missing_state,
    sum(Postal_Code is null or trim(Postal_Code) = '') as missing_postal_code,
    sum(Region is null or trim(Region) = '') as missing_region,
    sum(Email is null or trim(Email) = '') as missing_email
from customers_raw;

-- 5. Examine categorical consistency

select Segment, count(*) as total
from customers_raw
group by Segment
order by Segment;

select Region, count(*) as total
from customers_raw
group by Region
order by region;

select State, count(*) as total
from customers_raw
group by State
order by State;

-- 6. Profile Age

select 
	min(cast(nullif(trim(Age), '') as unsigned)) as minimum_age,
    max(cast(nullif(trim(Age), '') as unsigned)) as maximum_age,
    round(avg(cast(nullif(trim(Age), '') as unsigned)), 2) as average_age
from customers_raw;

-- Then investigate potentially invalid/suspicious ages:

select
	Customer_ID,
    Customer_Name,
    Age
from customers_raw
where trim(Age) <> ''
	and cast(Age as Unsigned) < 18;