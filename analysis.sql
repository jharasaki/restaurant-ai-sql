-- Phase 1 sanity-check queries (runs inside DuckDB or any ANSI-SQL DB)

-- Row counts
SELECT 'menu'   AS table_name, COUNT(*) AS rows FROM menu
UNION ALL
SELECT 'orders',               COUNT(*)          FROM orders;

-- Date range
SELECT 
    MIN(order_date) AS first_day,
    MAX(order_date) AS last_day
FROM orders;

-- Null checks
SELECT COUNT(*) AS missing_prices FROM menu   WHERE price   IS NULL;
SELECT COUNT(*) AS orphan_items   FROM orders WHERE item_id IS NULL;

-- Phase 2 Intermediate Analysis

-- CTE: order_items
WITH order_items AS (
    SELECT
        o.order_id,
        TRY_STRPTIME(o.order_date, '%m/%d/%y') AS order_date,
        m.menu_item_id               AS item_id,
        m.item_name,
        m.category,
        CAST(m.price AS DOUBLE)      AS price
    FROM orders AS o
    LEFT JOIN menu  AS m
           ON o.item_id = m.menu_item_id
)
SELECT * FROM order_items LIMIT 5;


-- Leaderboard
WITH order_items AS ( … same CTE … )
SELECT
    item_name,
    COUNT(*)                           AS num_sold,
    ROUND(SUM(price), 2)               AS total_revenue,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS sales_rank
FROM order_items
GROUP BY item_name
ORDER BY sales_rank
LIMIT 10;

-- Margin by category  (assumes 40 % food cost)
WITH order_items AS ( … same CTE … )
SELECT
    category,
    ROUND(SUM(price), 2)               AS revenue,
    ROUND(SUM(price) * 0.40, 2)        AS est_food_cost,
    ROUND(SUM(price) * 0.60, 2)        AS est_margin
FROM order_items
GROUP BY category
ORDER BY est_margin DESC;
