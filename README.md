# 🛒 Supermart Sales Analytics — End-to-End MySQL Project

## 📌 Project Overview

This project demonstrates an end-to-end SQL analytics workflow using MySQL and MySQL Workbench.

The objective was to transform raw Supermart transactional data into a clean, validated, optimized, and reusable analytics database capable of supporting business reporting and decision-making.

The project covers the complete analytics lifecycle:

**Raw Data → Data Profiling → Data Cleaning → Data Validation → KPI Analysis → SQL Views → Stored Procedures → Indexing & Performance Optimization → Database QA → Business Insights → Deployment Backup**

---

## 🎯 Project Objectives

The main objectives of this project were to:

- Profile raw customer, product, sales, and returns datasets
- Identify missing values, duplicates, invalid records, and relationship issues
- Build cleaned production-ready tables
- Validate primary and business keys
- Maintain relationships between sales, customers, products, and returns
- Develop reusable analytical SQL views
- Build business KPIs
- Create stored procedures for reusable reporting
- Improve query performance using indexes
- Perform final production-level QA
- Analyze sales, customers, products, regions, segments, and returns
- Prepare the database for backup and deployment

---

## 🛠 Technologies Used

- MySQL
- MySQL Workbench
- SQL
- Views
- Common Table Expressions (CTEs)
- Window Functions
- Aggregate Functions
- Stored Procedures
- Indexing
- Query Execution Plans
- Data Quality Validation
- Relational Data Modeling

---

## 📂 Project Structure

```text
Supermart-SQL-Analytics/
│
├── 01_Dataset/
│   └── Raw and project datasets
│
├── 02_SQL_Scripts/
│   ├── Data Profiling
│   ├── Data Cleaning
│   ├── Final Dataset Validation
│   ├── Business Analysis & KPI Queries
│   ├── Reusable SQL Views
│   ├── Indexing & Performance
│   ├── Final Database QA
│   └── Business Analysis & Insights
│
├── 03_Database_Backup/
│   └── supermart_analytics_database.sql
│
├── 04_Screenshots/
│   └── Query results and validation evidence
│
├── 05_Documentation/
│   └── Project documentation
│
└── README.md
```

---

# 🔍 1. Data Profiling

Initial profiling was performed on:

- Customers
- Products
- Sales
- Returns

Profiling included:

- Row counts
- Column validation
- Missing-value analysis
- Duplicate detection
- Distinct-value analysis
- Date validation
- Numeric-range checks
- Cross-table relationship profiling

This stage helped identify data-quality problems before transformation.

---

# 🧹 2. Data Cleaning

The raw datasets were transformed into cleaned analytical tables.

Major cleaning activities included:

- Removing duplicate business keys
- Standardizing customer records
- Deduplicating product records
- Validating sales transactions
- Cleaning return records
- Standardizing dates
- Handling missing dimension references
- Validating quantities and monetary values

Production-ready tables included:

- `sales_dedup`
- `customers_clean`
- `products_dedup`
- `returns_valid`

---

# ✅ 3. Data Quality Validation

A dedicated QA layer was created to verify the cleaned database.

Validation included:

- Duplicate sales business keys
- Duplicate customer IDs
- Duplicate product IDs
- Duplicate return IDs
- Missing Customer IDs
- Missing Product IDs
- Missing Order IDs
- Missing Order Lines
- Invalid quantities
- Invalid sales amounts
- Invalid return records

The final QA suite contained **19 validation checks**, all returning:

**PASS ✅**

---

# 📊 4. Core Business KPIs

Final validated KPIs:

| KPI | Result |
|---|---:|
| Total Orders | 5,000 |
| Sales Lines | 10,000 |
| Customers | 1,001 |
| Products | 301 |
| Units Sold | 44,932 |
| Total Sales | 6,966,436.99 |
| Total Profit | 1,347,352.20 |
| Profit Margin | 19.34% |
| Average Order Value | 13,932.87 |
| Avg Units per Order | 8.99 |
| Avg Sales per Customer | 69,594.77 |
| Total Returns | 799 |
| Total Refund Amount | 4,169,612.18 |
| Return Rate | 7.99% |
| Refund-to-Sales % | 5.99% |
| Net Sales After Refunds | 6,549,474.81 |
| First Order Date | 2022-01-01 |
| Last Order Date | 2025-12-31 |

---

# 📈 5. Sales Trend Analysis

Year-over-year sales analysis was performed using SQL window functions.

| Year | Total Sales | YoY Growth |
|---|---:|---:|
| 2022 | 1,803,028.02 | — |
| 2023 | 1,687,496.48 | -6.39% |
| 2024 | 1,726,063.26 | +2.28% |
| 2025 | 1,747,983.67 | +1.30% |

The analysis shows a sales decline in 2023 followed by recovery in 2024 and continued positive growth in 2025.

---

# 🌍 6. Regional Analysis

Regional performance analysis was conducted across:

- West
- South
- East
- North

Metrics analyzed included:

- Orders
- Customers
- Units sold
- Sales
- Profit
- Profit margin
- Average order value

This provides management with a geographic view of business performance.

---

# 👥 7. Customer & Segment Analysis

Customers were analyzed using:

- Total orders
- Units purchased
- Total sales
- Total profit
- Average order value
- Profit margin
- First order date
- Last order date

Segment-level analysis covered:

- Corporate
- Home Office
- Consumer

A reusable customer-performance view was developed to support customer ranking and segmentation.

---

# 📦 8. Product & Category Analysis

Product performance was analyzed using:

- Product sales
- Units sold
- Number of orders
- Total profit
- Profit margin
- Average selling price
- Average sales per order

Products were ranked using SQL window functions.

Analysis included both:

- Overall product sales ranking
- Category-level product ranking

---

# ↩️ 9. Returns Analysis

A dedicated returns analytical layer was developed.

Returns analysis included:

- Total returns
- Refund amount
- Average refund
- Refund impact %
- Adjusted sales
- Adjusted profit
- Days to return
- Return-date quality
- Category-level return analysis

Final validated values:

**799 returns**

**Total Refund Amount: 4,169,612.18**

---

# 🧱 10. Reusable SQL Views

Five analytical views were created:

- `vw_sales_detail`
- `vw_customer_performance`
- `vw_product_performance`
- `vw_returns_analysis`
- `vw_kpi_summary`

These views provide reusable analytical datasets and reduce duplication of complex SQL logic.

---

# ⚙️ 11. Stored Procedures

Three stored procedures were implemented:

- `sp_region_performance`
- `sp_segment_performance`
- `sp_region_segment_summary`

These procedures allow reusable business reporting without rewriting analytical SQL queries.

Example:

```sql
CALL sp_region_performance('West');
```

```sql
CALL sp_segment_performance('Corporate');
```

---

# 🚀 12. Indexing & Performance Optimization

Indexes were created for frequently used filtering and joining columns.

Examples include:

- Customer ID
- Product ID
- Order ID
- Order Line

Query performance was validated using:

```sql
EXPLAIN
```

Execution plans were compared before and after indexing.

Optimized queries showed index access methods such as:

- `ref`
- `eq_ref`

instead of unnecessary full-table scans for selective lookups.

---

# 🧪 13. Production QA

Before deployment, production-level reconciliation was performed between source tables and analytical views.
