-- ============================================================
-- RETAIL BUSINESS ANALYSIS
-- Dataset: Irish Retail - Robinsons | January 2024 to December 2025
-- PostgreSQL
--
-- Rolling reporting periods are anchored to the latest
-- transaction date available in the dataset.
-- ============================================================


-- ============================================================
-- Q1: Which categories generated the most net sales and profit
-- during the latest 90 days in the dataset?
-- ============================================================

SELECT
    p.category,
    ROUND(SUM(s.net_sales), 2) AS total_net_sales,
    ROUND(SUM(s.profit), 2)    AS total_profit
FROM fact_sales AS s
JOIN dim_product AS p
    ON s.product_id = p.product_id
WHERE s.order_date >= (
        SELECT MAX(order_date) - INTERVAL '89 days'
        FROM fact_sales
    )
GROUP BY
    p.category
ORDER BY
    total_net_sales DESC;


-- ============================================================
-- Q2: Which 10 products generated the highest net sales
-- during the latest 90 days, and how many orders and units
-- drove those sales?
-- ============================================================

SELECT
    p.product_name,
    p.category,
    ROUND(SUM(s.net_sales), 2) AS total_net_sales,
    COUNT(DISTINCT s.order_id) AS total_orders,
    SUM(s.quantity)            AS total_units
FROM fact_sales AS s
JOIN dim_product AS p
    ON s.product_id = p.product_id
WHERE s.order_date >= (
        SELECT MAX(order_date) - INTERVAL '89 days'
        FROM fact_sales
    )
GROUP BY
    p.product_id,
    p.product_name,
    p.category
ORDER BY
    total_net_sales DESC
LIMIT 10;


-- ============================================================
-- Q3: Which 20 repeat customers placed the most orders
-- during the latest 90 days, and how much net sales did
-- they generate?
-- ============================================================

SELECT
    c.customer_name,
    c.segment,
    c.loyalty_tier,
    COUNT(DISTINCT s.order_id) AS total_orders,
    ROUND(SUM(s.net_sales), 2) AS total_net_sales
FROM fact_sales AS s
JOIN dim_customer AS c
    ON s.customer_id = c.customer_id
WHERE s.order_date >= (
        SELECT MAX(order_date) - INTERVAL '89 days'
        FROM fact_sales
    )
GROUP BY
    c.customer_id,
    c.customer_name,
    c.segment,
    c.loyalty_tier
HAVING COUNT(DISTINCT s.order_id) >= 3
ORDER BY
    total_orders DESC,
    total_net_sales DESC
LIMIT 20;


-- ============================================================
-- Q4: How did net sales in 2025 compare with 2024
-- for each product category?
-- ============================================================

WITH category_sales AS (
    SELECT
        p.category,
        SUM(
            CASE
                WHEN s.order_date >= DATE '2024-01-01'
                 AND s.order_date <  DATE '2025-01-01'
                THEN s.net_sales
                ELSE 0
            END
        ) AS sales_2024,
        SUM(
            CASE
                WHEN s.order_date >= DATE '2025-01-01'
                 AND s.order_date <  DATE '2026-01-01'
                THEN s.net_sales
                ELSE 0
            END
        ) AS sales_2025
    FROM fact_sales AS s
    JOIN dim_product AS p
        ON s.product_id = p.product_id
    GROUP BY
        p.category
)
SELECT
    category,
    ROUND(sales_2024, 2) AS sales_2024,
    ROUND(sales_2025, 2) AS sales_2025,
    ROUND(sales_2025 - sales_2024, 2) AS sales_change,
    ROUND(
        100.0 * (sales_2025 - sales_2024)
        / NULLIF(sales_2024, 0),
        2
    ) AS sales_change_pct
FROM category_sales
ORDER BY
    sales_change_pct DESC;


-- ============================================================
-- Q5: Which products are below their reorder point across
-- our locations, and is stock already on order enough to
-- cover the shortfall?
-- ============================================================

SELECT
    p.product_name,
    p.category,
    l.location_name,
    i.on_hand_qty,
    i.reorder_point,
    i.reorder_point - i.on_hand_qty AS stock_shortfall,
    i.on_order_qty,
    i.on_order_qty - (i.reorder_point - i.on_hand_qty) AS order_cover,
    CASE
        WHEN i.on_order_qty >= i.reorder_point - i.on_hand_qty
            THEN 'Covered'
        ELSE 'Not covered'
    END AS cover_status
FROM fact_inventory_snapshot AS i
JOIN dim_product AS p
    ON i.product_id = p.product_id
JOIN dim_location AS l
    ON i.location_id = l.location_id
WHERE i.snapshot_date = (
        SELECT MAX(snapshot_date)
        FROM fact_inventory_snapshot
    )
  AND i.on_hand_qty < i.reorder_point
ORDER BY
    order_cover ASC,
    stock_shortfall DESC
LIMIT 20;


-- ============================================================
-- Q6: What percentage of total net sales did each category
-- contribute during the latest 90 days?
-- ============================================================

SELECT
    p.category,
    ROUND(SUM(s.net_sales), 2) AS total_net_sales,
    ROUND(
        100.0 * SUM(s.net_sales)
        / SUM(SUM(s.net_sales)) OVER (),
        2
    ) AS pct_of_total_sales
FROM fact_sales AS s
JOIN dim_product AS p
    ON s.product_id = p.product_id
WHERE s.order_date >= (
        SELECT MAX(order_date) - INTERVAL '89 days'
        FROM fact_sales
    )
GROUP BY
    p.category
ORDER BY
    total_net_sales DESC;


-- ============================================================
-- Q7: Which categories had the highest unit return rate
-- for sales made during 2025?
-- ============================================================

WITH returns_agg AS (
    SELECT
        sales_line_key,
        SUM(return_qty)   AS returned_qty,
        SUM(refund_value) AS refund_value
    FROM fact_returns
    GROUP BY
        sales_line_key
)
SELECT
    p.category,
    SUM(s.quantity) AS total_units_sold,
    SUM(COALESCE(r.returned_qty, 0)) AS total_units_returned,
    ROUND(
        100.0 * SUM(COALESCE(r.returned_qty, 0))
        / NULLIF(SUM(s.quantity), 0),
        2
    ) AS return_rate_pct,
    ROUND(
        SUM(COALESCE(r.refund_value, 0)),
        2
    ) AS total_refund_value
FROM fact_sales AS s
JOIN dim_product AS p
    ON s.product_id = p.product_id
LEFT JOIN returns_agg AS r
    ON s.sales_line_key = r.sales_line_key
WHERE s.order_date >= DATE '2025-01-01'
  AND s.order_date <  DATE '2026-01-01'
GROUP BY
    p.category
ORDER BY
    return_rate_pct DESC;


-- ============================================================
-- Q8: Which 20 products generated the most net sales above
-- their category average during the latest 90 days?
-- ============================================================

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(s.net_sales) AS total_net_sales
    FROM fact_sales AS s
    JOIN dim_product AS p
        ON s.product_id = p.product_id
    WHERE s.order_date >= (
        SELECT MAX(order_date) - INTERVAL '89 days'
        FROM fact_sales
    )
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
category_average AS (
    SELECT
        category,
        AVG(total_net_sales) AS avg_product_sales
    FROM product_sales
    GROUP BY
        category
)
SELECT
    ps.product_name,
    ps.category,
    ROUND(ps.total_net_sales, 2)   AS total_net_sales,
    ROUND(ca.avg_product_sales, 2) AS category_average,
    ROUND(
        ps.total_net_sales - ca.avg_product_sales,
        2
    ) AS amount_above_average
FROM product_sales AS ps
JOIN category_average AS ca
    ON ps.category = ca.category
WHERE ps.total_net_sales > ca.avg_product_sales
ORDER BY
    amount_above_average DESC
LIMIT 20;


-- ============================================================
-- Q9: Which two products generated the highest net sales
-- within each category during the latest 90 days?
-- ============================================================

WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        SUM(s.net_sales) AS total_net_sales
    FROM fact_sales AS s
    JOIN dim_product AS p
        ON s.product_id = p.product_id
    WHERE s.order_date >= (
        SELECT MAX(order_date) - INTERVAL '89 days'
        FROM fact_sales
    )
    GROUP BY
        p.product_id,
        p.product_name,
        p.category
),
ranked_products AS (
    SELECT
        product_name,
        category,
        total_net_sales,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_net_sales DESC
        ) AS category_rank
    FROM product_sales
)
SELECT
    category,
    category_rank,
    product_name,
    ROUND(total_net_sales, 2) AS total_net_sales
FROM ranked_products
WHERE category_rank <= 2
ORDER BY
    category,
    category_rank;


-- ============================================================
-- Q10: Which categories generated the most net sales in the
-- latest 90 days, and how did performance compare with the
-- previous 90 days?
-- ============================================================

WITH report_date AS (
    SELECT MAX(order_date) AS latest_date
    FROM fact_sales
),
latest_90 AS (
    SELECT
        p.category,
        SUM(s.net_sales) AS latest_90_day_sales,
        SUM(s.profit)    AS latest_90_day_profit
    FROM fact_sales AS s
    JOIN dim_product AS p
        ON s.product_id = p.product_id
    CROSS JOIN report_date AS r
    WHERE s.order_date >= r.latest_date - INTERVAL '89 days'
      AND s.order_date <= r.latest_date
    GROUP BY
        p.category
),
previous_90 AS (
    SELECT
        p.category,
        SUM(s.net_sales) AS previous_90_day_sales
    FROM fact_sales AS s
    JOIN dim_product AS p
        ON s.product_id = p.product_id
    CROSS JOIN report_date AS r
    WHERE s.order_date >= r.latest_date - INTERVAL '179 days'
      AND s.order_date <  r.latest_date - INTERVAL '89 days'
    GROUP BY
        p.category
)
SELECT
    l.category,
    ROUND(l.latest_90_day_sales, 2)   AS latest_90_day_sales,
    ROUND(p.previous_90_day_sales, 2) AS previous_90_day_sales,
    ROUND(
        l.latest_90_day_sales - p.previous_90_day_sales,
        2
    ) AS sales_change,
    ROUND(
        100.0 * (
            l.latest_90_day_sales - p.previous_90_day_sales
        ) / NULLIF(p.previous_90_day_sales, 0),
        2
    ) AS sales_change_pct,
    ROUND(l.latest_90_day_profit, 2) AS latest_90_day_profit
FROM latest_90 AS l
JOIN previous_90 AS p
    ON l.category = p.category
ORDER BY
    latest_90_day_sales DESC;
