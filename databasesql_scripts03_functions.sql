-- 1. Функция для расчета выручки за период
CREATE OR REPLACE FUNCTION calculate_revenue(
    start_date DATE,
    end_date DATE
) RETURNS DECIMAL AS $$
DECLARE
    total_revenue DECIMAL;
BEGIN
    SELECT COALESCE(SUM(total_amount), 0)
    INTO total_revenue
    FROM sales
    WHERE sale_date BETWEEN start_date AND end_date;
    
    RETURN total_revenue;
END;
$$ LANGUAGE plpgsql;

-- 2. Функция для сегментации клиентов по RFM
CREATE OR REPLACE FUNCTION calculate_rfm_segment(
    customer_id INTEGER
) RETURNS TABLE(
    recency INTEGER,
    frequency INTEGER,
    monetary DECIMAL,
    rfm_score VARCHAR(3)
) AS $$
BEGIN
    RETURN QUERY
    WITH customer_stats AS (
        SELECT 
            c.customer_id,
            EXTRACT(DAY FROM (CURRENT_DATE - MAX(s.sale_date)))::INTEGER as recency,
            COUNT(DISTINCT s.sale_date) as frequency,
            COALESCE(SUM(s.total_amount), 0) as monetary
        FROM customers c
        LEFT JOIN sales s ON c.customer_id = s.customer_id
        WHERE c.customer_id = $1
        GROUP BY c.customer_id
    )
    SELECT 
        cs.recency,
        cs.frequency,
        cs.monetary,
        CASE 
            WHEN cs.recency < 30 AND cs.frequency > 10 AND cs.monetary > 50000 THEN '111'
            WHEN cs.recency < 60 AND cs.frequency > 5 THEN '211'
            WHEN cs.recency < 90 THEN '311'
            ELSE '444'
        END as rfm_score
    FROM customer_stats cs;
END;
$$ LANGUAGE plpgsql;

-- 3. Функция для прогнозирования продаж на основе скользящего среднего
CREATE OR REPLACE FUNCTION forecast_sales_moving_average(
    product_id INTEGER,
    days_ahead INTEGER DEFAULT 30
) RETURNS DECIMAL AS $$
DECLARE
    avg_daily_sales DECIMAL;
    forecast DECIMAL;
BEGIN
    SELECT AVG(daily_sales)
    INTO avg_daily_sales
    FROM (
        SELECT sale_date::DATE, SUM(quantity) as daily_sales
        FROM sales
        WHERE product_id = $1
          AND sale_date >= CURRENT_DATE - INTERVAL '90 days'
        GROUP BY sale_date::DATE
    ) sub;
    
    forecast := COALESCE(avg_daily_sales, 0) * days_ahead;
    RETURN forecast;
END;
$$ LANGUAGE plpgsql;