-- =====================================================
-- Combined Analysis: Category Growth + Market Share
-- =====================================================

-- =====================================================
-- 1. Calculate monthly revenue per category
-- =====================================================
WITH category_monthly_rev AS (
    SELECT 
        p.category,                                           -- اسم الفئة
        DATE_TRUNC('month', o.order_date)::date AS month,     -- الشهر
        SUM(oi.unit_price * oi.quantity) AS revenue           -- إيرادات الفئة

    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id

    WHERE o.status != 'cancelled'                             -- استبعاد الطلبات الملغية

    GROUP BY 1, 2
),

-- =====================================================
-- 2. Add window functions:
--    - LAG → growth
--    - SUM OVER → market share
-- =====================================================
final_analysis AS (
    SELECT 
        month,
        category,
        revenue,

        -- الإيرادات للشهر السابق لكل فئة (لحساب النمو)
        LAG(revenue) OVER (
            PARTITION BY category 
            ORDER BY month
        ) AS prev_month_rev,

        -- إجمالي السوق في نفس الشهر (لحساب الحصة السوقية)
        SUM(revenue) OVER (
            PARTITION BY month
        ) AS total_monthly_market_revenue

    FROM category_monthly_rev
)

-- =====================================================
-- 3. Final results with percentages
-- =====================================================
SELECT 
    month,
    category,
    revenue,

    -- نسبة نمو الفئة مقارنة بالشهر السابق
    ROUND(
        ((revenue - prev_month_rev) / NULLIF(prev_month_rev, 0)) * 100,
        2
    ) AS cat_growth_pct,

    -- الحصة السوقية للفئة داخل الشهر
    ROUND(
        (revenue / total_monthly_market_revenue) * 100,
        2
    ) AS market_share_pct

FROM final_analysis

-- نستبعد أول شهر (ما فيه previous)
WHERE prev_month_rev IS NOT NULL

-- ترتيب: أحدث شهر + أعلى فئة
ORDER BY month DESC, market_share_pct DESC;