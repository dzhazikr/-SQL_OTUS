-- 1. Создание материализованных представлений для часто используемых отчетов

-- Материализованное представление для ежедневных продаж
CREATE MATERIALIZED VIEW daily_sales_summary AS
SELECT 
    sale_date::DATE as sale_day,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value,
    SUM(quantity) as total_items_sold
FROM sales
GROUP BY sale_date::DATE
WITH DATA;

-- Создание индекса для материализованного представления
CREATE INDEX idx_daily_sales_day ON daily_sales_summary(sale_day);

-- 2. Материализованное представление для клиентской аналитики
CREATE MATERIALIZED VIEW customer_analytics AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.segment_id,
    cs.segment_name,
    COUNT(s.sale_id) as total_orders,
    SUM(s.total_amount) as lifetime_value,
    MAX(s.sale_date) as last_purchase_date,
    AVG(s.total_amount) as avg_purchase_value
FROM customers c
JOIN customer_segments cs ON c.segment_id = cs.segment_id
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.segment_id, cs.segment_name
WITH DATA;

-- 3. Создание индексов для ускорения аналитических запросов
CREATE INDEX idx_sales_date_amount ON sales(sale_date, total_amount);
CREATE INDEX idx_customers_segment_total ON customers(segment_id, total_purchases);
CREATE INDEX idx_products_category_price ON products(category_id, unit_price);

-- 4. Функция для обновления материализованных представлений
CREATE OR REPLACE PROCEDURE refresh_materialized_views()
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY daily_sales_summary;
    REFRESH MATERIALIZED VIEW CONCURRENTLY customer_analytics;
    RAISE NOTICE 'Материализованные представления обновлены';
END;
$$;

-- 5. Представление для быстрого доступа к аналитике продаж по регионам
CREATE VIEW regional_sales_analysis AS
SELECT 
    r.region_name,
    r.country,
    COUNT(DISTINCT s.customer_id) as unique_customers,
    COUNT(s.sale_id) as total_orders,
    SUM(s.total_amount) as total_revenue,
    AVG(s.total_amount) as avg_order_value
FROM regions r
LEFT JOIN customers c ON r.region_id = c.region_id
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY r.region_id, r.region_name, r.country
ORDER BY total_revenue DESC;
