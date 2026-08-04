# Retail Analytics Project

![Retail Analytics Banner](Retail_Analytics_Banner.png)

## Overview

This project is an end-to-end retail analytics report built in Power BI.

The aim was to simulate a real business reporting environment for a department store, where management could track sales, product performance, returns and inventory from one report.

The report is built around practical business questions, such as:

- How is revenue trending over time?
- Which products and categories are driving performance?
- Which products are underperforming?
- Where are returns coming from?
- Which stock items are healthy, low, or at risk?

The project uses Power Query for data cleaning, a star schema model for analysis, DAX measures for KPIs, and Power BI report pages designed around business decision-making.

---

## Tools Used
- Power BI
- Power Query
- DAX
- Excel
- Photoshop

---

## Report Pages

### Sales Overview
![Sales Overview](Sales%20Overview.jpg)

The Sales Overview page gives a high-level view of business performance. It shows total revenue, orders, average order value and customer count, then breaks revenue down by category, sales channel and location.

The purpose of this page is to help management quickly see whether sales are trending up or down, which categories and channels are driving revenue, and where sales activity is concentrated geographically.

---

### Product Performance
![Product Performance](Product%20Performance.jpg)

The Product Performance page focuses on how individual products and categories are performing.

It highlights the top products by revenue, the lowest revenue products, category-level performance, and the relationship between revenue and order volume. This helps identify which products are driving sales, which products may need attention, and whether performance is being driven by volume, value, or both.

---

### Returns Analysis
![Returns Analysis](Returns%20Analysis.jpg)

The Returns Analysis page shows how returns are affecting the business.

It tracks returned units, return rate, return value and average days to return, then breaks returns down by category, channel and return reason. This helps identify where returns are concentrated and whether the issue is linked to product quality, customer behaviour, delivery problems or specific categories.

---

### Inventory Overview
![Inventory Overview](Inventory%20Overview.jpg)

The Inventory Overview page focuses on stock levels and inventory health.

It tracks total stock on hand, inventory value, low stock items and stock health percentage. The page also shows stock trends over time, current stock levels by product, and inventory value by category.

The purpose of this page is to help identify stock risk, low-stock products, and where the largest inventory value is held.

---

## Key Features
- Interactive report pages
- Power Query data cleaning and transformation
- Star schema data modelling
- DAX KPI measures
- Revenue, product, returns and inventory analysis
- Interactive slicers and filtering
- Business-focused reporting
- Professional dashboard design

---

## PostgreSQL SQL Analysis

To extend the Power BI project, I loaded the same retail model into PostgreSQL and wrote 10 business-focused queries covering sales, products, customers, returns and inventory.

The SQL analysis demonstrates:

- Joins, aggregations and date filtering
- GROUP BY, HAVING, ORDER BY and LIMIT
- Subqueries and conditional aggregation
- CASE, COALESCE and NULLIF
- CTEs and window functions
- Period comparisons and business-focused interpretation

[View the full business queries](SQL/02_business_queries.sql)

[View the data quality checks](SQL/01_data_quality_checks.sql)

---

## Selected SQL Results

### Category Sales and Profit — Latest 90 Days

<p align="center">
  <a href="Images/q01_category_performance.png">
    <img src="Images/q01_category_performance.png" width="600">
  </a>
</p>

**Key Finding:** Electronics dominated recent performance, generating €927,306.64 in net sales and €383,308.15 in profit.

### 2025 vs 2024 Category Performance

<p align="center">
  <a href="Images/q04_year_comparison.png">
    <img src="Images/q04_year_comparison.png" width="600">
  </a>
</p>

**Key Finding:** Electronics recorded the largest monetary decline, while DIY achieved the strongest year-on-year growth.

### Return Rate by Category

<p align="center">
  <a href="Images/q07_return_rate.png">
    <img src="Images/q07_return_rate.png" width="600">
  </a>
</p>

**Key Finding:** Fashion had the highest unit return rate, while Electronics generated the greatest refund value.

### Top Two Products Within Each Category

<p align="center">
  <a href="Images/q09_category_product_ranking.png">
    <img src="Images/q09_category_product_ranking.png" width="600">
  </a>
</p>

**Key Finding:** The category-level ranking identified each category’s leading products without allowing high-value Electronics products to dominate the entire result.

### Latest 90 Days vs Previous 90 Days

<p align="center">
  <a href="Images/q10_period_comparison.png">
    <img src="Images/q10_period_comparison.png" width="600">
  </a>
</p>

**Key Finding:** Most categories improved during the latest 90 days, while Baby declined by 23.97%.

---

## Author

Darragh Collins

[LinkedIn Profile](https://www.linkedin.com/in/darraghcollins)
