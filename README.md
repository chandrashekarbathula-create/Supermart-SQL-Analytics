# 🛒 Supermart SQL Analytics

## End-to-End MySQL Data Analytics & Business Intelligence Project

An end-to-end **SQL Data Analytics portfolio project** built using **MySQL and MySQL Workbench**, covering the complete analytics lifecycle from raw transactional data to a validated, production-ready analytical database.

The project demonstrates practical skills in:

**Data Profiling • Data Cleaning • SQL Analytics • Data Validation • Joins • CTEs • Window Functions • Views • Stored Procedures • Indexing • Database QA • KPI Development • Business Insights**

---

## 📌 Project Overview

The objective of this project is to simulate a real-world retail analytics environment in which raw customer, product, sales, and returns data must be transformed into reliable business information.

The project starts with raw CSV datasets and progresses through:

```text
Raw CSV Data
      ↓
Data Profiling
      ↓
Data Quality Assessment
      ↓
Data Cleaning
      ↓
Deduplication
      ↓
Cross-Table Validation
      ↓
Production Tables
      ↓
Business KPI Analysis
      ↓
Reusable SQL Views
      ↓
Stored Procedures
      ↓
Indexing & Performance
      ↓
Database QA
      ↓
Business Insights
      ↓
Production-Ready Analytics Database
```

The final database can serve as a reliable SQL reporting layer for downstream tools such as **Power BI, Tableau, Excel, Python, or other BI applications**.

---

# 🎯 Business Objectives

The project was designed to answer important retail business questions such as:

- How much revenue and profit does the business generate?
- How are sales changing year over year?
- Which regions generate the most revenue?
- Which customer segments contribute the most sales?
- Which product categories are most profitable?
- Which individual products generate the highest sales?
- Who are the highest-value customers?
- How significant are product returns and refunds?
- What is the financial impact of returns?
- Which areas provide opportunities for business growth?
- Is the analytical database reliable enough for reporting?

---

# 🗂️ Repository Structure

```text
Supermart-SQL-Analytics/
│
├── 01_Dataset/
│   ├── customers_raw.csv
│   ├── products_raw.csv
│   ├── sales_raw.csv
│   ├── returns_raw.csv
│   └── dataset_manifest.csv
│
├── 02_SQL_Scripts/
│   ├── 1. DATA PROFILING Basic customer profile.sql
│   ├── 2. DATA PROFILING Products profile.sql
│   ├── 3. DATA PROFILING Sales Data.sql
│   ├── 4. DATA PROFILING Returns.sql
│   ├── 5. CROSS TABLE RELATIONSHIP PROFILING.sql
│   ├── 6. DATA CLEANING.sql
│   ├── 7. Final Clean Dataset Validation.sql
│   ├── 8. BUSINESS ANALYSIS & KPI QUERIES.sql
│   ├── 9. Reusable SQL Views.sql
│   ├── 10. Indexing & Performance.sql
│   ├── 11. Final Database QA & Production Readiness.sql
│   ├── 12. BUSINESS ANALYSIS & INSIGHTS.sql
│   └── Supermart_Analytics_Queries.sql
│
├── 03_Database_Backup/
│   └── supermart_analytics_database.sql
│
├── 04_Screenshots/
│   └── Project execution and validation screenshots
│
├── 05_Documentation/
│   ├── 01_Project_Overview.md
│   ├── 02_Data_Dictionary.md
│   └── 03_Business_Insights.md
│
└── README.md
```

---

# 📊 Dataset

The project uses four primary raw datasets.

## Customers

Contains customer demographic and geographic information.

Important fields include:

```text
Customer_ID
Customer_Name
Segment
Age
Country
City
State
Postal_Code
Region
```

---

## Products

Contains product master information.

Important fields include:

```text
Product_ID
Product_Name
Category
Sub_Category
Brand
```

---

## Sales

Contains transactional sales information.

Important fields include:

```text
Order_ID
Order_Line
Order_Date
Ship_Date
Ship_Mode
Customer_ID
Product_ID
Quantity
Sales
Profit
```

---

## Returns

Contains returned-order information and refund amounts.

Important fields include:

```text
Return_ID
Order_ID
Order_Line
Return_Date
Refund_Amount
```

---

# 🔍 1. Data Profiling

Before modifying the source data, comprehensive profiling was performed.

The profiling process examined:

- total row counts
- unique business keys
- duplicate records
- NULL values
- blank strings
- invalid identifiers
- numerical ranges
- date ranges
- customer distribution
- product distribution
- sales values
- profit values
- return records
- refund values

Separate profiling scripts were created for:

```text
Customers
Products
Sales
Returns
```

This ensured that data-quality problems were identified before transformation.

---

# 🔗 2. Cross-Table Relationship Profiling

Relationships between datasets were validated before creating the analytical layer.

Major relationships included:

```text
Customers
    │
    └── Customer_ID
            │
            ▼
          Sales
            │
            ├── Product_ID ─────► Products
            │
            └── Order_ID +
                Order_Line ─────► Returns
```

Validation included checking for:

- orphan Customer IDs
- orphan Product IDs
- invalid return-order relationships
- duplicate business keys
- missing identifiers
- inconsistent cross-table relationships

---

# 🧹 3. Data Cleaning

The raw data was transformed into cleaner analytical datasets.

Cleaning operations included:

- removing duplicate business records
- standardizing identifiers
- trimming text values
- handling NULL values
- validating numerical values
- converting dates
- validating quantities
- checking negative sales values
- checking invalid foreign keys
- creating deduplicated production datasets

Production-oriented tables included:

```text
customers_clean
products_dedup
sales_dedup
returns_valid
```

The raw tables were retained separately for traceability.

---

# ✅ 4. Data Quality Validation

A dedicated validation layer was created after cleaning.

Important QA checks included:

```text
Sales duplicate business keys       = 0
Product duplicate IDs               = 0
Customer duplicate IDs              = 0
Return duplicate IDs                = 0
Sales missing Customer_ID           = 0
Sales missing Product_ID            = 0
Sales non-positive quantity         = 0
Sales negative sales amount         = 0
Returns missing Order_ID            = 0
Returns missing Order_Line          = 0
```

This provides evidence that the cleaned analytical tables satisfy the project's major quality requirements.

---

# 🧠 5. Business Analysis

Once the data passed validation, SQL was used to answer business questions across:

- sales
- customers
- products
- categories
- regions
- segments
- profitability
- returns
- monthly trends
- yearly trends

The analysis uses SQL concepts including:

```sql
JOIN
GROUP BY
HAVING
CASE
CTE
Subqueries
LAG()
DENSE_RANK()
COUNT(DISTINCT ...)
SUM()
AVG()
ROUND()
NULLIF()
YEAR()
MONTH()
```

---

# 📈 6. Core Business KPIs

The final KPI layer produced the following validated metrics:

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
| Avg Units Per Order | 8.99 |
| Avg Sales Per Customer | 69,594.77 |
| Total Returns | 799 |
| Total Refund Amount | 416,961.18 |
| Return Rate | 7.99% |
| Refund-to-Sales | 5.99% |
| Net Sales After Refunds | 6,549,475.81 |

Analysis period:

```text
2022-01-01 → 2025-12-31
```

---

# 📅 7. Year-over-Year Performance

| Year | Sales | Profit | Profit Margin | YoY Sales Growth |
|---|---:|---:|---:|---:|
| 2022 | 1,803,028.02 | 346,690.92 | 19.23% | — |
| 2023 | 1,687,496.48 | 328,295.59 | 19.45% | -6.39% |
| 2024 | 1,726,063.26 | 337,659.66 | 19.56% | +2.28% |
| 2025 | 1,749,783.67 | 334,608.59 | 19.13% | +1.30% |

### Insight

Sales declined in **2023**, followed by moderate recovery during **2024 and 2025**.

Despite the recovery, 2025 sales remained below the 2022 level.

This makes recovery and sustainable sales growth an important management focus.

---

# 🌍 8. Regional Performance

Regional analysis showed that the **West region generated the highest sales**.

Approximate regional sales:

```text
West     → 2.17M
South    → 1.98M
East     → 1.44M
North    → 1.37M
```

West also generated the highest absolute profit.

However, the East region showed a strong profit margin despite having lower total sales.

### Business Insight

Regional performance should therefore be evaluated using both:

```text
Revenue Contribution
        +
Profitability
```

rather than revenue alone.

---

# 👥 9. Customer Segment Analysis

Sales by customer segment:

| Segment | Total Sales | Total Profit | Profit Margin |
|---|---:|---:|---:|
| Corporate | 2,509,944.29 | 487,525.41 | 19.43% |
| Home Office | 2,394,321.28 | 464,003.66 | 19.38% |
| Consumer | 2,061,975.07 | 395,648.68 | 19.19% |

### Insight

**Corporate** generated the highest revenue and profit.

Home Office also demonstrated strong customer and order activity.

These segments represent important opportunities for retention, targeted promotions, and customer development.

---

# 📦 10. Category Performance

| Category | Total Sales | Total Profit | Margin |
|---|---:|---:|---:|
| Grocery | 1,306,270.53 | 253,167.63 | 19.38% |
| Beverages | 1,283,483.04 | 229,155.30 | 17.85% |
| Household | 1,187,380.16 | 239,504.26 | 20.17% |
| Electronics | 1,140,768.40 | 250,008.57 | 21.92% |
| Snacks | 1,107,919.72 | 216,486.01 | 19.54% |
| Personal Care | 939,708.58 | 158,758.47 | 16.89% |

### Key Findings

**Grocery** generated the highest category revenue.

**Electronics** produced the strongest profit margin among the major categories at approximately **21.92%**.

This demonstrates why revenue and profitability should be evaluated together.

---

# 🏆 11. Top Products

Examples of leading products by sales include:

| Rank | Product | Category | Sales |
|---:|---|---|---:|
| 1 | FreshChoice Sugar 439 | Grocery | 636,016.83 |
| 2 | UrbanMart Sugar 282 | Grocery | 620,789.23 |
| 3 | FreshChoice Cookies 764 | Snacks | 577,521.02 |
| 4 | NatureNest Tea 281 | Grocery | 569,506.16 |
| 5 | FreshChoice Pulses 907 | Grocery | 568,447.70 |

Window functions were used to generate both:

```text
Overall Product Rank
Category Product Rank
```

using SQL `DENSE_RANK()`.

---

# 👤 12. Customer Performance

A reusable customer-performance layer was created to calculate:

```text
Total Orders
Sales Lines
Units Purchased
Total Sales
Total Profit
Average Order Value
Profit Margin
First Order Date
Last Order Date
```

The analysis identified high-value customers and showed that several leading customers belonged to the Corporate segment.

This analysis can support:

- customer segmentation
- retention campaigns
- loyalty programs
- churn analysis
- personalized marketing

---

# ↩️ 13. Returns Analysis

Validated return metrics:

```text
Total Returns       = 799
Refund Amount       = 416,961.18
Return Rate         = 7.99%
Refund-to-Sales     = 5.99%
```

Net sales after refunds:

```text
6,549,475.81
```

The returns layer also analyzes:

```text
Original Sales
Refund Amount
Refund Impact %
Adjusted Sales
Adjusted Profit
Days to Return
Return Date Quality
```

### Business Insight

Refunds represent a meaningful reduction in realized sales and therefore should be monitored as both an operational and financial KPI.

---

# 🏗️ 14. Reusable Analytical Views

The project contains five reusable analytical views:

```text
vw_sales_detail
vw_customer_performance
vw_product_performance
vw_returns_analysis
vw_kpi_summary
```

### `vw_sales_detail`

Provides the primary transaction-level analytical dataset combining cleaned sales data with customer and product information.

### `vw_customer_performance`

Produces one analytical row per customer with customer-level sales and profitability metrics.

### `vw_product_performance`

Produces one analytical row per product with product-level sales, order, unit, and profitability metrics.

### `vw_returns_analysis`

Combines return transactions with corresponding sales, customer, product, and refund information.

### `vw_kpi_summary`

Provides a reusable executive KPI layer for high-level reporting.

---

# ⚙️ 15. Stored Procedures

Three reusable stored procedures were created:

```text
sp_region_segment_summary
sp_region_performance
sp_segment_performance
```

Examples:

```sql
CALL sp_region_segment_summary();

CALL sp_region_performance('West');

CALL sp_segment_performance('Corporate');
```

These procedures provide reusable business reporting without repeatedly writing the underlying aggregation logic.

---

# 🚀 16. Indexing & Performance

The project also includes database-performance optimization.

Indexing was applied to frequently used:

- business keys
- join columns
- customer identifiers
- product identifiers
- order identifiers
- analytical filter columns

Query execution plans and join behavior were reviewed to improve analytical query performance.

This demonstrates that the project considers not only query correctness but also **database efficiency and scalability**.

---

# 🧪 17. Production QA

A final database QA process was implemented before declaring the analytical database production-ready.

The final QA framework validated **19 checks**, including:

```text
Production row counts
Sales view row counts
Unique business keys
Customer dimension rows
Product dimension rows
Valid returns
KPI orders
KPI sales lines
KPI units
KPI sales
KPI profit
KPI refunds
Duplicate sales keys
Duplicate customer rows
Duplicate product rows
Duplicate return rows
Invalid returns
Stored procedures
Analytical views
```

Final result:

```text
19 / 19 QA CHECKS = PASS
```

This provides a final reconciliation between the production tables and analytical reporting layer.

---

# 🛡️ 18. Reconciliation Testing

Metrics were reconciled between production tables and analytical views.

Example:

```text
Production Sales Rows : 10,000
Sales View Rows       : 10,000

Production Sales      : 6,966,436.99
View Sales            : 6,966,436.99

Production Profit     : 1,347,352.20
View Profit           : 1,347,352.20

Production Units      : 44,932
View Units            : 44,932
```

Customer and product analytical views were also tested to ensure exactly one row existed per analytical entity.

---

# ⚠️ 19. Data Quality Finding

During analysis, one transaction was identified with a missing `Order_Date`.

The record remained part of the overall financial totals but was excluded from date-dependent trend analysis.

This demonstrated an important real-world analytics principle:

> Data-quality issues should be identified, documented, and handled according to their analytical impact rather than silently ignored.

Future production pipelines should automatically flag missing transaction dates before reporting.

---

# 💡 20. Major Business Insights

The project produced several important findings:

1. **West is the largest sales region**, generating approximately 2.17M in revenue.

2. **Corporate is the highest-revenue customer segment**, generating approximately 2.51M.

3. **Grocery is the largest category by sales.**

4. **Electronics has the strongest profit margin** among the major categories analyzed.

5. Sales declined **6.39% in 2023**, followed by moderate recovery in 2024 and 2025.

6. **799 returns** generated approximately **416,961** in refunds.

7. Refunds represent approximately **5.99% of gross sales**.

8. Profit margins remained relatively stable around **19%** throughout the analysis period.

9. Several high-value customers belong to the Corporate segment.

10. Product and customer performance vary substantially, supporting targeted business strategies instead of uniform treatment.

---

# 💼 21. Business Recommendations

Based on the analysis:

### Protect High-Performing Markets

Maintain strong performance in the West while identifying strategies that can be transferred to other regions.

### Strengthen Corporate Customer Retention

Corporate is the largest revenue-generating segment and should receive focused retention and account-management strategies.

### Expand High-Margin Categories

Electronics demonstrates strong profitability and may provide opportunities for profitable growth.

### Investigate Lower-Margin Categories

Personal Care and Beverages should be reviewed for pricing, discount, product-mix, and cost optimization opportunities.

### Reduce Refund Impact

Products and categories generating high refund amounts should be investigated for quality, fulfillment, pricing, and customer-expectation issues.

### Protect High-Value Customers

Customer-level analysis can support loyalty programs, targeted promotions, and churn prevention.

### Automate Data Quality

Future pipelines should automatically detect missing dates, duplicate keys, invalid relationships, and other critical data-quality issues.

---

# 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| MySQL | Relational database |
| MySQL Workbench | SQL development and database administration |
| SQL | Data profiling, cleaning, transformation and analytics |
| CSV | Raw source data |
| Git | Version control |
| GitHub | Project documentation and portfolio hosting |

---

# 🧠 SQL Skills Demonstrated

This project demonstrates practical experience with:

```text
SELECT
WHERE
CASE
GROUP BY
HAVING
ORDER BY
DISTINCT
INNER JOIN
LEFT JOIN
Subqueries
CTEs
Aggregate Functions
Date Functions
String Functions
NULL Handling
Data Cleaning
Data Validation
Deduplication
Window Functions
LAG()
DENSE_RANK()
Views
Stored Procedures
Indexes
Composite Keys
Referential Integrity
Database QA
Reconciliation Testing
Business KPI Development
```

---

# ▶️ How to Run the Project

## Prerequisites

Install:

```text
MySQL Server
MySQL Workbench
```

## Option 1 — Restore the Complete Database

The easiest method is to restore:

```text
03_Database_Backup/supermart_analytics_database.sql
```

using MySQL Workbench.

This restores the project database and associated objects contained in the backup.

## Option 2 — Build from the Raw Dataset

Import the files from:

```text
01_Dataset/
```

and execute the SQL scripts in numerical order:

```text
1 → Customer Profiling
2 → Product Profiling
3 → Sales Profiling
4 → Returns Profiling
5 → Cross-Table Profiling
6 → Data Cleaning
7 → Dataset Validation
8 → Business Analysis & KPI Queries
9 → Reusable SQL Views
10 → Indexing & Performance
11 → Final Database QA
12 → Business Analysis & Insights
```

---

# 📚 Project Documentation

Detailed project documentation is available in:

```text
05_Documentation/
```

including:

```text
01_Project_Overview.md
02_Data_Dictionary.md
03_Business_Insights.md
```

These documents provide additional information about the project architecture, dataset structure, analytical methodology, and business findings.

---

# 📸 Screenshots

Execution evidence and validation screenshots are available in:

```text
04_Screenshots/
```

The screenshots demonstrate:

- data validation
- KPI results
- analytical views
- customer analysis
- product analysis
- returns analysis
- stored procedure execution
- final database QA
- database export

---

# 🔮 Future Enhancements

Potential extensions to this project include:

- Power BI dashboard integration
- automated ETL pipelines
- Python-based exploratory data analysis
- customer RFM segmentation
- customer lifetime value analysis
- product affinity analysis
- sales forecasting
- anomaly detection
- automated SQL testing
- cloud database deployment

---

# 🎓 Key Learning Outcomes

This project demonstrates the ability to:

- convert raw data into structured analytical datasets
- investigate and resolve data-quality problems
- design reusable SQL reporting layers
- create business KPIs
- perform customer and product analytics
- analyze sales trends and profitability
- analyze returns and refund impact
- use advanced SQL window functions
- build reusable stored procedures
- optimize database queries
- perform production-level QA
- translate SQL results into actionable business insights

---

# 🏁 Conclusion

**Supermart SQL Analytics** demonstrates a complete SQL analytics workflow rather than a collection of isolated queries.

The project covers the journey from:

```text
Raw Data
   ↓
Clean Data
   ↓
Validated Data
   ↓
Analytical Views
   ↓
Business KPIs
   ↓
Business Insights
   ↓
Production QA
```

The resulting MySQL database provides a validated and reusable analytical foundation that can support BI dashboards, management reporting, and further advanced analytics.

---

## 👨‍💻 Author

**Chandrashekar Bathula**

Data Analytics | SQL | MySQL | Power BI | Python | Business Intelligence

---

⭐ If you found this project useful, feel free to explore the SQL scripts, documentation, and analytical workflow included in this repository.
