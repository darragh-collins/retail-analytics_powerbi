-- ============================================================
-- RETAIL ANALYTICS: DATA QUALITY CHECKS
-- PostgreSQL
-- ============================================================

-- 1. Confirm row counts for all imported tables
SELECT 'dim_channel' AS table_name, COUNT(*) AS row_count
FROM dim_channel

UNION ALL

SELECT 'dim_customer', COUNT(*)
FROM dim_customer

UNION ALL

SELECT 'dim_location', COUNT(*)
FROM dim_location

UNION ALL

SELECT 'dim_product', COUNT(*)
FROM dim_product

UNION ALL

SELECT 'fact_sales', COUNT(*)
FROM fact_sales

UNION ALL

SELECT 'fact_returns', COUNT(*)
FROM fact_returns

UNION ALL

SELECT 'fact_inventory_snapshot', COUNT(*)
FROM fact_inventory_snapshot

ORDER BY table_name;


-- 2. Check for duplicate sales-line keys
SELECT COUNT(*) AS duplicate_sales_line_keys
FROM (
    SELECT sales_line_key
    FROM fact_sales
    GROUP BY sales_line_key
    HAVING COUNT(*) > 1
) AS duplicates;


-- 3. Check for missing important sales keys
SELECT
    COUNT(*) FILTER (WHERE sales_line_key IS NULL) AS missing_sales_line_key,
    COUNT(*) FILTER (WHERE customer_id IS NULL)    AS missing_customer_id,
    COUNT(*) FILTER (WHERE product_id IS NULL)     AS missing_product_id,
    COUNT(*) FILTER (WHERE location_id IS NULL)    AS missing_location_id,
    COUNT(*) FILTER (WHERE channel_id IS NULL)     AS missing_channel_id
FROM fact_sales;
