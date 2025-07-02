SELECT 'menu'   AS table, COUNT(*) AS rows FROM menu
UNION ALL
SELECT 'orders', COUNT(*)          FROM orders;

SELECT MIN(order_date) AS first_day,
       MAX(order_date) AS last_day
FROM orders;

SELECT COUNT(*) AS missing_prices FROM menu   WHERE price   IS NULL;
SELECT COUNT(*) AS orphan_items   FROM orders WHERE item_id IS NULL;

CREATE TABLE menu_parquet   AS SELECT * FROM menu;
CREATE TABLE orders_parquet AS SELECT * FROM orders;