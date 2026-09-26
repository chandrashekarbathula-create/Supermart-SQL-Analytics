# Supermart SQL Analytics — Business Insights

## 1. Executive Summary

The Supermart SQL Analytics project analyzes customer, product, sales, profitability, and return performance across the period **2022–2025**.

The production-ready analytical dataset contains:

| KPI | Result |
|---|---:|
| Total Orders | 5,000 |
| Total Sales Lines | 10,000 |
| Total Customers | 1,001 |
| Total Products | 301 |
| Units Sold | 44,932 |
| Total Sales | 6,966,436.99 |
| Total Profit | 1,347,352.20 |
| Profit Margin | 19.34% |
| Average Order Value | 13,932.87 |
| Average Units per Order | 8.99 |
| Average Sales per Customer | 69,594.77 |
| Total Returns | 799 |
| Total Refund Amount | 416,961.18 |
| Return Rate | 7.99% |
| Refund-to-Sales Ratio | 5.99% |
| Net Sales After Refunds | 6,549,475.81 |

The analysis shows a business with relatively stable annual sales after the decline in 2023, positive profitability across major business segments, meaningful regional differences, and a material refund impact that should be monitored.

---

# 2. Sales Performance

## Overall Performance

Across the analytical period, Supermart generated:

```text
Gross Sales     : 6,966,436.99
Gross Profit    : 1,347,352.20
Profit Margin   : 19.34%
Units Sold      : 44,932
Orders          : 5,000
```

The overall profit margin of approximately **19.34%** indicates that the business remained profitable across the analyzed dataset.

Average Order Value was:

```text
13,932.87
```

with approximately:

```text
8.99 units per order
```

This means the typical order contains roughly nine units.

---

# 3. Year-over-Year Sales Analysis

Annual performance was:

| Year | Total Sales | Total Profit | Profit Margin | YoY Sales Growth |
|---|---:|---:|---:|---:|
| 2022 | 1,803,028.02 | 346,690.92 | 19.23% | — |
| 2023 | 1,687,496.48 | 328,295.59 | 19.45% | -6.39% |
| 2024 | 1,726,063.26 | 337,659.66 | 19.56% | +2.28% |
| 2025 | 1,749,783.67 | 334,608.59 | 19.13% | +1.30% |

## Insight

Sales declined approximately **6.39% in 2023** compared with 2022.

However, the business subsequently returned to positive growth:

```text
2024: +2.28%
2025: +1.30%
```

This indicates a gradual recovery after the 2023 decline.

Nevertheless, 2025 sales remained below the 2022 level, meaning the business had not fully recovered to its earlier sales peak by the end of the analytical period.

## Business Recommendation

Management should investigate the factors behind the 2023 decline by analyzing:

- customer activity,
- product/category performance,
- regional sales,
- customer segment performance,
- order frequency,
- and returns.

The goal should be to identify whether the decline was driven by customer loss, lower purchasing frequency, weaker category performance, or regional changes.

---

# 4. Regional Performance

Regional sales analysis produced approximately:

| Region | Orders | Customers | Units Sold | Total Sales | Total Profit | Margin |
|---|---:|---:|---:|---:|---:|---:|
| West | 2,649 | 305 | 14,136 | 2,170,137.22 | 421,406.33 | 19.42% |
| South | 2,462 | 284 | 12,782 | 1,984,923.06 | 379,908.72 | 19.14% |
| East | 1,820 | 212 | 9,057 | 1,442,914.78 | 284,253.46 | 19.70% |
| North | 1,821 | 199 | 8,952 | 1,367,416.58 | 261,575.24 | 19.13% |

## Key Insight

The **West region generated the highest sales**, contributing approximately:

```text
2.17 million
```

in sales.

It also generated the highest absolute profit among the regions.

The South region was the second-largest contributor.

The East and North regions generated considerably lower sales than West and South.

Interestingly, the East region produced the strongest profit margin among the four primary regions at approximately:

```text
19.70%
```

This demonstrates an important distinction between **sales volume** and **profitability efficiency**.

## Business Recommendation

The company should maintain its strong position in West while investigating opportunities to expand customer acquisition and order volume in East and North.

East deserves particular attention because its relatively strong margin suggests that additional sales growth there could potentially produce attractive profit contribution.

---

# 5. Customer Segment Performance

Customer segment analysis showed:

| Segment | Customers | Orders | Units Sold | Total Sales | Total Profit | Margin |
|---|---:|---:|---:|---:|---:|---:|
| Corporate | 341 | 2,905 | 15,894 | 2,509,944.29 | 487,525.41 | 19.43% |
| Home Office | 366 | 2,923 | 15,746 | 2,394,321.28 | 464,003.66 | 19.38% |
| Consumer | 293 | 2,540 | 13,287 | 2,061,975.07 | 395,648.68 | 19.19% |

## Key Insight

The **Corporate segment generated the highest total sales**:

```text
2,509,944.29
```

and the highest profit:

```text
487,525.41
```

Home Office had the largest customer count among the three main segments and generated the highest number of orders.

Consumer generated lower sales and profit compared with Corporate and Home Office.

Profit margins, however, remained relatively close across all three major segments.

This indicates that the main differences between segments come primarily from customer/order activity and sales volume rather than dramatic differences in margin.

## Business Recommendation

Corporate customers should remain an important revenue focus.

At the same time, Home Office customers present a strong opportunity because of their high customer count and order activity.

Consumer performance should be examined for opportunities to improve:

- purchase frequency,
- average basket size,
- cross-selling,
- and customer retention.

---

# 6. Region × Segment Analysis

Further analysis reveals important combinations of geography and customer segment.

Examples include:

| Region | Segment | Sales | Profit | Margin |
|---|---|---:|---:|---:|
| West | Home Office | 770,191.31 | 153,692.02 | 19.96% |
| West | Corporate | 762,823.97 | 145,378.66 | 19.06% |
| South | Corporate | 715,706.95 | 137,940.09 | 19.27% |
| South | Home Office | 695,726.22 | 134,172.53 | 19.29% |
| West | Consumer | 637,121.95 | 122,370.65 | 19.21% |
| South | Consumer | 573,489.89 | 107,956.33 | 18.80% |

## Key Insight

The combination:

```text
West + Home Office
```

generated particularly strong sales and profit.

West + Corporate was also a major revenue contributor.

This indicates that regional performance cannot be fully understood without considering customer segment composition.

## Business Recommendation

Marketing and sales strategies should be targeted at **region × segment combinations** rather than treating every customer identically.

For example, successful Home Office strategies in West could be analyzed and tested in other regions.

---

# 7. Product Category Performance

Category-level analysis showed approximately:

| Category | Total Sales | Total Profit | Profit Margin |
|---|---:|---:|---:|
| Grocery | 1,306,270.53 | 253,167.63 | 19.38% |
| Beverages | 1,283,483.04 | 229,155.30 | 17.85% |
| Household | 1,187,380.16 | 239,504.26 | 20.17% |
| Electronics | 1,140,768.40 | 250,008.57 | 21.92% |
| Snacks | 1,107,919.72 | 216,486.01 | 19.54% |
| Personal Care | 939,708.58 | 158,758.47 | 16.89% |

## Key Insight

**Grocery generated the highest total sales**, making it an important revenue category.

However, Electronics produced a considerably stronger profit margin:

```text
21.92%
```

compared with Grocery's approximately:

```text
19.38%
```

Personal Care showed the weakest margin among the six primary categories:

```text
16.89%
```

Beverages also showed a comparatively lower margin:

```text
17.85%
```

## Business Recommendation

Management should avoid evaluating categories only by revenue.

Categories should be assessed using both:

```text
Sales Volume
+
Profit Margin
```

Electronics may deserve greater commercial focus because of its strong profitability.

Personal Care and Beverages should be investigated for:

- pricing,
- discount levels,
- product mix,
- procurement cost,
- and promotional effectiveness.

---

# 8. Top Product Performance

Product-level ranking identified several major revenue-generating products.

Examples include:

| Rank | Product | Category | Total Sales |
|---:|---|---|---:|
| 1 | FreshChoice Sugar 439 | Grocery | 636,016.83 |
| 2 | UrbanMart Sugar 282 | Grocery | 620,789.23 |
| 3 | FreshChoice Cookies 764 | Snacks | 577,521.02 |
| 4 | NatureNest Tea 281 | Grocery | 569,506.16 |
| 5 | FreshChoice Pulses 907 | Grocery | 568,447.70 |
| 6 | FreshChoice Mixer Grinder 630 | Electronics | 566,179.88 |
| 7 | SmartBuy Dishwash 568 | Household | 527,012.38 |

## Key Insight

Several of the highest-selling individual products belong to Grocery.

FreshChoice also appears repeatedly among high-performing products.

The leading product:

```text
FreshChoice Sugar 439
```

generated approximately:

```text
636,016.83
```

in sales.

## Business Recommendation

Top-performing products should receive strong inventory availability and stock monitoring.

The business should also examine whether customers purchasing these products can be targeted with complementary products through:

- cross-selling,
- bundles,
- recommendations,
- and promotions.

---

# 9. Customer Performance

Customer-level analysis identifies the highest-value customers by total sales.

Examples include:

| Customer | Segment | Total Sales |
|---|---|---:|
| Priya Singh | Corporate | 174,902.05 |
| Sneha Kumar | Corporate | 167,934.47 |
| Priya Khan | Corporate | 167,181.18 |
| Rohan Khan | Corporate | 160,888.75 |
| Aisha Reddy | Corporate | 156,787.42 |

## Key Insight

Several of the highest-value customers belong to the **Corporate segment**.

This is consistent with the broader segment analysis showing Corporate as the largest segment by total sales.

## Business Recommendation

High-value customers should be considered for retention programs such as:

- loyalty incentives,
- personalized offers,
- priority service,
- targeted promotions,
- account-management programs,
- and churn monitoring.

Customer concentration should also be monitored to ensure that revenue is not excessively dependent on a small number of customers.

---

# 10. Returns Analysis

The validated return dataset contains:

```text
Total Returns       : 799
Total Refund Amount : 416,961.18
Return Rate         : 7.99%
Refund-to-Sales     : 5.99%
```

Refunds reduced gross sales from:

```text
6,966,436.99
```

to net sales after refunds of:

```text
6,549,475.81
```

## Key Insight

Refunds represent approximately **5.99% of gross sales**, which makes returns financially significant.

Return analysis therefore should not be treated only as an operational metric.

It directly affects realized revenue and profitability.

---

# 11. Returns by Category

Category-level return analysis showed:

| Category | Returns | Refund Amount | Average Refund | Avg Days to Return |
|---|---:|---:|---:|---:|
| Grocery | 142 | 815,227.00 | 5,781.75 | 14.54 |
| Household | 130 | 732,566.43 | 5,635.13 | 15.28 |
| Snacks | 127 | 689,811.17 | 5,431.58 | 17.09 |
| Electronics | 133 | 671,014.34 | 5,045.22 | 14.73 |
| Beverages | 129 | 659,797.72 | 5,114.71 | 14.81 |
| Personal Care | 138 | 601,195.52 | 4,356.49 | 16.37 |

## Key Insight

Grocery showed the highest aggregate refund amount in the category-level return analysis.

Return timing generally falls around two weeks after purchase across the major categories.

Some individual returned transactions also showed very high refund impact percentages, meaning a substantial portion of the original transaction value was refunded.

## Business Recommendation

The business should monitor returns using both:

```text
Return Count
+
Refund Value
```

A category with fewer returns can still create a large financial impact if the average refund value is high.

Product-level return investigation should focus on:

- frequently returned products,
- high-refund products,
- high refund-to-sales percentages,
- suppliers,
- quality issues,
- incorrect product descriptions,
- and fulfillment problems.

---

# 12. Profitability Analysis

Overall profitability remained relatively stable.

Annual margins were:

```text
2022 → 19.23%
2023 → 19.45%
2024 → 19.56%
2025 → 19.13%
```

## Key Insight

Despite fluctuations in revenue, annual margins remained close to approximately 19%.

This suggests that the company's major challenge during the analyzed period was not a collapse in gross profitability but rather maintaining and growing sales volume.

However, 2025's margin decreased from 2024:

```text
19.56% → 19.13%
```

This movement should be monitored.

## Business Recommendation

Management should investigate whether the 2025 margin decline was caused by:

- increased discounts,
- product mix changes,
- higher low-margin category sales,
- pricing changes,
- or other transaction-level factors.

---

# 13. Sales Concentration

The four primary regions contribute different amounts to overall sales.

West and South together account for a substantial portion of business revenue.

Similarly, Corporate and Home Office account for a large share of sales across customer segments.

## Business Implication

This concentration creates both opportunity and risk.

Strong regions and segments can be used to protect near-term revenue, while lower-performing regions offer potential expansion opportunities.

Management should balance:

```text
Protecting strong markets
        +
Developing weaker markets
```

rather than focusing entirely on one side.

---

# 14. Data Quality Insight

The analysis also uncovered an important data-quality issue:

```text
1 sales transaction had a missing Order_Date.
```

The transaction remained part of overall financial totals but was excluded from analyses requiring a valid date.

This explains why a NULL year initially appeared in annual analysis.

## Business Recommendation

Future production pipelines should implement validation rules that flag missing transaction dates before data reaches the reporting layer.

This prevents incomplete dates from affecting:

- monthly reports,
- annual reports,
- trend calculations,
- YoY growth,
- and forecasting.

---

# 15. Major Business Findings

The analysis supports the following main findings:

### 1. Sales recovered gradually after a 2023 decline

2023 sales fell approximately **6.39%**, followed by moderate growth in 2024 and 2025.

### 2. West is the largest sales region

West generated approximately **2.17 million** in sales and the highest absolute regional profit.

### 3. Corporate is the largest customer segment by revenue

Corporate generated approximately **2.51 million** in sales.

### 4. Grocery drives revenue

Grocery generated the highest category sales.

### 5. Electronics demonstrates strong profitability

Electronics produced an approximately **21.92% profit margin**, higher than the other major categories shown in the analysis.

### 6. Returns materially affect realized sales

Approximately **416,961.18** was refunded, equivalent to about **5.99% of gross sales**.

### 7. Customer performance is uneven

The highest-value customers generate significantly more sales than the average customer.

### 8. Profit margins remained relatively stable

Annual profit margins stayed near 19%, despite changes in sales.

### 9. Data quality directly affects analytics

The missing Order_Date demonstrated why data validation must happen before time-series analysis.

---

# 16. Recommended Business Actions

Based on the analysis, the following actions should be considered:

1. **Investigate the 2023 sales decline** and identify the regions, segments, customers, and categories responsible.

2. **Protect West-region revenue** while identifying opportunities to reproduce successful West strategies in other regions.

3. **Strengthen Corporate customer retention** because Corporate is the largest revenue-generating customer segment.

4. **Develop Home Office opportunities**, given its strong customer count and order activity.

5. **Promote high-margin categories such as Electronics** while continuing to monitor total sales contribution.

6. **Review Personal Care and Beverages profitability** because their margins are comparatively lower.

7. **Implement product-level return monitoring** to identify products generating excessive refunds.

8. **Create retention strategies for high-value customers** using customer-level sales performance.

9. **Introduce automated data-quality checks** for missing dates, duplicate business keys, invalid relationships, and other critical fields.

10. **Use the reusable analytical views as the reporting layer** for future BI dashboards and reporting systems.

---

# 17. Suggested Management Dashboard

The analytical model can support a management dashboard containing the following sections.

## Executive KPIs

```text
Total Sales
Total Profit
Profit Margin
Orders
Customers
Units Sold
Returns
Refund Amount
Net Sales After Refunds
```

## Sales Trends

```text
Monthly Sales
Yearly Sales
YoY Growth
Monthly Profit
Profit Margin Trend
```

## Regional Analysis

```text
Sales by Region
Profit by Region
Customers by Region
Region × Segment Performance
```

## Product Analysis

```text
Sales by Category
Profit by Category
Top 10 Products
Product Profit Margin
Units Sold
```

## Customer Analysis

```text
Top Customers
Sales by Segment
Customer Order Frequency
Average Sales per Customer
```

## Return Analysis

```text
Returns by Category
Refund Amount by Category
Average Refund
Days to Return
High Refund Impact Transactions
```

---

# 18. SQL Techniques Demonstrated

This project demonstrates practical use of:

- Data profiling
- Data cleaning
- Deduplication
- NULL handling
- Date conversion
- Joins
- Aggregations
- GROUP BY
- HAVING
- CASE expressions
- CTEs
- Subqueries
- Window functions
- `LAG()`
- `DENSE_RANK()`
- Year-over-year analysis
- Views
- Stored procedures
- Indexing
- Composite unique indexes
- Referential-integrity validation
- Database QA
- Reconciliation testing
- Production-readiness checks

---

# 19. Business Questions Answered

The project answers business questions such as:

**How much revenue and profit did the business generate?**

Gross sales were approximately **6.97 million**, generating approximately **1.35 million in profit**.

**Which region generated the highest sales?**

West.

**Which customer segment generated the highest sales?**

Corporate.

**Which category generated the highest revenue?**

Grocery.

**Which major category showed the strongest profit margin in the category analysis?**

Electronics.

**Who are the highest-value customers?**

Customer-performance analysis identified customers such as Priya Singh, Sneha Kumar, Priya Khan, and others among the highest sales contributors.

**How did sales change over time?**

Sales declined in 2023 and subsequently returned to modest positive growth in 2024 and 2025.

**How significant are returns?**

799 valid returns generated approximately **416,961.18** in refunds.

**How much revenue remains after refunds?**

Approximately:

```text
6,549,475.81
```

---

# 20. Final Project Conclusion

The Supermart SQL Analytics project demonstrates an end-to-end SQL analytics workflow rather than a collection of isolated SQL queries.

The project began with raw customer, product, sales, and returns data and progressed through:

```text
Raw Data
   ↓
Data Profiling
   ↓
Data Cleaning
   ↓
Deduplication
   ↓
Data Validation
   ↓
Business Analysis
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
Production-Ready Database
```

The final database provides a validated analytical foundation for reporting and BI applications.

The most important business findings include strong West-region performance, Corporate-segment leadership, Grocery revenue strength, Electronics profitability, gradual sales recovery following the 2023 decline, and a meaningful financial impact from product returns.

Most importantly, the project demonstrates the ability to move beyond writing SQL queries and use SQL to transform raw transactional data into **validated, reusable and business-focused analytical insights**.