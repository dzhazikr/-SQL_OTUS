-- 1. Процедура для обновления сегментов клиентов
CREATE OR REPLACE PROCEDURE update_customer_segments()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Временная таблица с обновленными сегментами
    CREATE TEMP TABLE temp_segments AS
    SELECT 
        c.customer_id,
        CASE 
            WHEN c.total_purchases >= 50000 THEN 1  -- VIP
            WHEN c.total_purchases >= 10000 THEN 2  -- Стандарт
            WHEN c.total_purchases > 0 THEN 3       -- Эконом
            ELSE 4                                   -- Новые
        END as new_segment_id
    FROM customers c;
    
    -- Обновление основной таблицы
    UPDATE customers c
    SET segment_id = ts.new_segment_id
    FROM temp_segments ts
    WHERE c.customer_id = ts.customer_id
      AND c.segment_id != ts.new_segment_id;
    
    DROP TABLE temp_segments;
    
    COMMIT;
END;
$$;

-- 2. Процедура для генерации ежедневного отчета
CREATE OR REPLACE PROCEDURE generate_daily_report(
    report_date DATE DEFAULT CURRENT_DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    daily_total DECIMAL;
    avg_order_value DECIMAL;
    top_product VARCHAR;
BEGIN
    -- Расчет дневной выручки
    SELECT COALESCE(SUM(total_amount), 0)
    INTO daily_total
    FROM sales
    WHERE sale_date::DATE = report_date;
    
    -- Расчет среднего чека
    SELECT COALESCE(AVG(total_amount), 0)
    INTO avg_order_value
    FROM sales
    WHERE sale_date::DATE = report_date;
    
    -- Самый продаваемый товар дня
    SELECT p.product_name
    INTO top_product
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE s.sale_date::DATE = report_date
    GROUP BY p.product_name
    ORDER BY SUM(s.quantity) DESC
    LIMIT 1;
    
    -- Вывод отчета
    RAISE NOTICE 'Отчет за %', report_date;
    RAISE NOTICE 'Общая выручка: % руб.', daily_total;
    RAISE NOTICE 'Средний чек: % руб.', avg_order_value;
    RAISE NOTICE 'Топ товар: %', COALESCE(top_product, 'Нет продаж');
    
END;
$$;

-- 3. Процедура для анализа сезонности
CREATE OR REPLACE PROCEDURE analyze_seasonality(
    year_param INTEGER DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)
)
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE monthly_sales AS
    SELECT 
        EXTRACT(MONTH FROM sale_date) as month_num,
        EXTRACT(YEAR FROM sale_date) as year_num,
        SUM(total_amount) as monthly_revenue,
        COUNT(*) as order_count
    FROM sales
    WHERE EXTRACT(YEAR FROM sale_date) = year_param
    GROUP BY EXTRACT(MONTH FROM sale_date), EXTRACT(YEAR FROM sale_date)
    ORDER BY month_num;
    
    RAISE NOTICE 'Анализ сезонности за % год:', year_param;
    FOR rec IN SELECT * FROM monthly_sales ORDER BY month_num
    LOOP
        RAISE NOTICE 'Месяц %: Выручка % руб., Заказов: %', 
            rec.month_num, rec.monthly_revenue, rec.order_count;
    END LOOP;
    
    DROP TABLE monthly_sales;
END;
$$;