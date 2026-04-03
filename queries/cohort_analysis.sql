-- queries/cohort_analysis.sql
--the first file
-- 1. Identify the first purchase month for each customer
--Common Table Expression (CTE) ✔
WITH first_purchase AS (
    SELECT customer_id, MIN(order_date) as first_order_date
    FROM orders
    GROUP BY customer_id
),
--first_purchase صارت عباره عن جدول جديد مؤقت فيه ال customer_id,first_order_date
-- 2. Define cohorts based on the month of that first purchase
cohort_definition AS (
    SELECT customer_id, DATE_TRUNC('month', first_order_date)::date as cohort_month
    FROM first_purchase
)
--cohort_definition صارت عباره عن جدول جديد فيه ال id,cohort_month

-- 3. Calculate how many customers belong to each cohort
SELECT cohort_month, COUNT(customer_id) as num_customers
FROM cohort_definition
GROUP BY cohort_month
ORDER BY cohort_month;