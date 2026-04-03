-- Trend Analysis (Simple & Clean)

-- 1. نحسب الإيرادات وعدد الطلبات لكل يوم
WITH daily_metrics AS (
    SELECT 
        o.order_date,
        COUNT(DISTINCT o.order_id) AS daily_orders,
        SUM(oi.unit_price * oi.quantity) AS daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY o.order_date
)

-- 2. نحسب moving averages
SELECT 
    order_date,
    daily_revenue,
    daily_orders,

    -- متوسط آخر 7 أيام (الإيرادات)
    AVG(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS avg_rev_7d,

    -- متوسط آخر 30 يوم (الإيرادات)
    AVG(daily_revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS avg_rev_30d,

    -- متوسط آخر 7 أيام (الطلبات)
    AVG(daily_orders) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS avg_orders_7d

FROM daily_metrics

ORDER BY order_date;