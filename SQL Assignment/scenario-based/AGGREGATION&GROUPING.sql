--# SQL queries — analytics over `customers` table




### 1) Total, average, minimum, and maximum credit limit of all customers

```sql
SELECT
  COUNT(*)                     AS num_customers,
  SUM(credit_limit)            AS total_credit_limit,
  AVG(credit_limit)            AS avg_credit_limit,
  MIN(credit_limit)            AS min_credit_limit,
  MAX(credit_limit)            AS max_credit_limit
FROM customers;
```

---

### 2) Count the number of customers in each income level

```sql
SELECT
  income_level,
  COUNT(*) AS customer_count
FROM customers
GROUP BY income_level
ORDER BY customer_count DESC;
```

---

### 3) Total credit limit by state and country

```sql
SELECT
  country,
  state,
  SUM(credit_limit) AS total_credit_limit,
  COUNT(*)          AS customer_count
FROM customers
GROUP BY country, state
ORDER BY country, total_credit_limit DESC;
```

---

### 4) Average credit limit for each marital status and gender combination

```sql
SELECT
  marital_status,
  gender,
  AVG(credit_limit) AS avg_credit_limit,
  COUNT(*)          AS customer_count
FROM customers
GROUP BY marital_status, gender
ORDER BY avg_credit_limit DESC;
```

---

### 5) Top 3 states with the highest average credit limit

```sql
SELECT
  state,
  country,
  AVG(credit_limit) AS avg_credit_limit,
  COUNT(*)          AS customer_count
FROM customers
GROUP BY state, country
HAVING COUNT(*) > 0
ORDER BY avg_credit_limit DESC
LIMIT 3;
```

---

### 6) Country with the maximum total customer credit limit

```sql
SELECT
  country,
  SUM(credit_limit) AS total_credit_limit
FROM customers
GROUP BY country
ORDER BY total_credit_limit DESC
LIMIT 1;
```

---

### 7) Number of customers whose credit limit exceeds their state average

```sql
SELECT COUNT(*) AS customers_above_state_avg
FROM (
  SELECT
    customer_id,
    credit_limit,
    AVG(credit_limit) OVER (PARTITION BY state) AS state_avg
  FROM customers
) t
WHERE credit_limit IS NOT NULL
  AND credit_limit > state_avg;
```

---

### 8) Total and average credit limit for customers born after 1980

If you have `birth_date` (DATE):

```sql
SELECT
  COUNT(*)                   AS customer_count,
  SUM(credit_limit)          AS total_credit_limit,
  AVG(credit_limit)          AS avg_credit_limit
FROM customers
WHERE birth_date > DATE '1980-12-31';
```

If you have `year_of_birth` (INT):

```sql
SELECT
  COUNT(*)                   AS customer_count,
  SUM(credit_limit)          AS total_credit_limit,
  AVG(credit_limit)          AS avg_credit_limit
FROM customers
WHERE year_of_birth > 1980;
```

---

### 9) Find states having more than 50 customers

```sql
SELECT
  state,
  COUNT(*) AS customer_count
FROM customers
GROUP BY state
HAVING COUNT(*) > 50
ORDER BY customer_count DESC;
```

---

### 10) List countries where the average credit limit is higher than the global average

```sql
WITH global_avg AS (
  SELECT AVG(credit_limit) AS global_avg FROM customers
),
country_avg AS (
  SELECT country, AVG(credit_limit) AS avg_credit_limit
  FROM customers
  GROUP BY country
)
SELECT
  ca.country,
  ca.avg_credit_limit,
  ga.global_avg
FROM country_avg ca
CROSS JOIN global_avg ga
WHERE ca.avg_credit_limit > ga.global_avg
ORDER BY ca.avg_credit_limit DESC;
```

---

### 11) Variance and standard deviation of customer credit limits by country

(uses population variance/stddev; change to `VAR_SAMP` / `STDDEV_SAMP` if sample stats are desired)

```sql
SELECT
  country,
  VAR_POP(credit_limit)    AS variance_pop,
  STDDEV_POP(credit_limit) AS stddev_pop,
  COUNT(*)                 AS customer_count
FROM customers
GROUP BY country
ORDER BY stddev_pop DESC;
```

---

### 12) Find the state with the smallest range (max – min) in credit limits

```sql
SELECT
  state,
  MAX(credit_limit) - MIN(credit_limit) AS credit_range,
  COUNT(*)                              AS customer_count
FROM customers
GROUP BY state
HAVING COUNT(*) > 0
ORDER BY credit_range ASC
LIMIT 1;
```

---

### 13) Total number of customers per income level and percentage contribution of each

```sql
WITH totals AS (
  SELECT COUNT(*) AS total_customers FROM customers
)
SELECT
  c.income_level,
  COUNT(*) AS customer_count,
  ROUND(100.0 * COUNT(*) / t.total_customers, 2) AS pct_of_total
FROM customers c
CROSS JOIN totals t
GROUP BY c.income_level, t.total_customers
ORDER BY customer_count DESC;
```

---

### 14) For each income level, how many customers have NULL credit limits

```sql
SELECT
  income_level,
  COUNT(*) AS null_credit_count
FROM customers
WHERE credit_limit IS NULL
GROUP BY income_level
ORDER BY null_credit_count DESC;
```

---

### 15) Display countries where the sum of credit limits exceeds 10 million

(adjust threshold if currency/units differ)

```sql
SELECT
  country,
  SUM(credit_limit) AS total_credit_limit,
  COUNT(*)          AS customer_count
FROM customers
GROUP BY country
HAVING SUM(credit_limit) > 10000000
ORDER BY total_credit_limit DESC;
```

---

### 16) Find the state that contributes the highest total credit limit to its country

(Returns one or more states per country in case of ties)

```sql
SELECT country, state, total_credit
FROM (
  SELECT
    country,
    state,
    SUM(credit_limit) AS total_credit,
    RANK() OVER (PARTITION BY country ORDER BY SUM(credit_limit) DESC) AS rnk
  FROM customers
  GROUP BY country, state
) t
WHERE rnk = 1
ORDER BY country;
```

---

### 17) Show total credit limit per year of birth, sorted by total descending

(if `birth_date` exists)

```sql
SELECT
  EXTRACT(YEAR FROM birth_date)::INT AS year_of_birth,
  SUM(credit_limit) AS total_credit_limit,
  COUNT(*)          AS customer_count
FROM customers
WHERE birth_date IS NOT NULL
GROUP BY year_of_birth
ORDER BY total_credit_limit DESC;
```

(if only `year_of_birth` exists)

```sql
SELECT
  year_of_birth,
  SUM(credit_limit) AS total_credit_limit,
  COUNT(*)          AS customer_count
FROM customers
WHERE year_of_birth IS NOT NULL
GROUP BY year_of_birth
ORDER BY total_credit_limit DESC;
```

---

### 18) Identify customers who hold the maximum credit limit in their respective country

(Returns all customers tied for country maximum)

```sql
SELECT c.*
FROM customers c
JOIN (
  SELECT country, MAX(credit_limit) AS max_credit
  FROM customers
  GROUP BY country
) m
  ON c.country = m.country
 AND c.credit_limit = m.max_credit;
```

---

### 19) Show the difference between maximum and average credit limit per country

```sql
SELECT
  country,
  MAX(credit_limit)               AS max_credit_limit,
  AVG(credit_limit)               AS avg_credit_limit,
  (MAX(credit_limit) - AVG(credit_limit)) AS max_minus_avg
FROM customers
GROUP BY country
ORDER BY max_minus_avg DESC;
```

---

### 20) Display the overall rank of each state based on its total credit limit

(uses `GROUP BY` for totals and an analytic `RANK()` for overall ranking)

```sql
SELECT
  state,
  country,
  total_credit,
  RANK() OVER (ORDER BY total_credit DESC) AS overall_rank
FROM (
  SELECT state, country, SUM(credit_limit) AS total_credit
  FROM customers
  GROUP BY state, country
) s
ORDER BY overall_rank;