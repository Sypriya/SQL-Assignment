Here’s a **complete SQL script** using Oracle’s **SH (Sales History)** schema that performs **all the listed analytics** using `JOIN`, `GROUP BY`, and analytic functions:

---

```sql
-- 1️⃣ Join SH.CUSTOMERS and SH.SALES to find customers with highest sales totals
SELECT 
    c.cust_id,
    c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
    c.country_id,
    SUM(s.amount_sold) AS total_sales
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.cust_id, c.cust_first_name, c.cust_last_name, c.country_id
ORDER BY total_sales DESC;


-- 2️⃣ For each customer, show their total sales amount and rank within country
SELECT 
    c.country_id,
    c.cust_id,
    c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
    SUM(s.amount_sold) AS total_sales,
    RANK() OVER (PARTITION BY c.country_id ORDER BY SUM(s.amount_sold) DESC) AS country_rank
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.country_id, c.cust_id, c.cust_first_name, c.cust_last_name;


-- 3️⃣ Find customers who purchased more than average sales amount of their country
WITH cust_sales AS (
    SELECT 
        c.country_id,
        c.cust_id,
        SUM(s.amount_sold) AS total_sales
    FROM sh.customers c
    JOIN sh.sales s ON c.cust_id = s.cust_id
    GROUP BY c.country_id, c.cust_id
)
SELECT *
FROM cust_sales cs
WHERE cs.total_sales > (
    SELECT AVG(total_sales)
    FROM cust_sales c2
    WHERE c2.country_id = cs.country_id
)
ORDER BY cs.country_id, cs.total_sales DESC;


-- 4️⃣ Display top 3 spenders per state
SELECT *
FROM (
    SELECT 
        c.state_province,
        c.cust_id,
        c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
        SUM(s.amount_sold) AS total_sales,
        RANK() OVER (PARTITION BY c.state_province ORDER BY SUM(s.amount_sold) DESC) AS rnk
    FROM sh.customers c
    JOIN sh.sales s ON c.cust_id = s.cust_id
    GROUP BY c.state_province, c.cust_id, c.cust_first_name, c.cust_last_name
)
WHERE rnk <= 3
ORDER BY state_province, total_sales DESC;


-- 5️⃣ Rank customers within each country by total sales quantity
SELECT 
    c.country_id,
    c.cust_id,
    c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
    SUM(s.quantity_sold) AS total_qty,
    RANK() OVER (PARTITION BY c.country_id ORDER BY SUM(s.quantity_sold) DESC) AS qty_rank
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.country_id, c.cust_id, c.cust_first_name, c.cust_last_name;


-- 6️⃣ Calculate each customer’s contribution percentage to country-level sales
SELECT 
    c.country_id,
    c.cust_id,
    c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
    SUM(s.amount_sold) AS total_sales,
    ROUND(
        100 * SUM(s.amount_sold) / SUM(SUM(s.amount_sold)) OVER (PARTITION BY c.country_id),
        2
    ) AS contribution_pct
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.country_id, c.cust_id, c.cust_first_name, c.cust_last_name
ORDER BY c.country_id, contribution_pct DESC;


-- 7️⃣ Identify customers whose sales have decreased compared to previous month
WITH monthly_sales AS (
    SELECT 
        c.cust_id,
        TRUNC(s.time_id, 'MM') AS month,
        SUM(s.amount_sold) AS monthly_sales,
        LAG(SUM(s.amount_sold)) OVER (PARTITION BY c.cust_id ORDER BY TRUNC(s.time_id, 'MM')) AS prev_month_sales
    FROM sh.customers c
    JOIN sh.sales s ON c.cust_id = s.cust_id
    GROUP BY c.cust_id, TRUNC(s.time_id, 'MM')
)
SELECT *
FROM monthly_sales
WHERE monthly_sales < prev_month_sales;


-- 8️⃣ Show customers who have never made a sale
SELECT c.cust_id, c.cust_first_name, c.cust_last_name
FROM sh.customers c
LEFT JOIN sh.sales s ON c.cust_id = s.cust_id
WHERE s.cust_id IS NULL;


-- 9️⃣ Find correlation between credit limit and total sales
SELECT 
    CORR(total_sales, credit_limit) AS corr_credit_sales
FROM (
    SELECT 
        c.cust_id,
        c.credit_limit,
        SUM(s.amount_sold) AS total_sales
    FROM sh.customers c
    JOIN sh.sales s ON c.cust_id = s.cust_id
    GROUP BY c.cust_id, c.credit_limit
);


-- 🔟 Show moving average of monthly sales per customer
SELECT 
    c.cust_id,
    TRUNC(s.time_id, 'MM') AS month,
    SUM(s.amount_sold) AS monthly_sales,
    ROUND(
        AVG(SUM(s.amount_sold)) OVER (
            PARTITION BY c.cust_id ORDER BY TRUNC(s.time_id, 'MM')
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_avg_3_month
FROM sh.customers c
JOIN sh.sales s ON c.cust_id = s.cust_id
GROUP BY c.cust_id, TRUNC(s.time_id, 'MM')
ORDER BY c.cust_id, month;
```

---