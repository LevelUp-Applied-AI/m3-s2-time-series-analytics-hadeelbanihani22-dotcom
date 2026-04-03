-- ===============================
-- Growth Analysis (MoM & QoQ)
-- ===============================

-- =====================================================
-- 1. Calculate monthly revenue and order count
-- =====================================================
WITH monthly_metrics AS (
    SELECT 
        DATE_TRUNC('month', o.order_date)::date AS month,  -- تحويل التاريخ لشهر
        SUM(oi.quantity * oi.unit_price) AS revenue,       -- إجمالي الإيرادات
        COUNT(DISTINCT o.order_id) AS orders               -- عدد الطلبات
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'                          -- استبعاد الطلبات الملغية
    GROUP BY 1
),

-- =====================================================
-- 2. Calculate Month-over-Month growth using LAG
-- =====================================================
mom_growth AS (
    SELECT 
        month,
        revenue,
        orders,

        -- الإيرادات للشهر السابق
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue,

        -- عدد الطلبات للشهر السابق
        LAG(orders) OVER (ORDER BY month) AS prev_orders

    FROM monthly_metrics
)

-- =====================================================
-- 3. Final MoM results
-- =====================================================
SELECT 
    month,
    revenue,
    prev_revenue,

    -- حساب نسبة نمو الإيرادات
    ROUND(
        ((revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100,
        2
    ) AS revenue_growth_mom_pct,

    orders,
    prev_orders,

    -- حساب نسبة نمو الطلبات (مع تحويل لنوع رقمي لتجنب القسمة الصحيحة)
    ROUND(
        ((orders - prev_orders)::numeric / NULLIF(prev_orders, 0)) * 100,
        2
    ) AS orders_growth_mom_pct

FROM mom_growth
ORDER BY month;



-- =====================================================
-- 4. Calculate quarterly revenue
-- =====================================================
WITH quarterly_metrics AS (
    SELECT 
        DATE_TRUNC('quarter', o.order_date)::date AS quarter,  -- تحويل لربع سنوي
        SUM(oi.quantity * oi.unit_price) AS revenue            -- إجمالي الإيرادات
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY 1
),

-- =====================================================
-- 5. Calculate Quarter-over-Quarter growth
-- =====================================================
qoq_growth AS (
    SELECT 
        quarter,
        revenue,

        -- الإيرادات للربع السابق
        LAG(revenue) OVER (ORDER BY quarter) AS prev_revenue

    FROM quarterly_metrics
)

-- =====================================================
-- 6. Final QoQ results
-- =====================================================
SELECT 
    quarter,
    revenue,
    prev_revenue,

    -- حساب نسبة النمو الربعي
    ROUND(
        ((revenue - prev_revenue) / NULLIF(prev_revenue, 0)) * 100,
        2
    ) AS revenue_growth_qoq_pct

FROM qoq_growth
ORDER BY quarter;