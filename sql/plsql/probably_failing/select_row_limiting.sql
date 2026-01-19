-- SELECT with row limiting clause (12c+)
-- Tests FETCH FIRST and OFFSET syntax

-- Basic FETCH FIRST
SELECT * FROM employees
ORDER BY employee_id
FETCH FIRST 10 ROWS ONLY;

-- FETCH NEXT (synonym for FIRST)
SELECT * FROM employees
ORDER BY employee_id
FETCH NEXT 5 ROWS ONLY;

-- FETCH with ROW (singular)
SELECT * FROM employees
ORDER BY employee_id
FETCH FIRST 1 ROW ONLY;

-- FETCH FIRST with percentage
SELECT * FROM employees
ORDER BY salary DESC
FETCH FIRST 10 PERCENT ROWS ONLY;

-- FETCH FIRST with WITH TIES
-- Returns additional rows if they tie with the last row
SELECT employee_id, salary FROM employees
ORDER BY salary DESC
FETCH FIRST 5 ROWS WITH TIES;

-- OFFSET without FETCH
SELECT * FROM employees
ORDER BY employee_id
OFFSET 10 ROWS;

-- OFFSET with ROW (singular)
SELECT * FROM employees
ORDER BY employee_id
OFFSET 1 ROW;

-- OFFSET with FETCH
SELECT * FROM employees
ORDER BY employee_id
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

-- OFFSET with FETCH and WITH TIES
SELECT employee_id, salary FROM employees
ORDER BY salary DESC
OFFSET 5 ROWS
FETCH NEXT 10 ROWS WITH TIES;

-- OFFSET with FETCH FIRST percentage
SELECT * FROM employees
ORDER BY hire_date
OFFSET 5 ROWS
FETCH FIRST 20 PERCENT ROWS ONLY;

-- Pagination example - page 1
SELECT * FROM employees
ORDER BY employee_id
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY;

-- Pagination example - page 2
SELECT * FROM employees
ORDER BY employee_id
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;

-- Pagination example - page 3
SELECT * FROM employees
ORDER BY employee_id
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY;

-- Row limiting with multiple ORDER BY columns
SELECT * FROM employees
ORDER BY department_id, salary DESC
FETCH FIRST 5 ROWS ONLY;

-- Row limiting with NULL ordering
SELECT employee_id, commission_pct FROM employees
ORDER BY commission_pct NULLS LAST
FETCH FIRST 10 ROWS ONLY;

-- Row limiting in subquery
SELECT * FROM (
    SELECT employee_id, first_name, salary
    FROM employees
    ORDER BY salary DESC
    FETCH FIRST 10 ROWS ONLY
) top_earners
WHERE salary > 10000;

-- Row limiting with GROUP BY
SELECT department_id, COUNT(*) as emp_count
FROM employees
GROUP BY department_id
ORDER BY emp_count DESC
FETCH FIRST 5 ROWS ONLY;

-- Row limiting with HAVING
SELECT department_id, AVG(salary) as avg_sal
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 5000
ORDER BY avg_sal DESC
FETCH FIRST 3 ROWS ONLY;

-- Row limiting with DISTINCT
SELECT DISTINCT department_id
FROM employees
ORDER BY department_id
FETCH FIRST 5 ROWS ONLY;

-- Row limiting with UNION
(SELECT employee_id, 'A' as source FROM employees WHERE department_id = 10
 FETCH FIRST 5 ROWS ONLY)
UNION ALL
(SELECT employee_id, 'B' as source FROM employees WHERE department_id = 20
 FETCH FIRST 5 ROWS ONLY);

-- Complex example with joins and row limiting
SELECT e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
ORDER BY e.salary DESC
OFFSET 10 ROWS
FETCH FIRST 20 ROWS ONLY;

-- Row limiting with analytical functions
SELECT * FROM (
    SELECT employee_id, salary, ROW_NUMBER() OVER (ORDER BY salary DESC) as rn
    FROM employees
)
FETCH FIRST 10 ROWS ONLY;

-- Comparison: old ROWNUM approach vs new row limiting
-- Old approach:
SELECT * FROM (
    SELECT e.*, ROWNUM rn
    FROM (SELECT * FROM employees ORDER BY employee_id) e
    WHERE ROWNUM <= 20
)
WHERE rn > 10;

-- New approach (equivalent):
SELECT * FROM employees
ORDER BY employee_id
OFFSET 10 ROWS
FETCH NEXT 10 ROWS ONLY;
