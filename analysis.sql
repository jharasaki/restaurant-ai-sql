# Check
import sys, subprocess, pkg_resources, platform, datetime
print("Python version:", platform.python_version())

!pip install -q duckdb pandas pyarrow

# Import libraries and quick sanity check
import duckdb, pandas as pd
duckdb.sql("SELECT 'DuckDB is ready' AS status").show()

# Mount google drive
from google.colab import drive
drive.mount('/content/drive')

# Verify project exists within the folder
!ls /content/drive/MyDrive/restaurant-ai-sql-project

import duckdb, pandas as pd, pathlib

# Path to the CSVs placed in Drive
DATA_PATH = pathlib.Path('/content/drive/MyDrive/restaurant-ai-sql-project/data_raw')

# Read CSVs with pandas
menu   = pd.read_csv(DATA_PATH / 'menu_items.csv')
orders = pd.read_csv(DATA_PATH / 'order_details.csv')

# Register with DuckDB so we can use plain SQL
con = duckdb.connect()
con.register('menu',   menu)
con.register('orders', orders)

# Quick confirmation that tables exist
print(
    "Loaded tables:",
    con.execute("SHOW TABLES").fetchdf()['name'].tolist()
)

# Row-count sanity check
con.sql("SELECT * FROM menu   LIMIT 3").show()
con.sql("SELECT * FROM orders LIMIT 3").show()

# Date-range check on orders
con.sql("""
SELECT 'menu'   AS table, COUNT(*) AS rows FROM menu
UNION ALL
SELECT 'orders', COUNT(*)          FROM orders;
""").show()

con.sql("""
SELECT MIN(order_date) AS first_day,
       MAX(order_date) AS last_day
FROM orders;
""").show()

# Null checks (price & item references)
con.sql("SELECT COUNT(*) AS missing_prices FROM menu WHERE price IS NULL").show()
con.sql("SELECT COUNT(*) AS orphan_items  FROM orders WHERE item_id IS NULL").show()

# Parquet backups (handy if Colab times out)
con.sql("CREATE TABLE menu_parquet   AS SELECT * FROM menu")
con.sql("CREATE TABLE orders_parquet AS SELECT * FROM orders")

# Make one analysis table with all order lines
con.sql("""
-- 2-A  ·  Build a joined view of every ordered item
CREATE OR REPLACE TABLE order_items AS
SELECT
    o.order_id,
    o.order_date,
    m.menu_item_id,
    m.item_name,
    m.category,
    m.price
FROM orders  AS o
LEFT JOIN menu AS m
       ON o.item_id = m.menu_item_id;
""")

# Sanity Check
con.sql("SELECT COUNT(*) AS rows FROM order_items").show()
con.sql("SELECT * FROM order_items LIMIT 3").show()

# Leaderboard – top 15 most-sold items
con.sql("""
WITH item_sales AS (
  SELECT
    item_name,
    COUNT(*)             AS num_sold,
    SUM(price)           AS revenue
  FROM order_items
  GROUP BY item_name
)
SELECT
    item_name,
    num_sold,
    revenue,
    RANK() OVER (ORDER BY num_sold DESC) AS sales_rank
FROM item_sales
ORDER BY sales_rank
LIMIT 15;
""").show()

# Save a full leaderboard for Tableau later
con.sql("""
WITH daily_sales AS (
  SELECT
    order_date,
    category,
    SUM(price) AS daily_revenue
  FROM order_items
  GROUP BY order_date, category
)
SELECT
    order_date,
    category,
    daily_revenue,
    -- rolling 7-day window, including current day
    SUM(daily_revenue) OVER (
        PARTITION BY category
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rev_7d
FROM daily_sales
ORDER BY order_date, category;
""").show()

# Margin proxy by category (assume 60 % gross margin)
con.sql("""
SELECT
    category,
    ROUND(SUM(price) * 0.60, 2) AS est_margin
FROM order_items
GROUP BY category
ORDER BY est_margin DESC;
""").show()

# Full order_items for ad-hoc Tableau exploration
con.execute("""
COPY order_items
TO '/content/drive/MyDrive/restaurant-ai-sql-project/outputs/order_items.csv'
(HEADER, DELIMITER ',');
""")

# Aggregated leaderboard
con.execute("""
COPY (SELECT item_name, num_sold, revenue
      FROM (SELECT item_name,
                   COUNT(*) AS num_sold,
                   SUM(price) AS revenue
            FROM order_items
            GROUP BY item_name))
TO '/content/drive/MyDrive/restaurant-ai-sql-project/outputs/leaderboard.csv'
(HEADER, DELIMITER ',');
""")
