-- Создание базы данных
CREATE DATABASE sales_analysis_platform;
\c sales_analysis_platform;

-- Таблица регионов
CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица категорий товаров
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_category_id INTEGER REFERENCES categories(category_id),
    profit_margin DECIMAL(5,2) DEFAULT 0.0
);

-- Таблица продуктов
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES categories(category_id),
    unit_price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    created_at DATE DEFAULT CURRENT_DATE
);

-- Таблица сегментов клиентов
CREATE TABLE customer_segments (
    segment_id SERIAL PRIMARY KEY,
    segment_name VARCHAR(50) NOT NULL,
    min_purchase_amount DECIMAL(10,2),
    max_purchase_amount DECIMAL(10,2),
    description TEXT
);

-- Таблица клиентов
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    region_id INTEGER REFERENCES regions(region_id),
    segment_id INTEGER REFERENCES customer_segments(segment_id),
    registration_date DATE DEFAULT CURRENT_DATE,
    total_purchases DECIMAL(10,2) DEFAULT 0.00,
    last_purchase_date DATE
);

-- Таблица сотрудников
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    hire_date DATE,
    department VARCHAR(50)
);

-- Основная таблица продаж
CREATE TABLE sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    product_id INTEGER REFERENCES products(product_id),
    employee_id INTEGER REFERENCES employees(employee_id),
    sale_date TIMESTAMP NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    discount DECIMAL(5,2) DEFAULT 0.00,
    payment_method VARCHAR(20)
);

-- Таблица для хранения прогнозов
CREATE TABLE sales_forecast (
    forecast_id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(product_id),
    forecast_date DATE NOT NULL,
    predicted_quantity DECIMAL(10,2),
    confidence_interval_low DECIMAL(10,2),
    confidence_interval_high DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица для анализа трендов
CREATE TABLE sales_trends (
    trend_id SERIAL PRIMARY KEY,
    analysis_date DATE NOT NULL,
    product_category VARCHAR(100),
    trend_direction VARCHAR(20),
    strength DECIMAL(5,2),
    notes TEXT
);

-- Индекс для ускорения запросов по дате продажи
CREATE INDEX idx_sales_date ON sales(sale_date);

-- Индекс для ускорения поиска по клиентам
CREATE INDEX idx_sales_customer ON sales(customer_id);

-- Индекс для ускорения поиска по продуктам
CREATE INDEX idx_sales_product ON sales(product_id);

-- Составной индекс для часто используемых запросов
CREATE INDEX idx_sales_date_customer ON sales(sale_date, customer_id);