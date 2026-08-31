# projects-1
my sql and power bi projects 
# Healthcare & Retail Data Analytics Portfolio: SQL + Power BI 📊💼

Welcome to my data analytics portfolio! This repository demonstrates my full-stack capabilities in data manipulation, advanced querying, and dashboard design. I leverage **Advanced SQL** for backend extraction, data cleaning, and complex business logic, paired with **Power BI** for visual storytelling.

---

## 💻 SQL Case Study: Hospital & Pharmaceutical Sales Analysis
**File:** `sql project....sql`

This project features a comprehensive script analyzing pharmaceutical sales datasets across metrics like cities, therapeutic areas, sales representatives, and financial metrics.

### 🔹 Core Technical Competencies Demonstrated:
*   **Window Functions & Partitioning:** Utilized `RANK() OVER (PARTITION BY ...)` to determine top sales reps within localized geographic territories and specialized therapeutic areas.
*   **Time-Series & Trend Analysis:** Implemented `LAG()` over monthly date fields to calculate **Month-over-Month (MoM) revenue growth percentages** and running totals.
*   **Conditional Segmenting:** Wrote robust `CASE WHEN` logical expressions to categorize business metrics by transaction discount values and high/medium/low financial revenue brackets.
*   **Advanced Filtering:** Leveraged `HAVING` clauses alongside structural multi-table **Common Table Expressions (CTEs)** to filter aggregate data fields dynamically.

### 🔍 Featured SQL Architecture Snippet

Here is an example from my script calculating **Month-over-Month Growth** using an advanced CTE and nested window functions:

```sql
WITH month_o_month AS (
    SELECT 
        TO_CHAR(order_date, 'mon') AS order_month,
        EXTRACT(MONTH FROM order_date) AS month_num,
        SUM(revenue) AS current_month_revenue
    FROM hospital
    GROUP BY TO_CHAR(order_date, 'mon'), EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month,
    current_month_revenue,
    LAG(current_month_revenue) OVER (ORDER BY month_num) AS previous_month_revenue,
    ((current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY month_num)) / 
      LAG(current_month_revenue) OVER (ORDER BY month_num)) * 100 AS mom_growth
FROM month_o_month
ORDER BY month_num;
```

---

## 👥 Power BI Project 1: XYZ Group Business Performance Dashboard
**File:** `XYZ Group.pbix`  
An executive-level operational dashboard exploring general sales performance, payment channels, and volume splits across geographic boundaries.

### 🔹 Key KPIs Tracked
*   **Total Gross Revenue:** \$136.01M
*   **Total Orders:** 10K
*   **Total Quantity Sold:** 39K

### 🔹 Core Insights & Visualizations
*   **Macro Trends:** Revenue peaked over **\$50M** in 2024, followed by structural shifts heading into 2026.
*   **Regional Performance:** **Delhi** and **Jaipur** lead local revenue generation; the **East** region drives overall volume with 3.4K distinct orders.
*   **Payment Vehicles:** **UPI** is the dominant transaction channel, capturing **39.79%** of the user base.

---

## 🏬 Power BI Project 2: Super Stores Sales & Profitability Analysis
**File:** `NEW SUPER SOTRES.pbix`  
A retail dashboard deep-dive identifying seasonal trends, organizational logistics, and gross profit tracking.

### 🔹 Key KPIs Tracked
*   **Total Sales:** \$1.57M
*   **Total Profit:** \$175.26K
*   **Total Orders:** 5.901K

### 🔹 Core Insights & Visualizations
*   **Seasonal Volatility:** Highlights a massive operational volume spike concentrated in **March**.
*   **Demographic Share:** **Consumer** profiles command the vast majority of target markets (**48%** share).
*   **Logistics Framework:** **Standard Class** delivery remains the favored shipping tier among purchasing clients.

---

## 🛠️ Tech Stack & Skills Used
*   **Languages:** SQL (PostgreSQL/SQL Server syntax)
*   **Tools:** Power BI Desktop, Power Query, DAX
*   **Analytical Frameworks:** Cohort Segmentation, Time-Series Analysis, Financial KPI Auditing, Pareto-Style Mix Testing

