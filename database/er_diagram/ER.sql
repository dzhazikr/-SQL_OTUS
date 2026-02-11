// Создайте файл er_diagram.dbd и вставьте этот код:

Table regions {
  region_id integer [primary key]
  region_name varchar(100)
  country varchar(50)
  created_at timestamp
}

Table categories {
  category_id integer [primary key]
  category_name varchar(100)
  parent_category_id integer [ref: > categories.category_id]
  profit_margin decimal(5,2)
}

Table products {
  product_id integer [primary key]
  product_name varchar(200)
  category_id integer [ref: > categories.category_id]
  unit_price decimal(10,2)
  cost_price decimal(10,2)
  stock_quantity integer
  created_at date
}

Table customer_segments {
  segment_id integer [primary key]
  segment_name varchar(50)
  min_purchase_amount decimal(10,2)
  max_purchase_amount decimal(10,2)
  description text
}

Table customers {
  customer_id integer [primary key]
  first_name varchar(100)
  last_name varchar(100)
  email varchar(150)
  phone varchar(20)
  region_id integer [ref: > regions.region_id]
  segment_id integer [ref: > customer_segments.segment_id]
  registration_date date
  total_purchases decimal(10,2)
  last_purchase_date date
}

Table employees {
  employee_id integer [primary key]
  first_name varchar(100)
  last_name varchar(100)
  position varchar(100)
  hire_date date
  department varchar(50)
}

Table sales {
  sale_id integer [primary key]
  customer_id integer [ref: > customers.customer_id]
  product_id integer [ref: > products.product_id]
  employee_id integer [ref: > employees.employee_id]
  sale_date timestamp
  quantity integer
  unit_price decimal(10,2)
  total_amount decimal(10,2)
  discount decimal(5,2)
  payment_method varchar(20)
}

Table sales_forecast {
  forecast_id integer [primary key]
  product_id integer [ref: > products.product_id]
  forecast_date date
  predicted_quantity decimal(10,2)
  confidence_interval_low decimal(10,2)
  confidence_interval_high decimal(10,2)
  created_at timestamp
}

Table sales_trends {
  trend_id integer [primary key]
  analysis_date date
  product_category varchar(100)
  trend_direction varchar(20)
  strength decimal(5,2)
  notes text
}

Ref: sales.customer_id > customers.customer_id
Ref: sales.product_id > products.product_id
Ref: sales.employee_id > employees.employee_id
Ref: customers.region_id > regions.region_id
Ref: customers.segment_id > customer_segments.segment_id
Ref: products.category_id > categories.category_id
Ref: sales_forecast.product_id > products.product_id
