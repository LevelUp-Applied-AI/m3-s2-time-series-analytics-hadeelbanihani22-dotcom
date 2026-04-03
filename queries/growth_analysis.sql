-- ===============================
-- Secound file: Growth Analysis (MoM & QoQ)
-- ===============================

-- ===============================
-- 1. Monthly Revenue & Orders
-- ===============================
WITH monthly_metrics AS (
    SELECT DATE_TRUNC('month', o.order_date)::date AS month,SUM(oi.quantity * oi.unit_price) AS revenue,COUNT(DISTINCT o.order_id) AS orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY 1
),

-- ===============================
-- 2. Month-over-Month Growth
-- ===============================
mom_growth AS (
    SELECT month,revenue,orders,LAG(revenue) OVER (ORDER BY month) AS prev_revenue,LAG(orders) OVER (ORDER BY month) AS prev_orders
    FROM monthly_metrics
)

-- 🔹 Month-over-Month Results
SELECT 
    month,
    revenue,
    prev_revenue,

    ROUND(
        ((revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100,
        2
    ) AS revenue_growth_mom_pct,

    orders,
    prev_orders,

    ROUND(
        ((orders - prev_orders) / NULLIF(prev_orders, 0)) * 100,
        2
    ) AS orders_growth_mom_pct

FROM mom_growth
ORDER BY month;



-- ===============================
-- 3. Quarterly Revenue
-- ===============================
with quarterly_metrics AS (
    SELECT 
        DATE_TRUNC('quarter', o.order_date)::date AS quarter,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY 1
),

-- ===============================
-- 4. Quarter-over-Quarter Growth
-- ===============================
qoq_growth AS (
    SELECT 
        quarter,
        revenue,
        LAG(revenue) OVER (ORDER BY quarter) AS prev_revenue
    FROM quarterly_metrics
)

-- ===============================
-- FINAL OUTPUT
-- ===============================

-- 🔹 Quarter-over-Quarter Results
SELECT 
    quarter,
    revenue,
    prev_revenue,

    ROUND(
        ((revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100,
        2
    ) AS revenue_growth_qoq_pct

FROM qoq_growth
ORDER BY quarter;
