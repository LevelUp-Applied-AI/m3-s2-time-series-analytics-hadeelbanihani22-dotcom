--third file

-- 1. تجهيز المقاييس اليومية: الدخل وعدد الطلبات
WITH daily_metrics AS (
    SELECT 
        o.order_date, -- حددنا الجدول هنا (o) لتجنب الغموض
        COUNT(DISTINCT o.order_id) as daily_orders, -- DISTINCT عشان ما نكرر الطلب لو فيه كذا منتج
        SUM(oi.unit_price * oi.quantity) as daily_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_date
)
-- 2. حساب المتوسط المتحرك (Moving Average)
SELECT 
    order_date,
    daily_revenue,
    -- المتوسط المتحرك للدخل لآخر 7 أيام
    AVG(daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_rev_7d,
    -- المتوسط المتحرك لعدد الطلبات لآخر 7 أيام
    AVG(daily_orders) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_orders_7d
FROM daily_metrics
ORDER BY order_date;