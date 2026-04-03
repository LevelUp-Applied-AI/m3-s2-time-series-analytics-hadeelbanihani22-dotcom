--4th file
WITH category_monthly_rev AS (
    SELECT 
        p.category,
        DATE_TRUNC('month', o.order_date)::date as month,
        SUM(oi.unit_price * oi.quantity) as revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY 1, 2
),
-- 2. دمج LAG (للنمو) مع Window SUM (للحصة السوقية)
final_analysis AS (
    SELECT 
        month,
        category,
        revenue,
        -- حساب نمو الفئة مقارنة بالشهر السابق
        LAG(revenue) OVER (PARTITION BY category ORDER BY month) as prev_month_rev,
        -- حساب إجمالي دخل المحل في هذا الشهر (لنعرف حصة الفئة)
        SUM(revenue) OVER (PARTITION BY month) as total_monthly_market_revenue
    FROM category_monthly_rev
)
-- 3. النتيجة النهائية مع النسب المئوية
SELECT 
    month,
    category,
    revenue,
    ROUND(((revenue - prev_month_rev) / prev_month_rev) * 100, 2) as cat_growth_pct,
    ROUND((revenue / total_monthly_market_revenue) * 100, 2) as market_share_pct
FROM final_analysis
WHERE prev_month_rev IS NOT NULL
ORDER BY month DESC, market_share_pct DESC