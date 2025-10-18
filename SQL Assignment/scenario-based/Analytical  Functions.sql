---1) Assign row numbers to customers ordered by credit limit descending

SELECT
  customer_id,
  credit_limit,
  ROW_NUMBER() OVER (ORDER BY credit_limit DESC NULLS LAST) AS rn_by_credit_desc
FROM customers;
```

-- 2) Rank customers within each state by credit limit
--sql
SELECT
  customer_id,
  state,
  credit_limit,
  RANK() OVER (PARTITION BY state ORDER BY credit_limit DESC NULLS LAST) AS rank_within_state
FROM customers;
```

--- 3) Use DENSE_RANK() to find the top 5 credit holders per country

```sql
SELECT *
FROM (
  SELECT
    customer_id,
    country,
    credit_limit,
    DENSE_RANK() OVER (PARTITION BY country ORDER BY credit_limit DESC NULLS LAST) AS dr
  FROM customers
) t
WHERE dr <= 5
ORDER BY country, credit_limit DESC;
```

--- 4) Divide customers into 4 quartiles based on their credit limit using NTILE(4)

```sql
SELECT
  customer_id,
  credit_limit,
  NTILE(4) OVER (ORDER BY credit_limit) AS quartile
FROM customers;
```

--- 5) Calculate a running total of credit limits ordered by customer_id

```sql
SELECT
  customer_id,
  credit_limit,
  SUM(credit_limit) OVER (ORDER BY customer_id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_by_id
FROM customers
ORDER BY customer_id;
```

--- 6) Show cumulative average credit limit by country

```sql
SELECT
  customer_id,
  country,
  credit_limit,
  AVG(credit_limit) OVER (
    PARTITION BY country
    ORDER BY customer_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cum_avg_by_country
FROM customers
ORDER BY country, customer_id;
```

--- 7) Compare each customer’s credit limit to the previous one using LAG()

```sql
SELECT
  customer_id,
  credit_limit,
  LAG(credit_limit) OVER (ORDER BY customer_id) AS prev_credit_limit
FROM customers
ORDER BY customer_id;
```

--- 8) Show next customer’s credit limit using LEAD()

```sql
SELECT
  customer_id,
  credit_limit,
  LEAD(credit_limit) OVER (ORDER BY customer_id) AS next_credit_limit
FROM customers
ORDER BY customer_id;
```

--- 9) Display the difference between each customer’s credit limit and the previous one

```sql
SELECT
  customer_id,
  credit_limit,
  credit_limit - LAG(credit_limit) OVER (ORDER BY customer_id) AS diff_from_prev
FROM customers
ORDER BY customer_id;
```

---10) For each country, display the first and last credit limit using FIRST_VALUE() and LAST_VALUE()

```sql
SELECT
  customer_id,
  country,
  credit_limit,
  FIRST_VALUE(credit_limit) OVER (
    PARTITION BY country
    ORDER BY customer_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS first_credit_in_country,
  LAST_VALUE(credit_limit) OVER (
    PARTITION BY country
    ORDER BY customer_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
  ) AS last_credit_in_country
FROM customers
ORDER BY country, customer_id;
```

--- 11) Compute percentage rank (PERCENT_RANK()) of customers based on credit limit

```sql
SELECT
  customer_id,
  credit_limit,
  PERCENT_RANK() OVER (ORDER BY credit_limit) AS pct_rank
FROM customers
ORDER BY credit_limit;
```

--- 12) Show each customer’s position in percentile (CUME_DIST() function)

```sql
SELECT
  customer_id,
  credit_limit,
  CUME_DIST() OVER (ORDER BY credit_limit) AS cume_dist_percentile
FROM customers
ORDER BY credit_limit;
```
--- 13) Display the difference between the maximum and current credit limit for each customer

```sql
SELECT
  customer_id,
  country,
  credit_limit,
  MAX(credit_limit) OVER (PARTITION BY country) - credit_limit AS diff_from_country_max
FROM customers;
```

---14) Rank income levels by their average credit limit

```sql
SELECT
  income_level,
  AVG(credit_limit) AS avg_credit_limit,
  RANK() OVER (ORDER BY AVG(credit_limit) DESC) AS income_level_rank
FROM customers
GROUP BY income_level
ORDER BY avg_credit_limit DESC;
```

--15) Calculate the average credit limit over the last 10 customers (sliding window)

(ordered by `customer_id`; change ordering column if you prefer time-based order)

```sql
SELECT
  customer_id,
  credit_limit,
  AVG(credit_limit) OVER (ORDER BY customer_id ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS avg_last_10
FROM customers
ORDER BY customer_id;
```

---16) For each state, calculate the cumulative total of credit limits ordered by city

```sql
SELECT
  customer_id,
  state,
  city,
  credit_limit,
  SUM(credit_limit) OVER (
    PARTITION BY state
    ORDER BY city, customer_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cum_total_by_state_city
FROM customers
ORDER BY state, city, customer_id;
```

---17) Find customers whose credit limit equals the median credit limit (use PERCENTILE_CONT(0.5))

(Overall median)

```sql
WITH median_cte AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY credit_limit) AS median_credit
  FROM customers
)
SELECT c.*
FROM customers c
CROSS JOIN median_cte m
WHERE c.credit_limit = m.median_credit;
```

(Per country median example)

```sql
WITH med_by_country AS (
  SELECT
    country,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY credit_limit) AS median_credit
  FROM customers
  GROUP BY country
)
SELECT c.*
FROM customers c
JOIN med_by_country m ON c.country = m.country
WHERE c.credit_limit = m.median_credit;
```

----18) Display the highest 3 credit holders per state using ROW_NUMBER() and PARTITION BY

```sql
SELECT *
FROM (
  SELECT
    customer_id,
    state,
    credit_limit,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY credit_limit DESC NULLS LAST) AS rn
  FROM customers
) t
WHERE rn <= 3
ORDER BY state, credit_limit DESC;
```

---19) Identify customers whose credit limit increased compared to previous row (using LAG)

```sql
SELECT
  customer_id,
  credit_limit,
  LAG(credit_limit) OVER (ORDER BY customer_id) AS prev_credit,
  CASE
    WHEN credit_limit > LAG(credit_limit) OVER (ORDER BY customer_id) THEN TRUE
    ELSE FALSE
  END AS increased_vs_prev
FROM customers
ORDER BY customer_id;
```

--- 20) Calculate moving average of credit limits with a window of 3

```sql
SELECT
  customer_id,
  credit_limit,
  AVG(credit_limit) OVER (ORDER BY customer_id ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3
FROM customers
ORDER BY customer_id;
```

--- 21) Show cumulative percentage of total credit limit per country

```sql
SELECT
  customer_id,
  country,
  credit_limit,
  SUM(credit_limit) OVER (
    PARTITION BY country
    ORDER BY credit_limit DESC
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) / SUM(credit_limit) OVER (PARTITION BY country) * 100.0 AS cum_pct_of_country_total
FROM customers
ORDER BY country, credit_limit DESC;
```

---22) Rank customers by age (derived from CUST_YEAR_OF_BIRTH)

```sql
SELECT
  customer_id,
  cust_year_of_birth,
  (EXTRACT(YEAR FROM CURRENT_DATE)::INT - cust_year_of_birth) AS age,
  RANK() OVER (ORDER BY (EXTRACT(YEAR FROM CURRENT_DATE)::INT - cust_year_of_birth) DESC) AS age_rank_desc
FROM customers
WHERE cust_year_of_birth IS NOT NULL
ORDER BY age DESC;
```

---23) Calculate difference in age between current and previous customer in the same state

```sql
SELECT
  customer_id,
  state,
  cust_year_of_birth,
  (EXTRACT(YEAR FROM CURRENT_DATE)::INT - cust_year_of_birth) AS age,
  ( (EXTRACT(YEAR FROM CURRENT_DATE)::INT - cust_year_of_birth)
    - LAG(EXTRACT(YEAR FROM CURRENT_DATE)::INT - cust_year_of_birth) OVER (PARTITION BY state ORDER BY customer_id)
  ) AS age_diff_vs_prev_in_state
FROM customers
WHERE cust_year_of_birth IS NOT NULL
ORDER BY state, customer_id;
```

---24) Use RANK() and DENSE_RANK() to show how ties are treated differently

```sql
SELECT
  customer_id,
  state,
  credit_limit,
  RANK() OVER (PARTITION BY state ORDER BY credit_limit DESC)      AS rnk_in_state,
  DENSE_RANK() OVER (PARTITION BY state ORDER BY credit_limit DESC) AS dense_rnk_in_state
FROM customers
ORDER BY state, credit_limit DESC;
```

----25) Compare each state’s average credit limit with country average using window partition

```sql
SELECT DISTINCT
  state,
  country,
  AVG(credit_limit) OVER (PARTITION BY state) AS avg_by_state,
  AVG(credit_limit) OVER (PARTITION BY country) AS avg_by_country,
  AVG(credit_limit) OVER (PARTITION BY state) - AVG(credit_limit) OVER (PARTITION BY country) AS state_minus_country_avg
FROM customers;
```

---- 26) Show total credit per state and also its rank within each country

```sql
WITH state_totals AS (
  SELECT
    country,
    state,
    SUM(credit_limit) AS total_credit,
    COUNT(*) AS customer_count
  FROM customers
  GROUP BY country, state
)
SELECT
  country,
  state,
  total_credit,
  customer_count,
  RANK() OVER (PARTITION BY country ORDER BY total_credit DESC) AS state_rank_within_country
FROM state_totals
ORDER BY country, state_rank_within_country;
```

----27) Find customers whose credit limit is above the 90th percentile of their income level

```sql
SELECT *
FROM (
  SELECT
    c.*,
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY credit_limit) OVER (PARTITION BY income_level) AS p90_by_income
  FROM customers c
) t
WHERE credit_limit > p90_by_income;
```
--- 28) Display top 3 and bottom 3 customers per country by credit limit

```sql
-- top 3 per country
SELECT *
FROM (
  SELECT
    customer_id, country, credit_limit,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY credit_limit DESC NULLS LAST) AS rn_top
  FROM customers
) t
WHERE rn_top <= 3
ORDER BY country, credit_limit DESC;

-- bottom 3 per country
SELECT *
FROM (
  SELECT
    customer_id, country, credit_limit,
    ROW_NUMBER() OVER (PARTITION BY country ORDER BY credit_limit ASC NULLS FIRST) AS rn_bottom
  FROM customers
) t
WHERE rn_bottom <= 3
ORDER BY country, credit_limit ASC;
```

---29) Calculate rolling sum of 5 customers’ credit limit within each country

(ordered by `customer_id`)

```sql
SELECT
  customer_id,
  country,
  credit_limit,
  SUM(credit_limit) OVER (
    PARTITION BY country
    ORDER BY customer_id
    ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
  ) AS rolling_sum_5_by_country
FROM customers
ORDER BY country, customer_id;
```

--30) For each marital status, display the most and least wealthy customers using analytical functions

(returns one most and one least per marital_status; ties handled by ROW_NUMBER)

```sql
WITH ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY marital_status ORDER BY credit_limit DESC NULLS LAST) AS rn_most,
    ROW_NUMBER() OVER (PARTITION BY marital_status ORDER BY credit_limit ASC NULLS FIRST) AS rn_least
  FROM customers
)
SELECT
  marital_status,
  'most' AS which,
  customer_id,
  credit_limit
FROM ranked
WHERE rn_most = 1

UNION ALL

SELECT
  marital_status,
  'least' AS which,
  customer_id,
  credit_limit
FROM ranked
WHERE rn_least = 1

ORDER BY marital_status, which;
```