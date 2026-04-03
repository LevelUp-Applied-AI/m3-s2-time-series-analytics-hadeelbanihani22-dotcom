-- queries/cohort_analysis.sql

-- =====================================================
-- 1. Rank orders per customer to find first purchase
-- =====================================================
--cohort = grouping customers based on first purchase date
WITH ranked_orders AS (
    SELECT 
        customer_id,          -- رقم العميل
        order_date,           -- تاريخ الطلب

        -- نعطي ترتيب لكل طلب داخل كل customer
        -- أول طلب رح يكون rn = 1
        ROW_NUMBER() OVER (
            PARTITION BY customer_id      -- لكل عميل لحاله
            ORDER BY order_date           -- ترتيب حسب التاريخ (من الأقدم)
        ) AS rn

    FROM orders
),

-- =====================================================
-- 2. Keep only the first purchase for each customer
-- =====================================================
first_purchase AS (
    SELECT 
        customer_id,
        order_date AS first_order_date    -- أول عملية شراء

    FROM ranked_orders

    -- نختار فقط أول طلب لكل عميل
    WHERE rn = 1
),

-- =====================================================
-- 3. Define cohort (group customers by first purchase month)
-- =====================================================
cohort_definition AS (
    SELECT 
        customer_id,

        -- نحول تاريخ أول شراء إلى شهر (cohort)
        -- مثال: 2025-04-15 → 2025-04-01
        DATE_TRUNC('month', first_order_date)::date AS cohort_month

    FROM first_purchase
)

-- =====================================================
-- 4. Count how many customers in each cohort
-- =====================================================
SELECT 
    cohort_month, 

    -- عدد العملاء في كل cohort
    COUNT(DISTINCT customer_id) AS num_customers

FROM cohort_definition

-- نجمع حسب الشهر
GROUP BY cohort_month

-- ترتيب من الأقدم للأحدث
ORDER BY cohort_month;