--------------------------------------------------------------------------------
-- 1) Display the top 5 customers with the highest credit limit
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit
FROM sh.customers
WHERE credit_limit IS NOT NULL
ORDER BY credit_limit DESC
FETCH FIRST 5 ROWS ONLY;         -- Oracle 12c+ syntax


--------------------------------------------------------------------------------
-- 2) Find customers having the same income level as the customer with the max credit limit
--------------------------------------------------------------------------------
WITH max_income AS (
    SELECT income_group
    FROM (
        SELECT income_group
        FROM sh.customers
        WHERE credit_limit IS NOT NULL
        ORDER BY credit_limit DESC
        FETCH FIRST 1 ROWS ONLY
    )
)
SELECT c.cust_id,
       c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
       c.income_group,
       c.credit_limit
FROM sh.customers c
JOIN max_income m ON (c.income_group = m.income_group)
ORDER BY c.credit_limit DESC;


--------------------------------------------------------------------------------
-- 3) Customers who have a credit limit higher than the average credit limit of all customers
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit
FROM (
    SELECT c.*,
           AVG(credit_limit) OVER () AS avg_credit_all
    FROM sh.customers c
)
WHERE credit_limit IS NOT NULL
  AND credit_limit > avg_credit_all
ORDER BY credit_limit DESC;


--------------------------------------------------------------------------------
-- 4) Rank all customers based on their credit limit in descending order and display rank along with name
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       RANK() OVER (ORDER BY credit_limit DESC NULLS LAST) AS credit_rank
FROM sh.customers
ORDER BY credit_rank;


--------------------------------------------------------------------------------
-- 5) Find customers who belong to the top 3 credit limit ranks in each income level
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       income_group,
       credit_limit,
       credit_rank_in_group
FROM (
    SELECT c.*,
           RANK() OVER (PARTITION BY COALESCE(income_group,'UNKNOWN') ORDER BY credit_limit DESC NULLS LAST)
               AS credit_rank_in_group
    FROM sh.customers c
)
WHERE credit_rank_in_group <= 3
ORDER BY income_group, credit_rank_in_group;


--------------------------------------------------------------------------------
-- 6) Categorize customers into "Platinum", "Gold", and "Standard" tiers based on credit_limit ranges
--    (Example ranges: Platinum >= 100000, Gold 50000-99999, Standard < 50000)
--    Adjust thresholds as required.
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       CASE
         WHEN credit_limit IS NULL THEN 'UNKNOWN'
         WHEN credit_limit >= 100000 THEN 'Platinum'
         WHEN credit_limit >= 50000  THEN 'Gold'
         ELSE 'Standard'
       END AS tier
FROM sh.customers
ORDER BY credit_limit DESC NULLS LAST;


--------------------------------------------------------------------------------
-- 7) Display each customer’s credit_limit along with the previous and next customer's limit
--    (ordered by credit_limit descending; ties handled by cust_id to make order deterministic)
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       LAG(credit_limit)  OVER (ORDER BY credit_limit DESC, cust_id) AS prev_credit_limit,
       LEAD(credit_limit) OVER (ORDER BY credit_limit DESC, cust_id) AS next_credit_limit
FROM sh.customers
ORDER BY credit_limit DESC NULLS LAST;


--------------------------------------------------------------------------------
-- 8) Find customers whose credit limit difference from the previous customer is more than 10,000
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       prev_credit_limit,
       ROUND(ABS(credit_limit - prev_credit_limit),2) AS diff_from_prev
FROM (
    SELECT c.*,
           LAG(credit_limit) OVER (ORDER BY credit_limit DESC, cust_id) AS prev_credit_limit
    FROM sh.customers c
)
WHERE prev_credit_limit IS NOT NULL
  AND ABS(credit_limit - prev_credit_limit) > 10000
ORDER BY diff_from_prev DESC;


--------------------------------------------------------------------------------
-- 9) Display the highest, lowest, and average credit limit per income level
--------------------------------------------------------------------------------
SELECT COALESCE(income_group,'UNKNOWN') AS income_group,
       MAX(credit_limit)   AS max_credit,
       MIN(credit_limit)   AS min_credit,
       ROUND(AVG(credit_limit),2) AS avg_credit,
       COUNT(*) AS customer_count
FROM sh.customers
WHERE credit_limit IS NOT NULL
GROUP BY COALESCE(income_group,'UNKNOWN')
ORDER BY avg_credit DESC;


--------------------------------------------------------------------------------
-- 10) Find the youngest and oldest customers (based on cust_year_of_birth)
--     (youngest = MAX(year_of_birth), oldest = MIN(year_of_birth))
--------------------------------------------------------------------------------
-- Youngest
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       cust_year_of_birth
FROM sh.customers
WHERE cust_year_of_birth = (SELECT MAX(cust_year_of_birth) FROM sh.customers WHERE cust_year_of_birth IS NOT NULL);

-- Oldest
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       cust_year_of_birth
FROM sh.customers
WHERE cust_year_of_birth = (SELECT MIN(cust_year_of_birth) FROM sh.customers WHERE cust_year_of_birth IS NOT NULL);


--------------------------------------------------------------------------------
-- 11) Display customers who belong to the same city as the customer "David Lee"
--     (Assumes cust_first_name = 'David' and cust_last_name = 'Lee'; case-sensitive as per DB)
--------------------------------------------------------------------------------
WITH david_city AS (
    SELECT city
    FROM sh.customers
    WHERE cust_first_name = 'David' AND cust_last_name = 'Lee'
    AND city IS NOT NULL
    FETCH FIRST 1 ROWS ONLY
)
SELECT c.cust_id,
       c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
       c.city,
       c.credit_limit
FROM sh.customers c
JOIN david_city d ON c.city = d.city
ORDER BY c.credit_limit DESC;


--------------------------------------------------------------------------------
-- 12) For each state, display the top 2 customers by credit limit
--------------------------------------------------------------------------------
SELECT state_province,
       cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       state_rank
FROM (
    SELECT c.*,
           RANK() OVER (PARTITION BY state_province ORDER BY credit_limit DESC NULLS LAST) AS state_rank
    FROM sh.customers c
)
WHERE state_rank <= 2
ORDER BY state_province, state_rank;


--------------------------------------------------------------------------------
-- 13) Show customers whose names start and end with the same letter
--     (Use last name + first name combined or only first/last — here we'll test full name)
--------------------------------------------------------------------------------
SELECT cust_id,
       full_name,
       credit_limit
FROM (
    SELECT cust_id,
           TRIM(cust_first_name || ' ' || cust_last_name) AS full_name,
           credit_limit,
           LOWER(SUBSTR(TRIM(cust_first_name || ' ' || cust_last_name),1,1)) AS first_char,
           LOWER(SUBSTR(TRIM(cust_first_name || ' ' || cust_last_name), -1, 1)) AS last_char
    FROM sh.customers
)
WHERE first_char = last_char
ORDER BY full_name;


--------------------------------------------------------------------------------
-- 14) Create a ranking of customers within each country by credit limit
--------------------------------------------------------------------------------
SELECT country_id,
       cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       RANK() OVER (PARTITION BY country_id ORDER BY credit_limit DESC NULLS LAST) AS country_rank
FROM sh.customers
ORDER BY country_id, country_rank;


--------------------------------------------------------------------------------
-- 15) Find customers whose credit limit is below the minimum of their income category
--------------------------------------------------------------------------------
WITH min_per_income AS (
    SELECT COALESCE(income_group,'UNKNOWN') AS income_group,
           MIN(credit_limit) AS min_credit
    FROM sh.customers
    GROUP BY COALESCE(income_group,'UNKNOWN')
)
SELECT c.cust_id,
       c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
       c.income_group,
       c.credit_limit,
       m.min_credit
FROM sh.customers c
JOIN min_per_income m ON COALESCE(c.income_group,'UNKNOWN') = m.income_group
WHERE c.credit_limit IS NOT NULL
  AND c.credit_limit < m.min_credit
ORDER BY c.income_group, c.credit_limit;


--------------------------------------------------------------------------------
-- 16) Display the percentage contribution of each customer's credit limit compared to total credit limit of their country
--------------------------------------------------------------------------------
SELECT country_id,
       cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       ROUND(100 * credit_limit / NULLIF(SUM(credit_limit) OVER (PARTITION BY country_id),0),2) AS pct_of_country_total
FROM sh.customers
WHERE credit_limit IS NOT NULL
ORDER BY country_id, pct_of_country_total DESC;


--------------------------------------------------------------------------------
-- 17) Split customers into 4 quartiles (Q1–Q4) based on their credit_limit using NTILE(4)
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       'Q' || NTILE(4) OVER (ORDER BY credit_limit) AS quartile
FROM sh.customers
WHERE credit_limit IS NOT NULL
ORDER BY quartile, credit_limit;


--------------------------------------------------------------------------------
-- 18) Display customers whose last name has more than 7 characters and income_level = 'E: 90,000–109,999'
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit,
       income_group
FROM sh.customers
WHERE LENGTH(NVL(cust_last_name,'')) > 7
  AND income_group = 'E: 90,000–109,999'
ORDER BY credit_limit DESC;


--------------------------------------------------------------------------------
-- 19) For each marital status, find the customer with the maximum credit limit
--------------------------------------------------------------------------------
SELECT marital_status,
       cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       credit_limit
FROM (
    SELECT c.*,
           RANK() OVER (PARTITION BY marital_status ORDER BY credit_limit DESC NULLS LAST) AS rnk_in_marital
    FROM sh.customers c
)
WHERE rnk_in_marital = 1
ORDER BY marital_status;


--------------------------------------------------------------------------------
-- 20) Identify customers whose credit limit equals the department average of their state
--     (Assumes a 'department' column exists; if not, replace department with appropriate column)
--     Use rounding to 2 decimals to avoid floating point equality issues.
--------------------------------------------------------------------------------
SELECT cust_id,
       cust_first_name || ' ' || cust_last_name AS customer_name,
       state_province,
       department,
       credit_limit,
       ROUND(AVG(credit_limit) OVER (PARTITION BY state_province, department),2) AS dept_state_avg
FROM sh.customers
WHERE credit_limit IS NOT NULL
  AND department IS NOT NULL
  AND ROUND(credit_limit,2) = ROUND(AVG(credit_limit) OVER (PARTITION BY state_province, department),2)
ORDER BY state_province, department;
```

---