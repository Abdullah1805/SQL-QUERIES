/* FIND TOTAL SALES PER MONTH */

SELECT
    YEAR(order_date)  AS [year],
    MONTH(order_date) AS [month],
    SUM(total_amount) AS total_sales_per_month
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY [year], [month];

/* FIND TOTAL SALES PER QUARTER */

SELECT
    YEAR(order_date)              AS [year],
    DATEPART(quarter, order_date) AS [quarter],
    SUM(total_amount)             AS total_sales_per_quarter
FROM orders
GROUP BY YEAR(order_date), DATEPART(quarter, order_date)
ORDER BY [year], [quarter];


/* FIND TOTAL SALES PER YEAR */
SELECT
    YEAR(order_date)  AS [year],
    SUM(total_amount) AS total_sales_per_year
FROM orders
GROUP BY YEAR(order_date)
ORDER BY [year];

/* FIND TOTAL SALES PER MONTH AND SUBTRACT IT FROM NEXT MONTH'S SALES */
WITH monthly_sales AS (
    SELECT
        YEAR(order_date)  AS [year],
        MONTH(order_date) AS [month],
        SUM(total_amount) AS total_sales_per_month
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    [year],
    [month],
    total_sales_per_month,
    LEAD(total_sales_per_month) OVER (ORDER BY [year], [month]) AS next_month_sales,
    LEAD(total_sales_per_month) OVER (ORDER BY [year], [month])
        - total_sales_per_month AS diff_to_next_month
FROM monthly_sales
ORDER BY [year], [month];


/* FIND TOTAL SALES PER MONTH AND SUBTRACT LAST MONTH'S SALES FROM IT */
WITH monthly_sales AS (
    SELECT
        YEAR(order_date)  AS [year],
        MONTH(order_date) AS [month],
        SUM(total_amount) AS total_sales_per_month
    FROM orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT
    [year],
    [month],
    total_sales_per_month,
    LAG(total_sales_per_month) OVER (ORDER BY [year], [month]) AS previous_month_sales,
    total_sales_per_month
        - LAG(total_sales_per_month) OVER (ORDER BY [year], [month]) AS diff_from_previous_month
FROM monthly_sales
ORDER BY [year], [month];

/* FIND TOTAL SALES PER MONTH FOR EACH PRODUCT ORDERED DESCENDING BY SALES */
SELECT
    YEAR(order_date)  AS [year],
    MONTH(order_date) AS [month],
    product_id,
    SUM(total_amount) AS total_sales_per_month_per_product
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date), product_id
ORDER BY total_sales_per_month_per_product DESC;

/* CHECK IF THERE IS NULL IN COLUMN SALES AND REPLACE IT WITH 0 BEFORE AGGREGATION */

SELECT
    YEAR(order_date)  AS [year],
    MONTH(order_date) AS [month],
    product_id,
    SUM(COALESCE(total_amount, 0)) AS total_sales_per_month_per_product
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date), product_id
ORDER BY total_sales_per_month_per_product DESC;

/* JOIN TABLE ORDERS WITH TABLE CUSTOMERS TO SHOW ORDERS AND CUSTOMERS EVEN ORDERS WITHOUT CUSTOMERS DETAILS */
SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_id,
    c.customer_name
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id;

/* JOIN TABLE ORDERS WITH TABLE CUSTOMERS WHERE ORDERS AND CUSTOMERS ARE BOTH AVAILABLE  */
SELECT
    o.order_id,
    o.order_date,
    o.total_amount,
    c.customer_id,
    c.customer_name
FROM orders o
INNER JOIN customers c
ON o.customer_id = c.customer_id;


/* SHOW USERS WHO DIDN'T MAKE ANY ORDERS YET */
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
;

/* COUNT USERS WHO DIDN'T MAKE ANY ORDERS YET */
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
    p.product_id,
    p.product_name,
    SUM(o.total_amount) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_sales DESC
;


/* CATEGORIZE PRODUCTS BY PRICE RANGE AND THEN SHOW TOTAL SALES FOR EACH CATEGORY */
SELECT
    price_category,
    SUM(total_amount) AS total_sales
FROM (
    SELECT
        CASE
            WHEN p.price < 10 THEN 'Low'
            WHEN p.price BETWEEN 10 AND 100 THEN 'Medium'
            ELSE 'High'
        END AS price_category,
        o.total_amount
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
) AS categorized_sales
GROUP BY price_category
ORDER BY total_sales DESC
;

/* SHOW HIGHEST PRODUCT SALES EVERY MONTH */
WITH monthly_product_sales AS (
    SELECT
        YEAR(o.order_date)  AS [year],
        MONTH(o.order_date) AS [month],
        o.product_id,
        p.product_name,
        SUM(o.total_amount) AS total_sales,
        RANK() OVER (
            PARTITION BY YEAR(o.order_date), MONTH(o.order_date)
            ORDER BY SUM(o.total_amount) DESC
        ) AS sales_rank
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    GROUP BY YEAR(o.order_date), MONTH(o.order_date), o.product_id, p.product_name
)
SELECT
    [year],
    [month],
    product_id,
    product_name,
    total_sales
FROM monthly_product_sales
WHERE sales_rank = 1
ORDER BY [year], [month]
;

/* RANK PRODUCTS BY SALES */
SELECT
    p.product_id,
    p.product_name,
    SUM(o.total_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS sales_rank
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
;

/* RANK MONTHS BY SALES */
SELECT
    YEAR(o.order_date)  AS [year],
    MONTH(o.order_date) AS [month],
    SUM(o.total_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS sales_rank
FROM orders o
GROUP BY YEAR(o.order_date), MONTH(o.order_date)
ORDER BY [year], [month];

/* DIVIDE PRODUCTS BY SALES INTO 5 GROUPS */
SELECT
    p.product_id,
    p.product_name,
    SUM(o.total_amount) AS total_sales,
    NTILE(5) OVER (ORDER BY SUM(o.total_amount) DESC) AS sales_quintile
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_id, p.product_name
;

/* SEARCH FOR EMPLOYEES WHO ARE FROM A SPECIFIC CITY */
SELECT
    employee_id,
    employee_name,
    city
FROM employees
WHERE city = 'BAGHDAD';

/* SEARCH FOR FEMALE CUSTOMERS WHO ARE FROM A SPECIFIC CITY AND THEIR AGE IS LESS THAN 30  AND COUNT THEM */
SELECT
    *,
    COUNT(*) OVER () AS female_customers_count
FROM customers
WHERE city = 'BAGHDAD' AND gender = 'Female' AND age < 30
;

/* SEARCH FOR FEMALE CUSTOMERS WHO ARE FROM A SPECIFIC CITY AND WHOSE AGE IS LESS THAN 30
  AND COUNT THEM AND RANK THEM BASED ON THEIR SALES */
SELECT
    c.customer_id,
    c.customer_name,
    c.city,
    c.gender,
    c.age,
    SUM(o.total_amount) AS total_sales,
    COUNT(*) OVER () AS female_customers_count,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS sales_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'BAGHDAD' AND c.gender = 'Female' AND c.age < 30
GROUP BY c.customer_id, c.customer_name, c.city, c.gender, c.age
ORDER BY sales_rank
;

/* COUNT AVERAGE SALES PER CUSTOMER AFTER THAT COUNT CUSTOMERS WHO BUY MORE THAN THE AVERAGE */
WITH customer_sales AS (
    SELECT
        c.customer_id,
        SUM(o.total_amount) AS total_sales_per_customer
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT
    (SELECT AVG(total_sales_per_customer * 1.0) FROM customer_sales) AS average_sales_per_customer,
    COUNT(*) AS customers_above_average
FROM customer_sales
WHERE total_sales_per_customer > (SELECT AVG(total_sales_per_customer * 1.0) FROM customer_sales)
;

/* SHOW ALL DEPARTMENTS WHO HAVE EMPLOYEES MORE THAN THE MARKETING DEPARTMENT */
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
    WHERE department_id IN (
        SELECT department_id
        FROM departments
        WHERE department_name = 'MARKETING'
    )
)
;

/* SHOW THE TOP 3 SALARIES IN EACH DEPARTMENT AT THE COMPANY */
WITH RankedSalaries AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.salary,
        e.department_id,
        DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank
    FROM employees e
)
SELECT
    employee_id,
    employee_name,
    salary,
    department_id,
    salary_rank
FROM RankedSalaries
WHERE salary_rank <= 3
ORDER BY department_id, salary_rank
;
