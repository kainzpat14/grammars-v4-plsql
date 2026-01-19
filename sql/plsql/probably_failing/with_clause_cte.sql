-- WITH clause (Common Table Expressions)
-- Tests CTE syntax including recursive queries

-- Basic WITH clause (non-recursive CTE)
WITH emp_dept AS (
    SELECT e.employee_id, e.first_name, e.last_name, d.department_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
)
SELECT * FROM emp_dept WHERE department_name = 'Sales';

-- Multiple CTEs in single query
WITH
dept_summary AS (
    SELECT department_id, COUNT(*) as emp_count, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
),
high_salary_depts AS (
    SELECT department_id
    FROM dept_summary
    WHERE avg_salary > 8000
)
SELECT e.employee_id, e.first_name, e.salary, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN high_salary_depts hsd ON e.department_id = hsd.department_id;

-- CTE with column aliases
WITH emp_summary (emp_id, full_name, annual_salary) AS (
    SELECT employee_id, first_name || ' ' || last_name, salary * 12
    FROM employees
)
SELECT * FROM emp_summary WHERE annual_salary > 50000;

-- Nested WITH clauses
WITH outer_cte AS (
    WITH inner_cte AS (
        SELECT department_id, COUNT(*) as emp_count
        FROM employees
        GROUP BY department_id
    )
    SELECT department_id, emp_count
    FROM inner_cte
    WHERE emp_count > 5
)
SELECT * FROM outer_cte;

-- CTE used multiple times in same query
WITH dept_totals AS (
    SELECT department_id, SUM(salary) as total_salary
    FROM employees
    GROUP BY department_id
)
SELECT dt1.department_id, dt1.total_salary,
       (dt1.total_salary / dt2.total_salary) * 100 as pct_of_max
FROM dept_totals dt1
CROSS JOIN (SELECT MAX(total_salary) as total_salary FROM dept_totals) dt2;

-- CTE in INSERT statement
WITH new_employees AS (
    SELECT employee_id, first_name, last_name, hire_date
    FROM employees
    WHERE hire_date >= TRUNC(SYSDATE, 'YYYY')
)
INSERT INTO employee_audit
SELECT * FROM new_employees;

-- CTE in UPDATE statement
WITH high_performers AS (
    SELECT employee_id
    FROM employees
    WHERE salary > (SELECT AVG(salary) * 1.5 FROM employees)
)
UPDATE employees e
SET e.bonus_pct = 0.15
WHERE e.employee_id IN (SELECT employee_id FROM high_performers);

-- CTE in DELETE statement
WITH inactive_employees AS (
    SELECT employee_id
    FROM employees
    WHERE last_login_date < ADD_MONTHS(SYSDATE, -6)
      AND status = 'INACTIVE'
)
DELETE FROM employees
WHERE employee_id IN (SELECT employee_id FROM inactive_employees);

-- CTE in MERGE statement
WITH source_data AS (
    SELECT employee_id, salary, department_id
    FROM employee_staging
)
MERGE INTO employees e
USING source_data s ON (e.employee_id = s.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = s.salary, e.department_id = s.department_id
WHEN NOT MATCHED THEN
    INSERT (employee_id, salary, department_id)
    VALUES (s.employee_id, s.salary, s.department_id);

-- Recursive CTE - Basic example
WITH emp_hierarchy (employee_id, manager_id, level_num) AS (
    -- Anchor member
    SELECT employee_id, manager_id, 1
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT e.employee_id, e.manager_id, eh.level_num + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM emp_hierarchy;

-- Recursive CTE with SEARCH clause (breadth-first)
WITH emp_tree (employee_id, manager_id, full_name, level_num) AS (
    SELECT employee_id, manager_id, first_name || ' ' || last_name, 1
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.manager_id, e.first_name || ' ' || e.last_name, et.level_num + 1
    FROM employees e
    JOIN emp_tree et ON e.manager_id = et.employee_id
)
SEARCH BREADTH FIRST BY employee_id SET order_seq
SELECT * FROM emp_tree ORDER BY order_seq;

-- Recursive CTE with SEARCH clause (depth-first)
WITH emp_tree (employee_id, manager_id, full_name) AS (
    SELECT employee_id, manager_id, first_name || ' ' || last_name
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.manager_id, e.first_name || ' ' || e.last_name
    FROM employees e
    JOIN emp_tree et ON e.manager_id = et.employee_id
)
SEARCH DEPTH FIRST BY employee_id SET order_seq
SELECT * FROM emp_tree ORDER BY order_seq;

-- Recursive CTE with CYCLE clause
WITH emp_hierarchy (employee_id, manager_id, level_num) AS (
    SELECT employee_id, manager_id, 1
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT e.employee_id, e.manager_id, eh.level_num + 1
    FROM employees e
    JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
)
CYCLE employee_id SET is_cycle TO 'Y' DEFAULT 'N'
SELECT * FROM emp_hierarchy;

-- Recursive CTE - generating sequence
WITH numbers (n) AS (
    SELECT 1 FROM DUAL
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 100
)
SELECT * FROM numbers;

-- Recursive CTE - date series
WITH date_series (dt) AS (
    SELECT TRUNC(SYSDATE, 'YYYY') as dt FROM DUAL
    UNION ALL
    SELECT dt + 1 FROM date_series WHERE dt < ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), 12) - 1
)
SELECT dt, TO_CHAR(dt, 'Day') as day_name FROM date_series;

-- Recursive CTE - bill of materials
WITH bom_explosion (component_id, parent_id, quantity, level_num, path) AS (
    -- Top-level components
    SELECT component_id, parent_component_id, 1, 1,
           CAST(component_name AS VARCHAR2(1000))
    FROM bom
    WHERE parent_component_id IS NULL

    UNION ALL

    -- Sub-components
    SELECT b.component_id, b.parent_component_id, b.quantity * be.quantity, be.level_num + 1,
           be.path || ' -> ' || b.component_name
    FROM bom b
    JOIN bom_explosion be ON b.parent_component_id = be.component_id
)
SELECT * FROM bom_explosion ORDER BY path;

-- WITH clause with aggregate and window functions
WITH ranked_employees AS (
    SELECT employee_id, first_name, salary, department_id,
           ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) as sal_rank
    FROM employees
)
SELECT * FROM ranked_employees WHERE sal_rank <= 3;

-- CTE with DISTINCT
WITH unique_jobs AS (
    SELECT DISTINCT job_id, job_title
    FROM jobs
)
SELECT * FROM unique_jobs ORDER BY job_title;

-- CTE with subquery
WITH dept_averages AS (
    SELECT department_id, AVG(salary) as avg_salary
    FROM employees
    WHERE department_id IN (
        SELECT department_id FROM departments WHERE location_id = 1700
    )
    GROUP BY department_id
)
SELECT * FROM dept_averages;

-- CTE with UNION in the definition
WITH all_names AS (
    SELECT employee_id as id, first_name || ' ' || last_name as name, 'Employee' as type
    FROM employees
    UNION
    SELECT department_id, department_name, 'Department'
    FROM departments
)
SELECT * FROM all_names ORDER BY type, name;

-- Multiple recursive CTEs
WITH RECURSIVE
managers AS (
    SELECT employee_id, manager_id, first_name, 1 as level_num
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.manager_id, e.first_name, m.level_num + 1
    FROM employees e
    JOIN managers m ON e.manager_id = m.employee_id
),
dept_hierarchy AS (
    SELECT department_id, parent_dept_id, department_name, 1 as level_num
    FROM departments
    WHERE parent_dept_id IS NULL
    UNION ALL
    SELECT d.department_id, d.parent_dept_id, d.department_name, dh.level_num + 1
    FROM departments d
    JOIN dept_hierarchy dh ON d.parent_dept_id = dh.department_id
)
SELECT m.first_name, m.level_num as mgr_level, dh.department_name, dh.level_num as dept_level
FROM managers m
JOIN employees e ON m.employee_id = e.employee_id
JOIN dept_hierarchy dh ON e.department_id = dh.department_id;

-- CTE with ORDER BY in the CTE definition
WITH sorted_employees AS (
    SELECT employee_id, first_name, salary
    FROM employees
    ORDER BY salary DESC
)
SELECT * FROM sorted_employees FETCH FIRST 10 ROWS ONLY;

-- CTE with FETCH FIRST in CTE definition
WITH top_earners AS (
    SELECT employee_id, first_name, salary
    FROM employees
    ORDER BY salary DESC
    FETCH FIRST 10 ROWS ONLY
)
SELECT * FROM top_earners;

-- WITH FUNCTION clause (18c+)
WITH
FUNCTION get_annual_salary(p_monthly_salary NUMBER) RETURN NUMBER IS
BEGIN
    RETURN p_monthly_salary * 12;
END;
SELECT employee_id, first_name, get_annual_salary(salary) as annual_salary
FROM employees;

-- WITH PROCEDURE clause (18c+)
WITH
PROCEDURE print_employee_info(p_emp_id NUMBER) IS
    v_name VARCHAR2(100);
BEGIN
    SELECT first_name || ' ' || last_name INTO v_name
    FROM employees WHERE employee_id = p_emp_id;
    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_name);
END;
SELECT employee_id FROM employees WHERE department_id = 10;

-- Combined WITH FUNCTION and CTE
WITH
FUNCTION calc_bonus(p_salary NUMBER, p_pct NUMBER) RETURN NUMBER IS
BEGIN
    RETURN p_salary * p_pct / 100;
END;
,
high_performers AS (
    SELECT employee_id, first_name, salary
    FROM employees
    WHERE salary > 10000
)
SELECT employee_id, first_name, salary, calc_bonus(salary, 10) as bonus
FROM high_performers;

-- CTE for pivot-like transformation
WITH monthly_sales AS (
    SELECT product_id, TO_CHAR(sale_date, 'MM') as month, SUM(amount) as total
    FROM sales
    GROUP BY product_id, TO_CHAR(sale_date, 'MM')
)
SELECT product_id,
       SUM(CASE WHEN month = '01' THEN total END) as jan,
       SUM(CASE WHEN month = '02' THEN total END) as feb,
       SUM(CASE WHEN month = '03' THEN total END) as mar
FROM monthly_sales
GROUP BY product_id;
