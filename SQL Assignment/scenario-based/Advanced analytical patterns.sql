--------------------------------------------------------------------------------
-- 1) Z-score normalization of customer credit limits (global)
--------------------------------------------------------------------------------
SELECT
    cust_id,
    cust_first_name || ' ' || cust_last_name AS customer_name,
    credit_limit,
    ROUND(
        (credit_limit - AVG(credit_limit) OVER ()) / NULLIF(STDDEV(credit_limit) OVER (),0),
        4
    ) AS z_score
FROM sh.customers
WHERE credit_limit IS NOT NULL
ORDER BY z_score DESC;


--------------------------------------------------------------------------------
-- 2) Gini coefficient of credit-limit inequality per country
--    Gini formula used: G = (2 * sum(i * x_i) / (n * sum x_i)) - (n + 1)/n
--    where rows are sorted low->high (i = 1..n)
--------------------------------------------------------------------------------
WITH c AS (
    SELECT
        country_id,
        credit_limit,
        ROW_NUMBER() OVER (PARTITION BY country_id ORDER BY credit_limit ASC) AS rn,
        COUNT(*) OVER (PARTITION BY country_id) AS n,
        SUM(credit_limit) OVER (PARTITION BY country_id) AS sum_x
    FROM sh.customers
    WHERE credit_limit IS NOT NULL
),
agg AS (
    SELECT
        country_id,
        n,
        sum_x,
        SUM(rn * credit_limit) AS sum_r_x
    FROM c
    GROUP BY country_id, n, sum_x
)
SELECT
    country_id,
    CASE WHEN sum_x = 0 OR n <= 1 THEN NULL
         ELSE ROUND( (2 * sum_r_x / (n * sum_x) - (n + 1) / CAST(n AS NUMBER)), 4)
    END AS gini_coefficient
FROM agg
ORDER BY gini_coefficient DESC NULLS LAST;


--------------------------------------------------------------------------------
-- 3) Customers with credit_limit > 75th percentile and < 90th percentile
--    (two variants: GLOBAL and PER COUNTRY)
--------------------------------------------------------------------------------
-- 3A: Global percentiles
WITH pct AS (
    SELECT
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY credit_limit) OVER () AS p75,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY credit_limit) OVER () AS p90
    FROM sh.customers
    WHERE credit_limit IS NOT NULL
    FETCH FIRST 1 ROWS ONLY
)
SELECT
    c.cust_id,
    c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
    c.credit_limit
FROM sh.customers c
CROSS JOIN pct
WHERE c.credit_limit IS NOT NULL
  AND c.credit_limit > pct.p75
  AND c.credit_limit < pct.p90
ORDER BY c.credit_limit DESC;


-- 3B: Per-country percentiles (if you prefer country-specific selection)
WITH cs AS (
    SELECT
        cust_id,
        country_id,
        credit_limit,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY credit_limit) OVER (PARTITION BY country_id) AS p75,
        PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY credit_limit) OVER (PARTITION BY country_id) AS p90
    FROM sh.customers
    WHERE credit_limit IS NOT NULL
)
SELECT cust_id, country_id, credit_limit
FROM cs
WHERE credit_limit > p75 AND credit_limit < p90
ORDER BY country_id, credit_limit DESC;


--------------------------------------------------------------------------------
-- 4) Rank difference between two states using analytic functions
--    (compare ranks for customers present in both states; use :STATE_A and :STATE_B)
--------------------------------------------------------------------------------
WITH ranks AS (
    SELECT
        state_province,
        cust_id,
        credit_limit,
        RANK() OVER (PARTITION BY state_province ORDER BY credit_limit DESC NULLS LAST) AS rank_in_state
    FROM sh.customers
    WHERE state_province IN (:STATE_A, :STATE_B)  -- bind variables e.g. 'California', 'Texas'
)
-- If you want to compare ranks only for customers that appear in both states (rare),
-- we join on cust_id. Alternatively you can aggregate ranks per state and compute differences.
SELECT
    a.cust_id,
    a.rank_in_state AS rank_in_state_a,
    b.rank_in_state AS rank_in_state_b,
    (a.rank_in_state - b.rank_in_state) AS rank_difference
FROM ranks a
JOIN ranks b ON a.cust_id = b.cust_id
WHERE a.state_province = :STATE_A
  AND b.state_province = :STATE_B
ORDER BY rank_difference DESC;


--------------------------------------------------------------------------------
-- 5) Median and Interquartile Range (IQR) of credit_limit per state
--------------------------------------------------------------------------------
SELECT
    state_province,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY credit_limit) OVER (PARTITION BY state_province),2) AS median_credit,
    ROUND(
      (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY credit_limit) OVER (PARTITION BY state_province)
       - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY credit_limit) OVER (PARTITION BY state_province)),
      2
    ) AS iqr_credit
FROM sh.customers
WHERE credit_limit IS NOT NULL
GROUP BY state_province
ORDER BY state_province;


--------------------------------------------------------------------------------
-- 6) Identify outliers in credit_limit using the IQR method (per state)
--------------------------------------------------------------------------------
WITH iqr AS (
    SELECT
        state_province,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY credit_limit) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY credit_limit) AS q3
    FROM sh.customers
    WHERE credit_limit IS NOT NULL
    GROUP BY state_province
),
joined AS (
    SELECT
        c.cust_id,
        c.cust_first_name || ' ' || c.cust_last_name AS customer_name,
        c.state_province,
        c.credit_limit,
        i.q1,
        i.q3,
        (i.q3 - i.q1) AS iqr
    FROM sh.customers c
    JOIN iqr i ON c.state_province = i.state_province
    WHERE c.credit_limit IS NOT NULL
)
SELECT
    cust_id,
    customer_name,
    state_province,
    credit_limit,
    CASE
        WHEN credit_limit < (q1 - 1.5 * iqr) THEN 'LOW_OUTLIER'
        WHEN credit_limit > (q3 + 1.5 * iqr) THEN 'HIGH_OUTLIER'
        ELSE 'NOT_OUTLIER'
    END AS outlier_flag,
    q1, q3, iqr
FROM joined
WHERE credit_limit < (q1 - 1.5 * iqr) OR credit_limit > (q3 + 1.5 * iqr)
ORDER BY state_province, credit_limit;


--------------------------------------------------------------------------------
-- 7) Credit limit growth per customer over years (requires history table)
--    Assumes: sh.customer_credit_history(cust_id, year, credit_limit)
--------------------------------------------------------------------------------
WITH hist AS (
    SELECT
        cust_id,
        year,
        credit_limit,
        LAG(credit_limit) OVER (PARTITION BY cust_id ORDER BY year) AS prev_limit
    FROM sh.customer_credit_history
)
SELECT
    cust_id,
    year,
    credit_limit,
    prev_limit,
    CASE WHEN prev_limit IS NULL THEN NULL
         WHEN prev_limit = 0 THEN NULL
         ELSE ROUND( (credit_limit - prev_limit) / prev_limit * 100, 2)
    END AS growth_pct
FROM hist
ORDER BY cust_id, year;


--------------------------------------------------------------------------------
-- 8) Running (cumulative) average of credit_limit by customer ID (over years)
--    Again uses sh.customer_credit_history
--------------------------------------------------------------------------------
SELECT
    cust_id,
    year,
    credit_limit,
    ROUND(
      AVG(credit_limit) OVER (PARTITION BY cust_id ORDER BY year
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
      2
    ) AS running_avg_credit
FROM sh.customer_credit_history
ORDER BY cust_id, year;


--------------------------------------------------------------------------------
-- 9) Total cumulative credit per income_group sorted by rank
--    Assumes column: income_group (can be NULL; handle with COALESCE)
--------------------------------------------------------------------------------
SELECT
    COALESCE(income_group, 'UNKNOWN') AS income_group,
    cust_id,
    credit_limit,
    RANK() OVER (PARTITION BY COALESCE(income_group,'UNKNOWN') ORDER BY credit_limit DESC NULLS LAST) AS rnk_in_group,
    SUM(credit_limit) OVER (PARTITION BY COALESCE(income_group,'UNKNOWN') ORDER BY credit_limit DESC
                            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_credit_in_group
FROM sh.customers
WHERE credit_limit IS NOT NULL
ORDER BY income_group, cumulative_credit_in_group DESC;


--------------------------------------------------------------------------------
-- 10) Leaderboard view showing top N customers dynamically using analytic functions
--     Use bind variable :N for the top N
--------------------------------------------------------------------------------

SELECT *
FROM (
    SELECT
        cust_id,
        cust_first_name || ' ' || cust_last_name AS customer_name,
        credit_limit,
        RANK() OVER (ORDER BY credit_limit DESC NULLS LAST) AS rank_position
    FROM sh.customers
    WHERE credit_limit IS NOT NULL
)
WHERE rank_position <= :N
ORDER BY rank_position;

SELECT *
FROM (
    SELECT
        country_id,
        cust_id,
        cust_first_name || ' ' || cust_last_name AS customer_name,
        credit_limit,
        RANK() OVER (PARTITION BY country_id ORDER BY credit_limit DESC NULLS LAST) AS country_rank
    FROM sh.customers
    WHERE credit_limit IS NOT NULL
)
WHERE country_rank <= :N
ORDER BY country_id, country_rank;
```

---