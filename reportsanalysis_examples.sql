-- 1. Анализ динамики продаж по месяцам
SELECT 
    TO_CHAR(sale_date, 'YYYY-MM') as month,
    COUNT(*) as orders_count,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM sales
GROUP BY TO_CHAR(sale_date, 'YYYY-MM')
ORDER BY month DESC;

-- 2. Топ-10 клиентов по объему покупок
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    cs.segment_name,
    COUNT(s.sale_id) as total_orders,
    SUM(s.total_amount) as total_spent,
    MAX(s.sale_date) as last_purchase_date
FROM customers c
JOIN customer_segments cs ON c.segment_id = cs.segment_id
LEFT JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, cs.segment_name
ORDER BY total_spent DESC
LIMIT 10;

-- 3. Анализ эффективности сотрудников
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.position,
    COUNT(s.sale_id) as sales_count,
    SUM(s.total_amount) as total_revenue,
    AVG(s.total_amount) as avg_sale_amount
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.position
ORDER BY total_revenue DESC;

-- 4. Анализ товарной матрицы (ABC-анализ)
WITH product_stats AS (
    SELECT 
        p.product_id,
        p.product_name,
        SUM(s.quantity) as total_quantity,
        SUM(s.total_amount) as total_revenue,
        SUM(s.total_amount) * 100.0 / SUM(SUM(s.total_amount)) OVER() as revenue_percentage
    FROM products p
    LEFT JOIN sales s ON p.product_id = s.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT 
    product_id,
    product_name,
    total_quantity,
    total_revenue,
    revenue_percentage,
    CASE 
        WHEN revenue_percentage >= 70 THEN 'A'
        WHEN revenue_percentage >= 20 THEN 'B'
        ELSE 'C'
    END as abc_category
FROM product_stats
ORDER BY total_revenue DESC;

-- 5. Прогнозирование спроса на следующие 30 дней
SELECT 
    p.product_id,
    p.product_name,
    p.stock_quantity as current_stock,
    forecast_sales_moving_average(p.product_id, 30) as forecast_next_30_days,
    CASE 
        WHEN p.stock_quantity < forecast_sales_moving_average(p.product_id, 30) * 0.5 
        THEN 'Требуется пополнение'
        ELSE 'Запас достаточный'
    END as stock_status
FROM products p
ORDER BY forecast_next_30_days DESC;