-- Multi-table INSERT statements
-- Tests INSERT ALL, INSERT FIRST, conditional INSERT

-- Basic INSERT ALL - insert into multiple tables
INSERT ALL
    INTO sales_history VALUES (product_id, sale_date, amount)
    INTO sales_summary VALUES (product_id, TO_CHAR(sale_date, 'YYYY-MM'), amount)
SELECT product_id, sale_date, amount
FROM sales
WHERE sale_date < ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -1);

-- INSERT ALL with different column mappings
INSERT ALL
    INTO employees_backup (emp_id, emp_name) VALUES (employee_id, first_name)
    INTO employee_salaries (emp_id, salary_amount) VALUES (employee_id, salary)
SELECT employee_id, first_name, salary
FROM employees
WHERE department_id = 50;

-- INSERT ALL with expressions
INSERT ALL
    INTO monthly_sales VALUES (product_id, 'January', jan_sales)
    INTO monthly_sales VALUES (product_id, 'February', feb_sales)
    INTO monthly_sales VALUES (product_id, 'March', mar_sales)
SELECT product_id, jan_sales, feb_sales, mar_sales
FROM quarterly_data
WHERE quarter = 'Q1';

-- INSERT ALL with WHERE clauses on individual INSERTs
INSERT ALL
    WHEN department_id = 10 THEN
        INTO dept_10_employees VALUES (employee_id, first_name, salary)
    WHEN department_id = 20 THEN
        INTO dept_20_employees VALUES (employee_id, first_name, salary)
    WHEN department_id = 30 THEN
        INTO dept_30_employees VALUES (employee_id, first_name, salary)
SELECT employee_id, first_name, salary, department_id
FROM employees;

-- INSERT FIRST - inserts into first matching table only
INSERT FIRST
    WHEN salary > 10000 THEN
        INTO high_earners VALUES (employee_id, first_name, salary)
    WHEN salary > 5000 THEN
        INTO medium_earners VALUES (employee_id, first_name, salary)
    WHEN salary > 0 THEN
        INTO low_earners VALUES (employee_id, first_name, salary)
SELECT employee_id, first_name, salary
FROM employees;

-- INSERT ALL with ELSE clause
INSERT ALL
    WHEN department_id IN (10, 20) THEN
        INTO priority_depts VALUES (employee_id, department_id, salary)
    WHEN salary > 8000 THEN
        INTO high_salary_employees VALUES (employee_id, salary)
    ELSE
        INTO other_employees VALUES (employee_id, first_name, last_name)
SELECT employee_id, first_name, last_name, department_id, salary
FROM employees;

-- INSERT FIRST with ELSE clause
INSERT FIRST
    WHEN hire_date >= ADD_MONTHS(SYSDATE, -12) THEN
        INTO new_hires VALUES (employee_id, first_name, hire_date)
    WHEN hire_date >= ADD_MONTHS(SYSDATE, -36) THEN
        INTO recent_hires VALUES (employee_id, first_name, hire_date)
    ELSE
        INTO veteran_employees VALUES (employee_id, first_name, hire_date)
SELECT employee_id, first_name, hire_date
FROM employees;

-- INSERT ALL with complex conditions
INSERT ALL
    WHEN salary > 10000 AND commission_pct IS NOT NULL THEN
        INTO high_commission_employees VALUES (employee_id, salary, commission_pct)
    WHEN department_id IN (50, 60, 80) AND job_id LIKE 'SA%' THEN
        INTO sales_team VALUES (employee_id, first_name, job_id)
    WHEN manager_id IS NULL THEN
        INTO executives VALUES (employee_id, first_name, last_name)
SELECT employee_id, first_name, last_name, salary, commission_pct, department_id, job_id, manager_id
FROM employees;

-- INSERT ALL with multiple inserts per condition
INSERT ALL
    WHEN sale_amount > 10000 THEN
        INTO large_sales VALUES (sale_id, customer_id, sale_amount)
        INTO high_value_customers VALUES (customer_id, sale_date)
    WHEN sale_amount > 5000 THEN
        INTO medium_sales VALUES (sale_id, customer_id, sale_amount)
SELECT sale_id, customer_id, sale_amount, sale_date
FROM sales;

-- INSERT ALL with aggregate source data
INSERT ALL
    INTO dept_employee_count VALUES (department_id, emp_count)
    INTO dept_salary_total VALUES (department_id, salary_total)
    INTO dept_salary_avg VALUES (department_id, salary_avg)
SELECT department_id,
       COUNT(*) as emp_count,
       SUM(salary) as salary_total,
       AVG(salary) as salary_avg
FROM employees
GROUP BY department_id;

-- INSERT ALL pivoting data
INSERT ALL
    INTO sales_by_month VALUES (product_id, 'JAN', jan_amount)
    INTO sales_by_month VALUES (product_id, 'FEB', feb_amount)
    INTO sales_by_month VALUES (product_id, 'MAR', mar_amount)
    INTO sales_by_month VALUES (product_id, 'APR', apr_amount)
SELECT product_id, jan_amount, feb_amount, mar_amount, apr_amount
FROM product_quarterly_sales;

-- INSERT FIRST with date range conditions
INSERT FIRST
    WHEN TO_CHAR(order_date, 'Q') = '1' THEN
        INTO q1_orders VALUES (order_id, order_date, amount)
    WHEN TO_CHAR(order_date, 'Q') = '2' THEN
        INTO q2_orders VALUES (order_id, order_date, amount)
    WHEN TO_CHAR(order_date, 'Q') = '3' THEN
        INTO q3_orders VALUES (order_id, order_date, amount)
    WHEN TO_CHAR(order_date, 'Q') = '4' THEN
        INTO q4_orders VALUES (order_id, order_date, amount)
SELECT order_id, order_date, amount
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 2024;

-- INSERT ALL with JOIN in source query
INSERT ALL
    INTO employee_dept_archive VALUES (employee_id, emp_name, dept_name)
    INTO salary_archive VALUES (employee_id, salary, hire_date)
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name as emp_name,
       d.department_name as dept_name,
       e.salary,
       e.hire_date
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.hire_date < ADD_MONTHS(SYSDATE, -60);

-- INSERT ALL with subquery in source
INSERT ALL
    INTO high_performers VALUES (employee_id, performance_score)
    INTO bonus_eligible VALUES (employee_id, bonus_amount)
SELECT employee_id,
       performance_score,
       performance_score * 1000 as bonus_amount
FROM (
    SELECT e.employee_id,
           (e.salary / dept_avg.avg_sal) * 100 as performance_score
    FROM employees e
    JOIN (
        SELECT department_id, AVG(salary) as avg_sal
        FROM employees
        GROUP BY department_id
    ) dept_avg ON e.department_id = dept_avg.department_id
)
WHERE performance_score > 120;

-- INSERT FIRST with priority-based routing
INSERT FIRST
    WHEN priority = 'CRITICAL' THEN
        INTO critical_queue VALUES (task_id, task_description, priority)
    WHEN priority = 'HIGH' THEN
        INTO high_priority_queue VALUES (task_id, task_description, priority)
    WHEN priority = 'MEDIUM' THEN
        INTO medium_priority_queue VALUES (task_id, task_description, priority)
    ELSE
        INTO low_priority_queue VALUES (task_id, task_description, priority)
SELECT task_id, task_description, priority
FROM incoming_tasks;

-- INSERT ALL with calculated fields
INSERT ALL
    WHEN region = 'North' THEN
        INTO north_region_sales VALUES (sale_id, amount, tax_amount, total_amount)
    WHEN region = 'South' THEN
        INTO south_region_sales VALUES (sale_id, amount, tax_amount, total_amount)
SELECT sale_id,
       amount,
       amount * 0.08 as tax_amount,
       amount * 1.08 as total_amount,
       region
FROM sales;

-- INSERT ALL with CASE expressions in conditions
INSERT ALL
    WHEN customer_category = 'Premium' THEN
        INTO premium_customers VALUES (customer_id, customer_name, discount_rate)
    WHEN customer_category = 'Standard' THEN
        INTO standard_customers VALUES (customer_id, customer_name, discount_rate)
SELECT customer_id,
       customer_name,
       CASE
           WHEN total_purchases > 100000 THEN 'Premium'
           ELSE 'Standard'
       END as customer_category,
       CASE
           WHEN total_purchases > 100000 THEN 0.15
           ELSE 0.05
       END as discount_rate
FROM customer_summary;

-- INSERT FIRST with overlapping conditions (only first match wins)
INSERT FIRST
    WHEN salary > 15000 THEN
        INTO executives VALUES (employee_id, salary)
    WHEN salary > 10000 THEN  -- This won't match if salary > 15000
        INTO senior_staff VALUES (employee_id, salary)
    WHEN salary > 5000 THEN   -- This won't match if salary > 10000
        INTO mid_level_staff VALUES (employee_id, salary)
    ELSE
        INTO junior_staff VALUES (employee_id, salary)
SELECT employee_id, salary
FROM employees;

-- INSERT ALL partitioning by year
INSERT ALL
    INTO sales_2021 VALUES (sale_id, sale_date, amount)
    INTO sales_2022 VALUES (sale_id, sale_date, amount)
    INTO sales_2023 VALUES (sale_id, sale_date, amount)
    INTO sales_2024 VALUES (sale_id, sale_date, amount)
SELECT s.sale_id,
       s.sale_date,
       s.amount
FROM sales s
WHERE EXTRACT(YEAR FROM s.sale_date) BETWEEN 2021 AND 2024;

-- INSERT ALL with NULL handling
INSERT ALL
    WHEN commission_pct IS NOT NULL THEN
        INTO commissioned_employees VALUES (employee_id, salary, commission_pct)
    WHEN commission_pct IS NULL THEN
        INTO salaried_employees VALUES (employee_id, salary)
SELECT employee_id, salary, commission_pct
FROM employees;

-- INSERT FIRST with type-based routing
INSERT FIRST
    WHEN transaction_type = 'SALE' THEN
        INTO sales_transactions VALUES (trans_id, trans_date, amount)
    WHEN transaction_type = 'REFUND' THEN
        INTO refund_transactions VALUES (trans_id, trans_date, amount)
    WHEN transaction_type = 'ADJUSTMENT' THEN
        INTO adjustment_transactions VALUES (trans_id, trans_date, amount)
    ELSE
        INTO other_transactions VALUES (trans_id, trans_date, amount, transaction_type)
SELECT trans_id, trans_date, amount, transaction_type
FROM all_transactions;

-- INSERT ALL with analytical functions in source
INSERT ALL
    INTO ranked_employees VALUES (employee_id, salary, dept_rank)
    INTO percentile_employees VALUES (employee_id, salary, salary_percentile)
SELECT employee_id,
       salary,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_rank,
       PERCENT_RANK() OVER (ORDER BY salary) as salary_percentile
FROM employees;

-- Complex INSERT ALL with multiple tables and conditions
INSERT ALL
    WHEN product_category = 'Electronics' AND sale_amount > 1000 THEN
        INTO high_value_electronics VALUES (sale_id, product_id, sale_amount)
        INTO premium_customers VALUES (customer_id, sale_date)
    WHEN product_category = 'Electronics' THEN
        INTO electronics_sales VALUES (sale_id, product_id, sale_amount)
    WHEN product_category = 'Clothing' AND season = 'Winter' THEN
        INTO winter_clothing_sales VALUES (sale_id, product_id, sale_amount)
    ELSE
        INTO other_sales VALUES (sale_id, product_id, product_category, sale_amount)
SELECT s.sale_id,
       s.customer_id,
       s.product_id,
       p.product_category,
       s.sale_amount,
       s.sale_date,
       CASE
           WHEN EXTRACT(MONTH FROM s.sale_date) IN (12, 1, 2) THEN 'Winter'
           WHEN EXTRACT(MONTH FROM s.sale_date) IN (3, 4, 5) THEN 'Spring'
           WHEN EXTRACT(MONTH FROM s.sale_date) IN (6, 7, 8) THEN 'Summer'
           ELSE 'Fall'
       END as season
FROM sales s
JOIN products p ON s.product_id = p.product_id;
