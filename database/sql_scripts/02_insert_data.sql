-- Заполнение таблицы регионов
INSERT INTO regions (region_name, country) VALUES
('Москва', 'Россия'),
('Санкт-Петербург', 'Россия'),
('Новосибирск', 'Россия'),
('Екатеринбург', 'Россия'),
('Казань', 'Россия');

-- Заполнение категорий
INSERT INTO categories (category_name, profit_margin) VALUES
('Электроника', 25.00),
('Одежда', 40.00),
('Книги', 20.00),
('Продукты питания', 15.00),
('Мебель', 30.00);

-- Заполнение продуктов
INSERT INTO products (product_name, category_id, unit_price, cost_price, stock_quantity) VALUES
('Смартфон XYZ', 1, 29999.99, 22000.00, 100),
('Ноутбук ABC', 1, 79999.99, 65000.00, 50),
('Футболка', 2, 1999.99, 1200.00, 200),
('Джинсы', 2, 4999.99, 3000.00, 150),
('Книга "SQL для анализа"', 3, 1499.99, 1000.00, 75);

-- Заполнение сегментов клиентов
INSERT INTO customer_segments (segment_name, min_purchase_amount, max_purchase_amount, description) VALUES
('VIP', 50000.00, NULL, 'Клиенты с высокой покупательской способностью'),
('Стандарт', 10000.00, 49999.99, 'Средние по объему покупок клиенты'),
('Эконом', 0.00, 9999.99, 'Клиенты с небольшими покупками'),
('Новые', NULL, NULL, 'Недавно зарегистрированные клиенты');

-- Заполнение клиентов
INSERT INTO customers (first_name, last_name, email, region_id, segment_id, total_purchases) VALUES
('Иван', 'Иванов', 'ivanov@mail.ru', 1, 1, 150000.00),
('Мария', 'Петрова', 'petrova@mail.ru', 2, 2, 35000.00),
('Алексей', 'Сидоров', 'sidorov@mail.ru', 3, 3, 8000.00),
('Ольга', 'Смирнова', 'smirnova@mail.ru', 1, 4, 5000.00);

-- Заполнение сотрудников
INSERT INTO employees (first_name, last_name, position, hire_date, department) VALUES
('Дмитрий', 'Козлов', 'Менеджер по продажам', '2022-01-15', 'Продажи'),
('Анна', 'Волкова', 'Старший менеджер', '2021-03-10', 'Продажи'),
('Сергей', 'Павлов', 'Аналитик', '2023-06-20', 'Аналитика');

-- Заполнение продаж (пример за последние 6 месяцев)
INSERT INTO sales (customer_id, product_id, employee_id, sale_date, quantity, unit_price, discount, payment_method)
SELECT 
    c.customer_id,
    p.product_id,
    e.employee_id,
    CURRENT_DATE - INTERVAL '1 day' * FLOOR(RANDOM() * 180),
    FLOOR(RANDOM() * 5) + 1,
    p.unit_price,
    CASE WHEN RANDOM() > 0.7 THEN 10.00 ELSE 0.00 END,
    (ARRAY['Наличные', 'Карта', 'Онлайн'])[FLOOR(RANDOM() * 3) + 1]
FROM customers c
CROSS JOIN products p
CROSS JOIN employees e
LIMIT 1000;

-- Обновление общей суммы покупок клиентов
UPDATE customers c
SET total_purchases = (
    SELECT COALESCE(SUM(total_amount), 0)
    FROM sales s
    WHERE s.customer_id = c.customer_id
);

-- Обновление даты последней покупки
UPDATE customers c
SET last_purchase_date = (
    SELECT MAX(sale_date)
    FROM sales s
    WHERE s.customer_id = c.customer_id
);
