-- ============================================================
-- 1. DATA PROFILING Basic customer profile
-- ============================================================

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