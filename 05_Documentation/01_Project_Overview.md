# Supermart SQL Analytics — Project Overview

## 1. Project Summary

**Supermart SQL Analytics** is an end-to-end MySQL data analytics project designed to demonstrate a realistic data analyst workflow using transactional retail data.

The project begins with raw customer, product, sales, and returns datasets and progresses through data profiling, data cleaning, validation, relational integrity checks, business analysis, reusable analytical views, stored procedures, indexing, performance optimization, final database QA, business insights, and database backup.

The final result is a cleaned, validated, reusable, and optimized MySQL analytical database that can support reporting, KPI analysis, and downstream BI tools.

---

## 2. Project Objectives

The primary objectives were to:

- Import and understand raw transactional datasets.
- Profile each dataset before transformation.
- Identify missing values, duplicates, invalid records, and data-quality problems.
- Validate relationships between customers, products, sales, and returns.
- Build cleaned production-ready tables.
- Protect sales data from duplicate business keys.
- Develop reusable analytical SQL views.
- Calculate management-level KPIs.
- Build customer, product, regional, segment, and returns analysis.
- Create stored procedures for reusable reporting.
- Improve query performance using indexes.
- Validate optimization using `EXPLAIN`.
- Perform production-readiness QA.
- Generate business insights from the validated analytical layer.
- Export the completed database for backup and reproducibility.

---

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| MySQL | Relational database and SQL analytics |
| MySQL Workbench | Database development, administration, querying, and export |
| SQL | Data profiling, transformation, analysis, and validation |
| CSV | Raw source datasets |
| GitHub | Version control and portfolio presentation |

The project also demonstrates SQL concepts including:

- Joins
- Aggregate functions
- Subqueries
- Common Table Expressions (CTEs)
- CASE expressions
- Date functions
- Window functions
- `LAG()`
- `DENSE_RANK()`
- Views
- Stored procedures
- Indexes
- `EXPLAIN`
- Data-quality validation

---

## 4. Source Data

The project uses four primary business datasets:

### Customers

Contains customer-level attributes such as:

- Customer ID
- Customer Name
- Segment
- Age
- Country
- City
- State
- Postal Code
- Region

### Products

Contains product-level information such as:

- Product ID
- Product Name
- Category
- Sub-Category
- Brand

### Sales

Contains transactional sales information such as:

- Order ID
- Order Line
- Order Date
- Ship Date
- Ship Mode
- Customer ID
- Product ID
- Quantity
- Sales
- Discount
- Profit

### Returns

Contains returned-order information including return identifiers, order references, dates, and refund amounts.

---

## 5. End-to-End Project Workflow

The project was developed using the following workflow:

```text
Raw CSV Files
      ↓
Data Import
      ↓
Data Profiling
      ↓
Cross-Table Relationship Profiling
      ↓
Data Cleaning
      ↓
Clean Dataset Validation
      ↓
Business Analysis & KPI Development
      ↓
Reusable SQL Views
      ↓
Stored Procedures
      ↓
Indexing & Performance Optimization
      ↓
Final Database QA
      ↓
Business Analysis & Insights
      ↓
Database Backup / Deployment Preparation
```

---

## 6. Data Profiling

Data profiling was performed before cleaning to understand the structure and quality of the source data.

Checks included:

- Total row counts
- Distinct identifiers
- Duplicate IDs
- Duplicate business keys
- Missing values
- Invalid quantities
- Invalid monetary values
- Date ranges
- Customer relationships
- Product relationships
- Sales-to-return relationships

Separate profiling scripts were created for customers, products, sales, and returns.

Cross-table profiling was also performed to identify orphaned or inconsistent relationships.

---

## 7. Data Cleaning

Raw data was transformed into production-ready analytical tables.

Key cleaned tables include:

```text
customers_clean
products_dedup
sales_dedup
returns_valid
```

Cleaning operations included:

- Customer deduplication
- Product deduplication
- Sales business-key deduplication
- Date conversion and standardization
- Invalid-record detection
- Missing-key validation
- Quantity validation
- Sales-value validation
- Return validation
- Relationship validation

For sales transactions, the combination of:

```text
Order_ID + Order_Line
```

was treated as the business key to prevent duplicate sales records.

---

## 8. Final Clean Dataset Validation

After cleaning, a dedicated validation stage was performed.

Checks included:

- Duplicate sales business keys
- Duplicate customer IDs
- Duplicate product IDs
- Duplicate return IDs
- Missing customer references
- Missing product references
- Missing order identifiers
- Missing order-line identifiers
- Non-positive quantities
- Invalid sales amounts
- Invalid return records

The validated production tables were then used as the foundation for all downstream analytics.

---

## 9. Analytical Views

Five reusable SQL views were created:

### `vw_sales_detail`

Provides the primary detailed analytical sales dataset by combining validated sales information with customer and product dimensions.

### `vw_customer_performance`

Aggregates performance at customer level and supports analysis of:

- Orders
- Units purchased
- Sales
- Profit
- Average order value
- Profit margin
- First order
- Last order

### `vw_product_performance`

Provides product-level metrics including:

- Orders
- Units sold
- Sales
- Profit
- Profit margin
- Average selling price
- Average sales per order

### `vw_returns_analysis`

Provides a reusable returns-analysis layer containing metrics such as:

- Refund amount
- Refund impact
- Adjusted sales
- Adjusted profit
- Days to return
- Return-date quality

### `vw_kpi_summary`

Provides a consolidated management-level KPI layer for the overall business.

---

## 10. Stored Procedures

Three stored procedures were created for reusable business reporting:

```sql
CALL sp_region_segment_summary();

CALL sp_region_performance('West');

CALL sp_segment_performance('Corporate');
```

These procedures allow common business questions to be answered without repeatedly rewriting complex aggregation queries.

---

## 11. Indexing and Performance Optimization

Indexes were added to frequently filtered and joined columns.

Examples include:

- Customer ID
- Product ID
- Order ID
- Order Line

Query execution plans were examined using:

```sql
EXPLAIN
```

Optimization testing confirmed that selective lookups and joins could use indexed access methods such as:

```text
ref
eq_ref
```

instead of unnecessary full-table scans where appropriate.

---

## 12. Production QA

A final database QA framework was created before deployment.

The QA process reconciled:

- Production sales rows
- Analytical sales rows
- Unique sales business keys
- Customer counts
- Product counts
- Return counts
- Orders
- Sales lines
- Units
- Sales
- Profit
- Refunds
- Duplicate records
- Invalid return records
- Stored procedures
- Analytical views

### Final QA Result

**19 out of 19 validation checks passed.**

This provided confidence that the final analytical database reconciled with the validated production data.

---

## 13. Final Business KPIs

The validated analytical database produced the following overall KPIs:

| KPI | Value |
|---|---:|
| Total Orders | 5,000 |
| Total Sales Lines | 10,000 |
| Total Customers | 1,001 |
| Total Products | 301 |
| Total Units | 44,932 |
| Total Sales | 6,966,436.99 |
| Total Profit | 1,347,352.20 |
| Profit Margin | 19.34% |
| Average Order Value | 13,932.87 |
| Average Units per Order | 8.99 |
| Average Sales per Customer | 69,594.77 |
| Total Returns | 799 |
| Total Refund Amount | 416,961.18 |
| Return Rate | 