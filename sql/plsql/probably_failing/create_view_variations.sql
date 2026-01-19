-- CREATE VIEW statement variations
-- Tests CREATE VIEW with various options and clauses

-- Basic CREATE VIEW
CREATE VIEW emp_view AS
SELECT employee_id, first_name, last_name, salary
FROM employees;

-- CREATE VIEW with WHERE clause
CREATE VIEW active_employees AS
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE status = 'ACTIVE';

-- CREATE VIEW with JOIN
CREATE VIEW emp_dept_view AS
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- CREATE VIEW with multiple JOINs
CREATE VIEW emp_full_details AS
SELECT e.employee_id, e.first_name, e.last_name,
       d.department_name, l.city, l.state_province
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN locations l ON d.location_id = l.location_id;

-- CREATE VIEW with LEFT JOIN
CREATE VIEW all_employees_with_dept AS
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

-- CREATE VIEW with aggregation
CREATE VIEW dept_salary_summary AS
SELECT department_id,
       COUNT(*) as employee_count,
       AVG(salary) as avg_salary,
       SUM(salary) as total_salary,
       MIN(salary) as min_salary,
       MAX(salary) as max_salary
FROM employees
GROUP BY department_id;

-- CREATE VIEW with HAVING clause
CREATE VIEW high_paying_depts AS
SELECT department_id, AVG(salary) as avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 8000;

-- CREATE VIEW with ORDER BY
CREATE VIEW employees_by_salary AS
SELECT employee_id, first_name, last_name, salary
FROM employees
ORDER BY salary DESC;

-- CREATE VIEW with subquery
CREATE VIEW above_avg_salary AS
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- CREATE VIEW with correlated subquery
CREATE VIEW emp_vs_dept_avg AS
SELECT e.employee_id, e.first_name, e.salary,
       (SELECT AVG(salary) FROM employees WHERE department_id = e.department_id) as dept_avg
FROM employees e;

-- CREATE VIEW with UNION
CREATE VIEW all_contacts AS
SELECT employee_id as contact_id, first_name || ' ' || last_name as name, email, 'EMPLOYEE' as type
FROM employees
UNION ALL
SELECT customer_id, customer_name, email, 'CUSTOMER'
FROM customers;

-- CREATE VIEW with INTERSECT
CREATE VIEW active_project_employees AS
SELECT employee_id, first_name, last_name
FROM employees
WHERE status = 'ACTIVE'
INTERSECT
SELECT employee_id, first_name, last_name
FROM project_assignments
WHERE project_status = 'ACTIVE';

-- CREATE VIEW with MINUS
CREATE VIEW employees_without_projects AS
SELECT employee_id, first_name, last_name
FROM employees
MINUS
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
JOIN project_assignments pa ON e.employee_id = pa.employee_id;

-- CREATE VIEW with CTE (WITH clause)
CREATE VIEW dept_top_earners AS
WITH ranked_employees AS (
    SELECT employee_id, first_name, last_name, department_id, salary,
           RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as rank
    FROM employees
)
SELECT employee_id, first_name, last_name, department_id, salary
FROM ranked_employees
WHERE rank <= 3;

-- CREATE VIEW with analytic functions
CREATE VIEW employee_rankings AS
SELECT employee_id, first_name, last_name, department_id, salary,
       RANK() OVER (ORDER BY salary DESC) as overall_rank,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_rank,
       ROW_NUMBER() OVER (ORDER BY hire_date) as hire_sequence
FROM employees;

-- CREATE VIEW with window functions
CREATE VIEW employee_salary_analysis AS
SELECT employee_id, first_name, salary,
       AVG(salary) OVER (PARTITION BY department_id) as dept_avg,
       salary - AVG(salary) OVER (PARTITION BY department_id) as diff_from_avg,
       PERCENT_RANK() OVER (ORDER BY salary) as salary_percentile
FROM employees;

-- CREATE VIEW with CASE expression
CREATE VIEW employee_salary_grades AS
SELECT employee_id, first_name, last_name, salary,
       CASE
           WHEN salary > 10000 THEN 'High'
           WHEN salary > 5000 THEN 'Medium'
           ELSE 'Low'
       END as salary_grade
FROM employees;

-- CREATE VIEW with PIVOT
CREATE VIEW quarterly_sales_pivot AS
SELECT *
FROM (
    SELECT product_id, TO_CHAR(sale_date, 'Q') as quarter, sale_amount
    FROM sales
    WHERE EXTRACT(YEAR FROM sale_date) = 2024
)
PIVOT (
    SUM(sale_amount)
    FOR quarter IN ('1' AS q1, '2' AS q2, '3' AS q3, '4' AS q4)
);

-- CREATE VIEW with UNPIVOT
CREATE VIEW quarterly_sales_unpivot AS
SELECT product_id, quarter, amount
FROM quarterly_sales
UNPIVOT (
    amount FOR quarter IN (q1, q2, q3, q4)
);

-- CREATE VIEW with hierarchical query
CREATE VIEW org_hierarchy AS
SELECT employee_id, first_name, last_name, manager_id, LEVEL as org_level,
       SYS_CONNECT_BY_PATH(first_name || ' ' || last_name, ' > ') as path
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- CREATE OR REPLACE VIEW
CREATE OR REPLACE VIEW emp_view AS
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees;

-- CREATE VIEW with column aliases in definition
CREATE VIEW emp_summary (emp_id, emp_name, annual_salary) AS
SELECT employee_id, first_name || ' ' || last_name, salary * 12
FROM employees;

-- CREATE VIEW with explicit column list
CREATE VIEW dept_info (dept_id, dept_name, mgr_id) AS
SELECT department_id, department_name, manager_id
FROM departments;

-- CREATE VIEW with WITH READ ONLY
CREATE VIEW readonly_employees AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WITH READ ONLY;

-- CREATE VIEW with WITH CHECK OPTION
CREATE VIEW high_salary_employees AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > 5000
WITH CHECK OPTION;

-- CREATE VIEW with WITH CHECK OPTION and constraint name
CREATE VIEW dept_10_employees AS
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id = 10
WITH CHECK OPTION CONSTRAINT dept_10_check;

-- CREATE VIEW with both READ ONLY and column aliases
CREATE VIEW emp_readonly (id, name, dept) AS
SELECT employee_id, first_name || ' ' || last_name, department_id
FROM employees
WITH READ ONLY;

-- CREATE FORCE VIEW (create even if base table doesn't exist)
CREATE FORCE VIEW future_table_view AS
SELECT column1, column2, column3
FROM non_existent_table;

-- CREATE NO FORCE VIEW (default - requires base table to exist)
CREATE NO FORCE VIEW emp_noforce_view AS
SELECT employee_id, first_name
FROM employees;

-- CREATE VIEW with inline view/derived table
CREATE VIEW complex_aggregation AS
SELECT dept_id, avg_salary, emp_count
FROM (
    SELECT department_id as dept_id,
           AVG(salary) as avg_salary,
           COUNT(*) as emp_count
    FROM employees
    GROUP BY department_id
)
WHERE avg_salary > 5000;

-- CREATE VIEW with DISTINCT
CREATE VIEW distinct_job_titles AS
SELECT DISTINCT job_id, job_title
FROM jobs;

-- CREATE VIEW with string functions
CREATE VIEW formatted_employees AS
SELECT employee_id,
       UPPER(first_name) as first_name_upper,
       LOWER(last_name) as last_name_lower,
       INITCAP(first_name || ' ' || last_name) as full_name
FROM employees;

-- CREATE VIEW with date functions
CREATE VIEW employee_tenure AS
SELECT employee_id, first_name, last_name, hire_date,
       TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) as years_employed,
       TRUNC(SYSDATE) - hire_date as days_employed
FROM employees;

-- CREATE VIEW with numeric functions
CREATE VIEW rounded_salaries AS
SELECT employee_id, first_name,
       salary as original_salary,
       ROUND(salary, -2) as rounded_salary,
       FLOOR(salary) as floor_salary,
       CEIL(salary) as ceil_salary
FROM employees;

-- CREATE VIEW with NVL/COALESCE
CREATE VIEW employees_with_defaults AS
SELECT employee_id, first_name, last_name,
       NVL(commission_pct, 0) as commission_pct,
       COALESCE(phone_number, mobile_number, 'N/A') as contact_number
FROM employees;

-- CREATE VIEW with DECODE
CREATE VIEW department_categories AS
SELECT department_id, department_name,
       DECODE(department_id,
              10, 'Administration',
              20, 'Marketing',
              30, 'Purchasing',
              'Other') as category
FROM departments;

-- CREATE VIEW with complex WHERE clause
CREATE VIEW filtered_employees AS
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees
WHERE (department_id IN (10, 20) AND salary > 5000)
   OR (department_id IN (30, 40) AND hire_date > DATE '2020-01-01');

-- CREATE VIEW with BETWEEN
CREATE VIEW mid_salary_employees AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary BETWEEN 5000 AND 10000;

-- CREATE VIEW with LIKE
CREATE VIEW it_employees AS
SELECT employee_id, first_name, last_name, job_id
FROM employees
WHERE job_id LIKE 'IT_%';

-- CREATE VIEW with EXISTS
CREATE VIEW employees_with_history AS
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- CREATE VIEW with NOT EXISTS
CREATE VIEW employees_no_dependents AS
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM dependents d
    WHERE d.employee_id = e.employee_id
);

-- CREATE VIEW with ANY
CREATE VIEW above_any_dept_avg AS
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > ANY (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department_id
);

-- CREATE VIEW with ALL
CREATE VIEW highest_paid AS
SELECT employee_id, first_name, salary
FROM employees
WHERE salary >= ALL (
    SELECT salary FROM employees
);

-- CREATE VIEW with ROWNUM
CREATE VIEW top_10_earners AS
SELECT employee_id, first_name, salary
FROM (
    SELECT employee_id, first_name, salary
    FROM employees
    ORDER BY salary DESC
)
WHERE ROWNUM <= 10;

-- CREATE VIEW with FETCH FIRST (12c+)
CREATE VIEW recent_hires AS
SELECT employee_id, first_name, hire_date
FROM employees
ORDER BY hire_date DESC
FETCH FIRST 20 ROWS ONLY;

-- CREATE VIEW with OFFSET and FETCH (12c+)
CREATE VIEW employees_page_2 AS
SELECT employee_id, first_name, last_name
FROM employees
ORDER BY employee_id
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

-- CREATE VIEW with FOR UPDATE clause
CREATE VIEW employees_for_update AS
SELECT employee_id, first_name, salary
FROM employees
WHERE department_id = 10
FOR UPDATE;

-- CREATE VIEW with SKIP LOCKED (11g+)
CREATE VIEW available_tasks AS
SELECT task_id, task_name, status
FROM tasks
WHERE status = 'PENDING'
FOR UPDATE SKIP LOCKED;

-- CREATE VIEW with complex calculation
CREATE VIEW employee_compensation AS
SELECT employee_id, first_name, last_name,
       salary as base_salary,
       NVL(commission_pct, 0) * salary as commission,
       salary + (NVL(commission_pct, 0) * salary) as total_compensation,
       (salary + (NVL(commission_pct, 0) * salary)) * 12 as annual_compensation
FROM employees;

-- CREATE VIEW with EXTRACT
CREATE VIEW employees_by_hire_year AS
SELECT employee_id, first_name, last_name, hire_date,
       EXTRACT(YEAR FROM hire_date) as hire_year,
       EXTRACT(MONTH FROM hire_date) as hire_month
FROM employees;

-- CREATE VIEW with TO_CHAR formatting
CREATE VIEW formatted_dates AS
SELECT employee_id, first_name,
       TO_CHAR(hire_date, 'YYYY-MM-DD') as hire_date_iso,
       TO_CHAR(hire_date, 'Month DD, YYYY') as hire_date_formatted,
       TO_CHAR(salary, '$999,999.99') as formatted_salary
FROM employees;

-- CREATE VIEW with interval arithmetic
CREATE VIEW contract_extensions AS
SELECT contract_id, start_date, end_date,
       end_date - start_date as duration_days,
       end_date + INTERVAL '1' YEAR as extended_end_date
FROM contracts;

-- CREATE VIEW with LISTAGG (11g R2+)
CREATE VIEW dept_employee_list AS
SELECT department_id,
       LISTAGG(first_name || ' ' || last_name, ', ')
           WITHIN GROUP (ORDER BY last_name) as employee_list
FROM employees
GROUP BY department_id;

-- CREATE VIEW with LAG/LEAD
CREATE VIEW salary_changes AS
SELECT employee_id, review_date, salary,
       LAG(salary) OVER (PARTITION BY employee_id ORDER BY review_date) as previous_salary,
       LEAD(salary) OVER (PARTITION BY employee_id ORDER BY review_date) as next_salary
FROM salary_history;

-- CREATE VIEW with FIRST_VALUE/LAST_VALUE
CREATE VIEW dept_salary_bounds AS
SELECT employee_id, department_id, salary,
       FIRST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY salary) as min_dept_salary,
       LAST_VALUE(salary) OVER (PARTITION BY department_id ORDER BY salary
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as max_dept_salary
FROM employees;

-- CREATE VIEW with XMLAGG
CREATE VIEW dept_employees_xml AS
SELECT department_id,
       XMLAGG(XMLELEMENT("employee", first_name || ' ' || last_name)) as employees_xml
FROM employees
GROUP BY department_id;

-- CREATE VIEW with JSON functions (12c+)
CREATE VIEW employees_json AS
SELECT department_id,
       JSON_ARRAYAGG(
           JSON_OBJECT(
               'id' VALUE employee_id,
               'name' VALUE first_name || ' ' || last_name,
               'salary' VALUE salary
           )
       ) as employees_json
FROM employees
GROUP BY department_id;

-- CREATE VIEW with JSON_TABLE (12c+)
CREATE VIEW parsed_json_products AS
SELECT jt.*
FROM products_json p,
     JSON_TABLE(p.product_data, '$'
         COLUMNS (
             product_name VARCHAR2(100) PATH '$.name',
             price NUMBER PATH '$.price',
             active VARCHAR2(10) PATH '$.active'
         )
     ) jt;

-- CREATE VIEW with LATERAL (12c+)
CREATE VIEW employee_top_sale AS
SELECT e.employee_id, e.first_name, s.sale_amount, s.sale_date
FROM employees e,
     LATERAL (
         SELECT sale_amount, sale_date
         FROM sales
         WHERE salesperson_id = e.employee_id
         ORDER BY sale_amount DESC
         FETCH FIRST 1 ROW ONLY
     ) s;

-- CREATE VIEW with multiple LATERAL joins
CREATE VIEW employee_stats AS
SELECT e.employee_id, e.first_name,
       ts.total_sales,
       tp.project_count
FROM employees e,
     LATERAL (
         SELECT SUM(sale_amount) as total_sales
         FROM sales
         WHERE salesperson_id = e.employee_id
     ) ts,
     LATERAL (
         SELECT COUNT(*) as project_count
         FROM project_assignments
         WHERE employee_id = e.employee_id
     ) tp;

-- CREATE VIEW with XMLTABLE
CREATE VIEW parsed_xml_data AS
SELECT xt.*
FROM xml_documents xd,
     XMLTABLE('/root/item'
         PASSING xd.xml_data
         COLUMNS
             item_id NUMBER PATH '@id',
             item_name VARCHAR2(100) PATH 'name',
             item_value NUMBER PATH 'value'
     ) xt;

-- CREATE VIEW with inline constraints (view definition)
CREATE VIEW constrained_view AS
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > 0 AND employee_id IS NOT NULL;

-- CREATE VIEW referencing another view
CREATE VIEW summary_of_summary AS
SELECT dept_id, avg_salary
FROM (
    SELECT department_id as dept_id, avg_salary
    FROM dept_salary_summary
)
WHERE avg_salary > 7000;

-- CREATE VIEW with CONNECT_BY_ROOT
CREATE VIEW org_with_ceo AS
SELECT employee_id, first_name,
       CONNECT_BY_ROOT employee_id as ceo_id,
       LEVEL as org_level
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- CREATE VIEW with NOCYCLE (11g+)
CREATE VIEW safe_hierarchy AS
SELECT employee_id, first_name, manager_id, LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;

-- CREATE VIEW with bitmask/bitwise operations (if supported)
CREATE VIEW permission_view AS
SELECT user_id, username,
       BITAND(permissions, 1) as can_read,
       BITAND(permissions, 2) as can_write,
       BITAND(permissions, 4) as can_delete
FROM user_permissions;
