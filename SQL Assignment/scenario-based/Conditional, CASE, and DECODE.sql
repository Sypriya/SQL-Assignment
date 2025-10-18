---

### 1️⃣ Categorize customers into income tiers: Platinum, Gold, Silver, Bronze

```sql
SELECT
  customer_id,
  income_level,
  CASE
    WHEN income_level IN ('A', 'B') THEN 'Platinum'
    WHEN income_level IN ('C', 'D') THEN 'Gold'
    WHEN income_level IN ('E', 'F') THEN 'Silver'
    ELSE 'Bronze'
  END AS income_tier
FROM customers;
```

> *(Adjust letter ranges to match your actual income-level coding.)*

---

### 2️⃣ Display “High”, “Medium”, or “Low” income categories based on credit limit

```sql
SELECT
  customer_id,
  credit_limit,
  CASE
    WHEN credit_limit >= 100000 THEN 'High'
    WHEN credit_limit BETWEEN 50000 AND 99999 THEN 'Medium'
    ELSE 'Low'
  END AS credit_category
FROM customers;
```

---

### 3️⃣ Replace NULL income levels with “Unknown” using NVL (or COALESCE)

```sql
SELECT
  customer_id,
  NVL(income_level, 'Unknown') AS income_level
FROM customers;
```

> **PostgreSQL equivalent:** `COALESCE(income_level, 'Unknown')`

---

### 4️⃣ Show customer details and mark whether they have above-average credit limit

```sql
WITH avg_cte AS (
  SELECT AVG(credit_limit) AS avg_credit FROM customers
)
SELECT
  c.customer_id,
  c.credit_limit,
  CASE
    WHEN c.credit_limit > a.avg_credit THEN 'Above Average'
    ELSE 'At or Below Average'
  END AS credit_category
FROM customers c
CROSS JOIN avg_cte a;
```

---

### 5️⃣ Use DECODE to convert marital status codes (S/M/D) into full text

*(Oracle syntax; for PostgreSQL/MySQL use CASE instead.)*

```sql
SELECT
  customer_id,
  marital_status,
  DECODE(marital_status,
         'S', 'Single',
         'M', 'Married',
         'D', 'Divorced',
         'Unknown') AS marital_status_full
FROM customers;
```

**PostgreSQL alternative (CASE):**

```sql
SELECT
  customer_id,
  marital_status,
  CASE marital_status
    WHEN 'S' THEN 'Single'
    WHEN 'M' THEN 'Married'
    WHEN 'D' THEN 'Divorced'
    ELSE 'Unknown'
  END AS marital_status_full
FROM customers;
```

---

### 6️⃣ Use CASE to show age group (≤30, 31–50, >50) from `cust_year_of_birth`

```sql
SELECT
  customer_id,
  cust_year_of_birth,
  EXTRACT(YEAR FROM CURRENT_DATE) - cust_year_of_birth AS age,
  CASE
    WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - cust_year_of_birth) <= 30 THEN '≤30'
    WHEN (EXTRACT(YEAR FROM CURRENT_DATE) - cust_year_of_birth) BETWEEN 31 AND 50 THEN '31–50'
    ELSE '>50'
  END AS age_group
FROM customers
WHERE cust_year_of_birth IS NOT NULL;
```

---

### 7️⃣ Label customers as “Old Credit Holder” or “New Credit Holder” based on year of birth < 1980

```sql
SELECT
  customer_id,
  cust_year_of_birth,
  CASE
    WHEN cust_year_of_birth < 1980 THEN 'Old Credit Holder'
    ELSE 'New Credit Holder'
  END AS holder_type
FROM customers;
```

---

### 8️⃣ Create a loyalty tag — “Premium” if credit limit > 50,000 **and** income_level = ‘E’

```sql
SELECT
  customer_id,
  income_level,
  credit_limit,
  CASE
    WHEN credit_limit > 50000 AND income_level = 'E' THEN 'Premium'
    ELSE 'Standard'
  END AS loyalty_tag
FROM customers;
```

---

### 9️⃣ Assign grades (A–F) based on credit limit range using CASE

```sql
SELECT
  customer_id,
  credit_limit,
  CASE
    WHEN credit_limit >= 100000 THEN 'A'
    WHEN credit_limit >= 75000  THEN 'B'
    WHEN credit_limit >= 50000  THEN 'C'
    WHEN credit_limit >= 25000  THEN 'D'
    WHEN credit_limit > 0       THEN 'E'
    ELSE 'F'
  END AS credit_grade
FROM customers;
```

---

### 🔟 Show country, state, and number of premium customers using conditional aggregation

(“Premium” defined as credit_limit > 50,000)

```sql
SELECT
  country,
  state,
  COUNT(*) AS total_customers,
  SUM(CASE WHEN credit_limit > 50000 THEN 1 ELSE 0 END) AS premium_customers,
  ROUND(100.0 * SUM(CASE WHEN credit_limit > 50000 THEN 1 ELSE 0 END) / COUNT(*), 2) AS premium_pct
FROM customers
GROUP BY country, state
ORDER BY country, state;
```

---