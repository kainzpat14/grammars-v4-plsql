-- SELECT statement basic clauses and variations
-- Tests fundamental SELECT syntax that should be supported

-- Basic SELECT
SELECT * FROM employees;

-- SELECT with specific columns
SELECT employee_id, first_name, last_name FROM employees;

-- SELECT with DISTINCT
SELECT DISTINCT department_id FROM employees;

-- SELECT with UNIQUE (Oracle-specific, same as DISTINCT)
SELECT UNIQUE job_id FROM employees;

-- SELECT with ALL (explicit, default behavior)
SELECT ALL department_id FROM employees;

-- SELECT with column aliases using AS
SELECT employee_id AS emp_id, first_name AS fname FROM employees;

-- SELECT with column aliases without AS
SELECT employee_id emp_id, first_name fname FROM employees;

-- SELECT with quoted column aliases
SELECT employee_id "Employee ID", first_name "First Name" FROM employees;

-- SELECT with table alias
SELECT e.employee_id, e.first_name FROM employees e;

-- SELECT with schema qualification
SELECT hr.employees.employee_id FROM hr.employees;

-- SELECT with WHERE clause
SELECT * FROM employees WHERE department_id = 10;

-- SELECT with multiple conditions
SELECT * FROM employees WHERE department_id = 10 AND salary > 5000;

-- SELECT with OR condition
SELECT * FROM employees WHERE department_id = 10 OR department_id = 20;

-- SELECT with IN clause
SELECT * FROM employees WHERE department_id IN (10, 20, 30);

-- SELECT with BETWEEN
SELECT * FROM employees WHERE salary BETWEEN 3000 AND 8000;

-- SELECT with LIKE
SELECT * FROM employees WHERE last_name LIKE 'S%';

-- SELECT with IS NULL
SELECT * FROM employees WHERE commission_pct IS NULL;

-- SELECT with IS NOT NULL
SELECT * FROM employees WHERE manager_id IS NOT NULL;

-- SELECT with ORDER BY
SELECT * FROM employees ORDER BY last_name;

-- SELECT with ORDER BY DESC
SELECT * FROM employees ORDER BY salary DESC;

-- SELECT with ORDER BY multiple columns
SELECT * FROM employees ORDER BY department_id, last_name;

-- SELECT with ORDER BY and NULL handling
SELECT * FROM employees ORDER BY commission_pct NULLS FIRST;
SELECT * FROM employees ORDER BY commission_pct NULLS LAST;

-- SELECT with GROUP BY
SELECT department_id, COUNT(*) FROM employees GROUP BY department_id;

-- SELECT with GROUP BY and aggregate functions
SELECT department_id, AVG(salary), MAX(salary), MIN(salary)
FROM employees
GROUP BY department_id;

-- SELECT with HAVING clause
SELECT department_id, AVG(salary)
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 5000;

-- SELECT with GROUP BY multiple columns
SELECT department_id, job_id, COUNT(*)
FROM employees
GROUP BY department_id, job_id;

-- SELECT with expression in SELECT list
SELECT first_name, salary, salary * 12 AS annual_salary FROM employees;

-- SELECT with CASE expression
SELECT
    first_name,
    salary,
    CASE
        WHEN salary > 10000 THEN 'High'
        WHEN salary > 5000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_grade
FROM employees;

-- SELECT with simple CASE
SELECT
    first_name,
    department_id,
    CASE department_id
        WHEN 10 THEN 'Administration'
        WHEN 20 THEN 'Marketing'
        WHEN 30 THEN 'Purchasing'
        ELSE 'Other'
    END AS dept_name
FROM employees;

-- SELECT with concatenation
SELECT first_name || ' ' || last_name AS full_name FROM employees;

-- SELECT with NULL handling functions
SELECT first_name, NVL(commission_pct, 0) AS commission FROM employees;
SELECT first_name, NVL2(commission_pct, 'Has Commission', 'No Commission') FROM employees;
SELECT first_name, COALESCE(commission_pct, manager_id, 0) FROM employees;

-- SELECT with DECODE (Oracle-specific)
SELECT
    first_name,
    DECODE(department_id, 10, 'Admin', 20, 'Marketing', 'Other') AS dept
FROM employees;

-- SELECT with subquery in WHERE
SELECT * FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales');

-- SELECT with subquery using IN
SELECT * FROM employees WHERE department_id IN (SELECT department_id FROM departments WHERE location_id = 1700);

-- SELECT with scalar subquery in SELECT list
SELECT first_name, (SELECT department_name FROM departments d WHERE d.department_id = e.department_id) AS dept_name
FROM employees e;

-- SELECT with EXISTS
SELECT * FROM departments d WHERE EXISTS (SELECT 1 FROM employees e WHERE e.department_id = d.department_id);

-- SELECT with NOT EXISTS
SELECT * FROM departments d WHERE NOT EXISTS (SELECT 1 FROM employees e WHERE e.department_id = d.department_id);

-- SELECT with ALL operator
SELECT * FROM employees WHERE salary > ALL (SELECT salary FROM employees WHERE department_id = 10);

-- SELECT with ANY operator
SELECT * FROM employees WHERE salary > ANY (SELECT salary FROM employees WHERE department_id = 10);

-- SELECT with UNION
SELECT employee_id, first_name FROM employees WHERE department_id = 10
UNION
SELECT employee_id, first_name FROM employees WHERE department_id = 20;

-- SELECT with UNION ALL
SELECT employee_id FROM employees WHERE department_id = 10
UNION ALL
SELECT employee_id FROM employees WHERE department_id = 20;

-- SELECT with INTERSECT
SELECT employee_id FROM employees WHERE department_id = 10
INTERSECT
SELECT employee_id FROM employees WHERE salary > 5000;

-- SELECT with MINUS
SELECT employee_id FROM employees
MINUS
SELECT employee_id FROM employees WHERE department_id = 10;

-- SELECT with inline view
SELECT * FROM (SELECT employee_id, first_name, salary FROM employees WHERE department_id = 10) e WHERE e.salary > 5000;

-- SELECT with multiple inline views
SELECT e.first_name, d.department_name
FROM (SELECT employee_id, first_name, department_id FROM employees) e,
     (SELECT department_id, department_name FROM departments) d
WHERE e.department_id = d.department_id;

-- SELECT with COUNT(*)
SELECT COUNT(*) FROM employees;

-- SELECT with COUNT(column)
SELECT COUNT(commission_pct) FROM employees;

-- SELECT with COUNT(DISTINCT)
SELECT COUNT(DISTINCT department_id) FROM employees;

-- SELECT with aggregate functions
SELECT
    SUM(salary) AS total_salary,
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary,
    MIN(salary) AS min_salary
FROM employees;
