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

