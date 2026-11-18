/* FIND TOTAL SALES PER MONTH */

SELECT 
    DATE_PART('month', order_date) AS month,
    SUM(total_amount) OVER (PARTITION BY DATE_PART('month', order_date)) AS total_sales_per_month
FROM orders;

/* FIND TOTAL SALES PER QUARTER */

SELECT 
    DATE_PART('quarter', order_date) AS quarter,
    SUM(total_amount) OVER (PARTITION BY DATE_PART('quarter', order_date)) AS total_sales_per_quarter
FROM orders;


/* FIND TOTAL SALES PER YEAR */
SELECT 
    DATE_PART('year', order_date) AS year,
    SUM(total_amount) OVER (PARTITION BY DATE_PART('year', order_date)) AS total_sales_per_year
FROM orders;

/* FIND TOTAL SALES PER MONTH AND SUBTRACT PREVIOUS MONTH'S SALES */
SELECT 
    DATE_PART('month', order_date) AS month,
    SUM(total_amount) OVER (PARTITION BY DATE_PART('month', order_date)) AS total_sales_per_month,
    LAG(SUM(total_amount) OVER (PARTITION BY DATE_PART('month', order_date))) OVER (ORDER BY DATE_PART('month', order_date)) AS previous_month_sales
FROM orders;


/* FIND TOTAL SALES PER MONTH AND SUBTRACT IT FROM NEXT MONTH'S SALES */
SELECT 
    DATE_PART('month', order_date) AS month,
    SUM(total_amount) OVER (PARTITION BY DATE_PART('month', order_date)) AS total_sales_per_month,
    LEAD(SUM(total_amount) OVER (PARTITION BY DATE_PART('month', order_date))) OVER (ORDER BY DATE_PART('month', order_date)) AS next_month_sales
FROM orders;

/* FIND TOTAL SALES PER MONTH FOR EACH PRODUCT ORDERED DESCENDING BY SALES */
SELECT 
    DATE_PART('month', order_date) AS month,
    product_id,
    SUM(total_amount) OVER (PARTITION BY DATE_PART('month', order_date), product_id ) AS total_sales_per_month_per_product
FROM orders
ORDER BY total_sales_per_month_per_product DESC;

/* CHECK IF THERE IS NULL IN COLUMN SALES AND REPLACE IT WITH 0 BEFORE AGGREGATION */

SELECT
    DATE_PART('month', order_date) AS month,
    product_id,
    COALESCE(SUM(total_amount), 0) AS total_sales_per_month_per_product
FROM orders
GROUP BY DATE_PART('month', order_date), product_id
ORDER BY total_sales_per_month_per_product DESC;

/* JOIN TABLE ORDERS WITH TABLE CUSTOMERS WHERE SHOW ORDERS AND CUSTOMERS EVEN ORDERS WITHOUT CUSTOMERS DETAILS */
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_id,
    c.customer_name
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id;

/* JOIN TABLE ORDERS WITH TABLE CUSTOMERS WHERE ORDERS AND CUSTOMERS BOTH AVAILABLE  */
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_id,
    c.customer_name
FROM orders o
INNER JOIN customers c 
ON o.customer_id = c.customer_id;


/* SHOW USERS HOW DIDN'T MAKE ANY ORDERS YET */
SELECT 
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
;

/* COUNT USERS HOW DIDN'T MAKE ANY ORDERS YET */
SELECT 
    COUNT(c.customer_id) AS users_without_orders
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
;

/* CATEGORIZE PRODUCTS BY PRICE RANGE */
SELECT 
    product_id,
    product_name,
    CASE 
        WHEN price < 10 THEN 'Low'
        WHEN price BETWEEN 10 AND 100 THEN 'Medium'
        ELSE 'High'
    END AS price_category
FROM products;

/* SHOW TOP 10 PRODUCTS BY SALES */
SELECT TOP 10
    product_id,
    product_name,
    SUM(total_amount) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY product_id, product_name
ORDER BY total_sales DESC
;


/* CATEGORIZE PRODUCTS BY PRICE RANGE AND AFTER THAT SHOW TOTAL SALES FOR EACH CATEGORY */
SELECT 
    CASE 
        WHEN p.price < 10 THEN 'Low'
        WHEN p.price BETWEEN 10 AND 100 THEN 'Medium'
        ELSE 'High'
    END AS price_category,
    SUM(o.total_amount) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY price_category
ORDER BY total_sales DESC
;

/* SHOW HIGHEST PRODUCT SALES EVERY MONTH */
SELECT 
    DATE_PART('month', o.order_date) AS month,
    o.product_id,
    p.product_name,
    SUM(o.total_amount) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY DATE_PART('month', o.order_date), o.product_id, p.product_name
ORDER BY month, total_sales DESC
;

/* RANK PRODUCTS BY SALES */
SELECT 
    product_id,
    product_name,
    SUM(total_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS sales_rank
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY product_id, product_name
;

/* RANK MONTHS BY SALES */
SELECT 
    DATE_PART('month', o.order_date) AS month,
    SUM(o.total_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS sales_rank
FROM orders o
GROUP BY DATE_PART('month', o.order_date)
ORDER BY month;

/* DIVIDE PRODUCTS BY SALES TO 5 GROUPS */
SELECT 
    product_id,
    product_name,
    SUM(total_amount) AS total_sales,
    NTILE(5) OVER (ORDER BY SUM(total_amount) DESC) AS sales_quartile
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY product_id, product_name
;

/* SEARCH FOR EMPLOYEES WHO ARE FROM A SPECIFIC CITY */
SELECT 
    employee_id,
    employee_name,
    city
FROM employees
WHERE city = 'BAGHDAD';

/* SEARCH FOR FEMALE CUSTOMERS WHO ARE FROM A SPECIFIC CITY AND AND THEIR AGE IS LESS THAN 30  AND COUNT THEM */
SELECT
    *,
    COUNT(*) AS female_customers_count
FROM customers
WHERE city = 'BAGHDAD' AND gender = 'Female' AND age < 30
GROUP BY city, gender, age
;

/* SEARCH FOR FEMALE CUSTOMERS WHO ARE FROM A SPECIFIC CITY AND AND THEIR AGE IS LESS THAN 30
  AND COUNT THEM AND RANK THEM BASED ON THEIR SALES */
SELECT
    *,
    COUNT(*) AS female_customers_count,
    RANK() OVER (ORDER BY SUM(total_amount) DESC) AS sales_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'BAGHDAD' AND c.gender = 'Female' AND c.age < 30
GROUP BY c.customer_id, c.customer_name, c.city, c.gender, c.age
;

/* COUNT AVERAGE SALES PER CUSTOMER AFTER THAT COUNT CUSTOMERS WHO BUY MORE THAN THE AVERAGE */
SELECT 
    average_sales_per_customer,
    COUNT(*) AS customers_above_average
FROM (
    SELECT 
        c.customer_id,
        AVG(o.total_amount) AS average_sales_per_customer
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
) AS customer_averages
WHERE average_sales_per_customer > (SELECT AVG(average_sales_per_customer) FROM customer_averages)
;

/* SHOW ALL DEPARTMENTS WHO HAVE EMPLOYEES MORE THAB MARKETING DEPARTMENTS */
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) > (
    SELECT COUNT(employee_id)
    FROM employees
    WHERE department_id = (
        SELECT department_id
        FROM departments
        WHERE department_name = 'MARKETING'
    )
)
;


