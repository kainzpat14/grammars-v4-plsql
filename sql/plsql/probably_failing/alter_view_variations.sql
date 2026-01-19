-- ALTER VIEW statement variations
-- Tests ALTER VIEW with various clauses and options

-- ALTER VIEW COMPILE
ALTER VIEW emp_view COMPILE;

-- ALTER VIEW ADD CONSTRAINT (with CHECK OPTION)
ALTER VIEW high_salary_employees
ADD CONSTRAINT high_sal_check CHECK (salary > 5000);

-- ALTER VIEW DROP CONSTRAINT
ALTER VIEW high_salary_employees
DROP CONSTRAINT high_sal_check;

-- ALTER VIEW MODIFY CONSTRAINT
ALTER VIEW dept_10_employees
MODIFY CONSTRAINT dept_10_check DISABLE;

-- ALTER VIEW MODIFY CONSTRAINT ENABLE
ALTER VIEW dept_10_employees
MODIFY CONSTRAINT dept_10_check ENABLE;

-- ALTER VIEW with READ ONLY (using ALTER)
-- Note: This is typically done via CREATE OR REPLACE
CREATE OR REPLACE VIEW emp_view AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WITH READ ONLY;

-- ALTER VIEW with CHECK OPTION (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW active_employees AS
SELECT employee_id, first_name, last_name, status
FROM employees
WHERE status = 'ACTIVE'
WITH CHECK OPTION;

-- ALTER VIEW remove READ ONLY (by recreating without it)
CREATE OR REPLACE VIEW emp_view AS
SELECT employee_id, first_name, last_name, salary
FROM employees;

-- Recompile view with dependencies
ALTER VIEW emp_dept_view COMPILE;

-- ALTER VIEW to add columns (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW emp_view AS
SELECT employee_id, first_name, last_name, salary, department_id, hire_date
FROM employees;

-- ALTER VIEW to change query logic (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW active_employees AS
SELECT employee_id, first_name, last_name, status, hire_date
FROM employees
WHERE status = 'ACTIVE' AND hire_date >= DATE '2020-01-01';

-- ALTER VIEW to add WHERE clause (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW emp_view AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > 3000;

-- ALTER VIEW to add JOIN (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW emp_view AS
SELECT e.employee_id, e.first_name, e.last_name, e.salary, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- ALTER VIEW to add aggregation (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW dept_summary AS
SELECT department_id,
       COUNT(*) as emp_count,
       AVG(salary) as avg_salary,
       SUM(salary) as total_salary
FROM employees
GROUP BY department_id;

-- ALTER VIEW to add ORDER BY (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW employees_sorted AS
SELECT employee_id, first_name, last_name, salary
FROM employees
ORDER BY salary DESC, last_name;

-- ALTER VIEW to add analytic functions (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW employee_rankings AS
SELECT employee_id, first_name, salary,
       RANK() OVER (ORDER BY salary DESC) as salary_rank,
       DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_rank
FROM employees;

-- ALTER VIEW to change from simple to complex (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW emp_analysis AS
WITH dept_stats AS (
    SELECT department_id, AVG(salary) as dept_avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.employee_id, e.first_name, e.salary,
       ds.dept_avg_salary,
       e.salary - ds.dept_avg_salary as diff_from_avg
FROM employees e
JOIN dept_stats ds ON e.department_id = ds.department_id;

-- ALTER VIEW to add CHECK OPTION with constraint name (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW dept_20_employees AS
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id = 20
WITH CHECK OPTION CONSTRAINT dept_20_ck;

-- ALTER VIEW to make it READ ONLY (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW readonly_emp_data AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WITH READ ONLY;

-- ALTER VIEW COMPILE with debug info
ALTER VIEW emp_view COMPILE DEBUG;

-- ALTER VIEW COMPILE without debug info
ALTER VIEW emp_view COMPILE;

-- Force recompile of invalid view
ALTER VIEW invalid_view COMPILE;

-- ALTER VIEW to change column aliases (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW emp_summary (id, name, monthly_sal, annual_sal) AS
SELECT employee_id, first_name || ' ' || last_name, salary, salary * 12
FROM employees;

-- ALTER VIEW to add DISTINCT (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW unique_departments AS
SELECT DISTINCT department_id, department_name
FROM departments;

-- ALTER VIEW to add UNION (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW all_people AS
SELECT employee_id as person_id, first_name || ' ' || last_name as name, 'EMPLOYEE' as type
FROM employees
UNION ALL
SELECT customer_id, customer_name, 'CUSTOMER'
FROM customers;

-- ALTER VIEW to add subquery (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW high_earners AS
SELECT employee_id, first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- ALTER VIEW to add CASE expression (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW employee_grades AS
SELECT employee_id, first_name, salary,
       CASE
           WHEN salary > 10000 THEN 'A'
           WHEN salary > 7000 THEN 'B'
           WHEN salary > 5000 THEN 'C'
           ELSE 'D'
       END as grade
FROM employees;

-- ALTER VIEW to add PIVOT (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW sales_by_quarter AS
SELECT *
FROM (
    SELECT product_id, TO_CHAR(sale_date, 'Q') as quarter, sale_amount
    FROM sales
)
PIVOT (
    SUM(sale_amount)
    FOR quarter IN ('1' AS q1, '2' AS q2, '3' AS q3, '4' AS q4)
);

-- ALTER VIEW to add hierarchical query (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT employee_id, first_name, manager_id, LEVEL as level,
       SYS_CONNECT_BY_PATH(first_name, '/') as path
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- ALTER VIEW to add window functions (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW salary_analysis AS
SELECT employee_id, department_id, salary,
       AVG(salary) OVER (PARTITION BY department_id) as dept_avg,
       MIN(salary) OVER (PARTITION BY department_id) as dept_min,
       MAX(salary) OVER (PARTITION BY department_id) as dept_max,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_rank
FROM employees;

-- ALTER VIEW to add LISTAGG (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW dept_emp_names AS
SELECT department_id,
       LISTAGG(first_name, ', ') WITHIN GROUP (ORDER BY first_name) as employee_names
FROM employees
GROUP BY department_id;

-- ALTER VIEW to simplify complex view (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW simple_emp_view AS
SELECT employee_id, first_name, last_name
FROM employees;

-- ALTER VIEW to add LATERAL join (using CREATE OR REPLACE) (12c+)
CREATE OR REPLACE VIEW emp_with_top_sale AS
SELECT e.employee_id, e.first_name, s.max_sale
FROM employees e,
     LATERAL (
         SELECT MAX(sale_amount) as max_sale
         FROM sales
         WHERE salesperson_id = e.employee_id
     ) s;

-- ALTER VIEW to add JSON functions (using CREATE OR REPLACE) (12c+)
CREATE OR REPLACE VIEW employees_as_json AS
SELECT department_id,
       JSON_OBJECT(
           'department' VALUE department_id,
           'employees' VALUE JSON_ARRAYAGG(
               JSON_OBJECT(
                   'id' VALUE employee_id,
                   'name' VALUE first_name || ' ' || last_name
               )
           )
       ) as dept_json
FROM employees
GROUP BY department_id;

-- ALTER VIEW to change constraint (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW verified_employees AS
SELECT employee_id, first_name, email
FROM employees
WHERE email IS NOT NULL
WITH CHECK OPTION CONSTRAINT verified_emp_ck;

-- ALTER VIEW to add multiple constraints (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW active_high_salary AS
SELECT employee_id, first_name, salary, status
FROM employees
WHERE status = 'ACTIVE' AND salary > 5000
WITH CHECK OPTION;

-- Modify view to be editable (remove READ ONLY)
CREATE OR REPLACE VIEW editable_emp_view AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE department_id = 10;

-- Modify view to be non-editable (add READ ONLY)
CREATE OR REPLACE VIEW noneditable_emp_view AS
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE department_id = 10
WITH READ ONLY;

-- ALTER VIEW to add FETCH FIRST (using CREATE OR REPLACE) (12c+)
CREATE OR REPLACE VIEW top_earners AS
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;

-- ALTER VIEW to add OFFSET (using CREATE OR REPLACE) (12c+)
CREATE OR REPLACE VIEW employees_page_3 AS
SELECT employee_id, first_name, salary
FROM employees
ORDER BY employee_id
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;

-- ALTER VIEW to add ROW LIMITING (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW top_10_percent AS
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 10 PERCENT ROWS ONLY;

-- ALTER VIEW to add WITH TIES (using CREATE OR REPLACE)
CREATE OR REPLACE VIEW top_salaries_with_ties AS
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 5 ROWS WITH TIES;

-- ALTER VIEW to change from updatable to non-updatable
CREATE OR REPLACE VIEW complex_emp_view AS
SELECT e.employee_id, e.first_name, COUNT(pa.project_id) as project_count
FROM employees e
LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
GROUP BY e.employee_id, e.first_name;

-- ALTER VIEW to remove aggregation (make updatable again)
CREATE OR REPLACE VIEW simple_emp_for_update AS
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees;

-- ALTER VIEW with BEQUEATH CURRENT_USER (12c+)
CREATE OR REPLACE VIEW secure_emp_view
BEQUEATH CURRENT_USER
AS
SELECT employee_id, first_name, last_name
FROM employees;

-- ALTER VIEW with BEQUEATH DEFINER (12c+)
CREATE OR REPLACE VIEW definer_emp_view
BEQUEATH DEFINER
AS
SELECT employee_id, first_name, last_name, salary
FROM employees;

-- ALTER VIEW to add DEFAULT COLLATION (12c+)
CREATE OR REPLACE VIEW collated_view
DEFAULT COLLATION BINARY_CI
AS
SELECT employee_id, first_name, last_name
FROM employees;

-- ALTER VIEW to add EDITIONING view (11g R2+)
CREATE OR REPLACE EDITIONING VIEW edit_emp_view AS
SELECT employee_id, first_name, last_name, salary
FROM employees;

-- ALTER VIEW to add NONEDITIONABLE view (11g R2+)
CREATE OR REPLACE NONEDITIONABLE VIEW nonedit_emp_view AS
SELECT employee_id, first_name, last_name
FROM employees;

-- Recompile view and dependent objects
ALTER VIEW emp_dept_view COMPILE;

-- ALTER VIEW to add inline view
CREATE OR REPLACE VIEW emp_with_stats AS
SELECT e.*, dept_stats.avg_salary as dept_avg
FROM employees e,
     (SELECT department_id, AVG(salary) as avg_salary
      FROM employees
      GROUP BY department_id) dept_stats
WHERE e.department_id = dept_stats.department_id;

-- ALTER VIEW to add multiple JOINs
CREATE OR REPLACE VIEW comprehensive_emp_view AS
SELECT e.employee_id, e.first_name, e.last_name,
       d.department_name,
       j.job_title,
       l.city, l.country
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id
JOIN locations l ON d.location_id = l.location_id;

-- ALTER VIEW to change CHECK OPTION level
CREATE OR REPLACE VIEW cascaded_check_view AS
SELECT employee_id, first_name, department_id
FROM employees
WHERE department_id IN (10, 20)
WITH CASCADED CHECK OPTION;

-- ALTER VIEW to use LOCAL CHECK OPTION
CREATE OR REPLACE VIEW local_check_view AS
SELECT employee_id, first_name, department_id
FROM employees
WHERE department_id IN (10, 20)
WITH LOCAL CHECK OPTION;

-- ALTER VIEW to add XMLTABLE (11g+)
CREATE OR REPLACE VIEW parsed_xml_view AS
SELECT xt.employee_id, xt.employee_name
FROM xml_employees xe,
     XMLTABLE('/employees/employee'
         PASSING xe.xml_data
         COLUMNS
             employee_id NUMBER PATH '@id',
             employee_name VARCHAR2(100) PATH 'name'
     ) xt;

-- ALTER VIEW to add JSON_TABLE (12c+)
CREATE OR REPLACE VIEW parsed_json_view AS
SELECT jt.product_id, jt.product_name, jt.price
FROM json_products jp,
     JSON_TABLE(jp.product_data, '$.products[*]'
         COLUMNS (
             product_id NUMBER PATH '$.id',
             product_name VARCHAR2(100) PATH '$.name',
             price NUMBER PATH '$.price'
         )
     ) jt;

-- ALTER VIEW to add CROSS APPLY pattern (12c+)
CREATE OR REPLACE VIEW emp_recent_projects AS
SELECT e.employee_id, e.first_name, recent.project_name, recent.start_date
FROM employees e
CROSS APPLY (
    SELECT project_name, start_date
    FROM projects p
    JOIN project_assignments pa ON p.project_id = pa.project_id
    WHERE pa.employee_id = e.employee_id
    ORDER BY start_date DESC
    FETCH FIRST 1 ROW ONLY
) recent;

-- ALTER VIEW to add OUTER APPLY pattern (12c+)
CREATE OR REPLACE VIEW emp_with_latest_project AS
SELECT e.employee_id, e.first_name, latest.project_name
FROM employees e
OUTER APPLY (
    SELECT project_name
    FROM projects p
    JOIN project_assignments pa ON p.project_id = pa.project_id
    WHERE pa.employee_id = e.employee_id
    ORDER BY pa.assignment_date DESC
    FETCH FIRST 1 ROW ONLY
) latest;

-- ALTER VIEW to add PARTITION OUTER JOIN
CREATE OR REPLACE VIEW sales_with_all_dates AS
SELECT s.product_id, d.date_key, s.sale_amount
FROM sales s
PARTITION BY (s.product_id)
RIGHT OUTER JOIN date_dimension d
ON s.sale_date = d.date_key;

-- ALTER VIEW to optimize with hints
CREATE OR REPLACE VIEW optimized_emp_view AS
SELECT /*+ FULL(e) PARALLEL(e, 4) */ employee_id, first_name, salary
FROM employees e
WHERE salary > 5000;

-- ALTER VIEW to add materialized view query
CREATE OR REPLACE VIEW mv_compatible_view AS
SELECT department_id, COUNT(*) as emp_count, SUM(salary) as total_salary
FROM employees
GROUP BY department_id;

-- Recompile with PL/SQL optimization level
ALTER VIEW complex_view_with_plsql COMPILE PLSQL_OPTIMIZE_LEVEL = 2;

-- Force view to be valid
ALTER VIEW potentially_invalid_view COMPILE;
