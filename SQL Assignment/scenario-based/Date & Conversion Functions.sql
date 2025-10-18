---

### 1️⃣ Convert `CUST_YEAR_OF_BIRTH` to **age as of today**

```sql
SELECT
  customer_id,
  cust_year_of_birth,
  EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth AS age
FROM customers
WHERE cust_year_of_birth IS NOT NULL;
```

> `EXTRACT(YEAR FROM CURRENT_DATE) - cust_year_of_birth AS age`

---

### 2️⃣ Display all customers **born between 1980 and 1990**

```sql
SELECT
  customer_id,
  cust_year_of_birth
FROM customers
WHERE cust_year_of_birth BETWEEN 1980 AND 1990
ORDER BY cust_year_of_birth;
```

---

### 3️⃣ Format date of birth into “Month YYYY” using `TO_CHAR`

```sql
SELECT
  customer_id,
  TO_CHAR(date_of_birth, 'Month YYYY') AS formatted_birth_date
FROM customers
WHERE date_of_birth IS NOT NULL;
```


---

### 4️⃣ Convert income level text (like `'A: Below 30,000'`) to **numeric lower limit**


SELECT
  customer_id,
  income_level,
  CASE
    WHEN income_level LIKE '%Below 30,000%' THEN 0
    WHEN income_level LIKE '%30,000%' THEN 30000
    WHEN income_level LIKE '%50,000%' THEN 50000
    WHEN income_level LIKE '%70,000%' THEN 70000
    ELSE NULL
  END AS income_lower_limit
FROM customers;
```

---

### 5️⃣ Display customer **birth decades** (e.g., 1960s, 1970s, etc.)

```sql
SELECT
  customer_id,
  cust_year_of_birth,
  TRUNC(cust_year_of_birth / 10) * 10 || 's' AS birth_decade
FROM customers
WHERE cust_year_of_birth IS NOT NULL;
```


---

### 6️⃣ Show customers **grouped by age bracket (10-year intervals)**

```sql
SELECT
  FLOOR((EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth) / 10) * 10 AS age_bracket_start,
  COUNT(*) AS num_customers
FROM customers
WHERE cust_year_of_birth IS NOT NULL
GROUP BY FLOOR((EXTRACT(YEAR FROM SYSDATE) - cust_year_of_birth) / 10) * 10
ORDER BY age_bracket_start;
```

---

### 7️⃣ Convert `country_id` to **UPPERCASE** and state name to **lowercase**

```sql
SELECT
  customer_id,
  UPPER(country_id) AS country_upper,
  LOWER(state)      AS state_lower
FROM customers;
```

---

### 8️⃣ Show customers where **credit limit > average of their birth decade**

```sql
WITH decade_avg AS (
  SELECT
    TRUNC(cust_year_of_birth / 10) * 10 AS birth_decade,
    AVG(credit_limit) AS avg_decade_credit
  FROM customers
  WHERE cust_year_of_birth IS NOT NULL
  GROUP BY TRUNC(cust_year_of_birth / 10) * 10
)
SELECT
  c.customer_id,
  c.cust_year_of_birth,
  TRUNC(c.cust_year_of_birth / 10) * 10 AS birth_decade,
  c.credit_limit,
  d.avg_decade_credit
FROM customers c
JOIN decade_avg d
  ON TRUNC(c.cust_year_of_birth / 10) * 10 = d.birth_decade
WHERE c.credit_limit > d.avg_decade_credit;
```

---

### 9️⃣ Convert all numeric credit limits to **currency format `$999,999.00`**

```sql
SELECT
  customer_id,
  TO_CHAR(credit_limit, '$999,999.00') AS credit_limit_currency
FROM customers;
```



---

### 🔟 Find customers whose credit limit was NULL and replace with **average (using NVL)**

```sql
WITH avg_cte AS (
  SELECT AVG(credit_limit) AS avg_credit FROM customers
)
SELECT
  customer_id,
  NVL(credit_limit, (SELECT avg_credit FROM avg_cte)) AS adjusted_credit_limit
FROM customers;
```