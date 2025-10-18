---
--- 1️⃣ Show customers whose **first and last name start with the same letter**

```sql
SELECT
  customer_id,
  first_name,
  last_name
FROM customers
WHERE UPPER(SUBSTR(first_name, 1, 1)) = UPPER(SUBSTR(last_name, 1, 1));
```

---

--- 2️⃣ Display full names in **“Last, First”** format

```sql
SELECT
  customer_id,
  last_name || ', ' || first_name AS full_name
FROM customers;
```


---

--- 3️⃣ Find customers whose **last name ends with 'SON'**


SELECT
  customer_id,
  first_name,
  last_name
FROM customers
WHERE UPPER(last_name) LIKE '%SON';


---

---4️⃣ Display **length of each customer’s full name**

```sql
SELECT
  customer_id,
  first_name,
  last_name,
  LENGTH(first_name || ' ' || last_name) AS full_name_length
FROM customers;
```

> 

---5️⃣ Replace **vowels** in customer names with `*`

```sql
SELECT
  customer_id,
  first_name,
  last_name,
  REGEXP_REPLACE(first_name || ' ' || last_name, '[AEIOUaeiou]', '*') AS masked_name
FROM customers;
```



---

### 6️⃣ Show customers whose **income level description contains ‘90’**

```sql
SELECT
  customer_id,
  income_level
FROM customers
WHERE income_level LIKE '%90%';
```

---

### 7️⃣ Display **initials** of each customer (first letters of first and last name)

```sql
SELECT
  customer_id,
  first_name,
  last_name,
  UPPER(SUBSTR(first_name, 1, 1)) || UPPER(SUBSTR(last_name, 1, 1)) AS initials
FROM customers;
```



---

### 8️⃣ Concatenate **city and state** to create full address

```sql
SELECT
  customer_id,
  city,
  state,
  city || ', ' || state AS full_address
FROM customers;
```


---

-- 9️⃣ Extract numeric value from `income_level` using `REGEXP_SUBSTR`

(e.g., `'A: Below 30,000'` → `30000`)

```sql
SELECT
  customer_id,
  income_level,
  TO_NUMBER(REGEXP_SUBSTR(income_level, '[0-9]+')) AS numeric_value
FROM customers;
```



### 🔟 Count how many customers have a 3-letter first name**

```sql
SELECT
  COUNT(*) AS three_letter_firstnames
FROM customers
WHERE LENGTH(first_name) = 3;
```

---