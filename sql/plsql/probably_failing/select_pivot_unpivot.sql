-- SELECT with PIVOT and UNPIVOT operations
-- Tests data transformation from rows to columns and vice versa

-- Basic PIVOT - convert rows to columns
SELECT *
FROM (
    SELECT department_id, job_id, salary
    FROM employees
)
PIVOT (
    AVG(salary)
    FOR job_id IN ('IT_PROG' AS it_prog, 'SA_REP' AS sales_rep, 'ST_CLERK' AS clerk)
);

-- PIVOT with SUM
SELECT *
FROM (
    SELECT department_id, job_id, salary
    FROM employees
)
PIVOT (
    SUM(salary) AS total_salary
    FOR job_id IN ('IT_PROG', 'SA_REP', 'ST_CLERK')
);

-- PIVOT with multiple aggregates
SELECT *
FROM (
    SELECT department_id, job_id, salary
    FROM employees
)
PIVOT (
    COUNT(*) AS emp_count,
    AVG(salary) AS avg_salary,
    MAX(salary) AS max_salary
    FOR job_id IN ('IT_PROG' AS it, 'SA_REP' AS sales)
);

-- PIVOT with multiple columns
SELECT *
FROM (
    SELECT department_id, job_id, hire_date, salary
    FROM employees
)
PIVOT (
    SUM(salary)
    FOR (job_id, TO_CHAR(hire_date, 'YYYY')) IN (
        ('IT_PROG', '2005') AS it_2005,
        ('IT_PROG', '2006') AS it_2006,
        ('SA_REP', '2005') AS sales_2005
    )
);

-- PIVOT with WHERE clause applied before pivoting
SELECT *
FROM (
    SELECT department_id, job_id, salary
    FROM employees
    WHERE salary > 5000
)
PIVOT (
    AVG(salary)
    FOR job_id IN ('IT_PROG', 'SA_REP', 'ST_CLERK')
);

-- PIVOT with aliased columns
SELECT department_id, it_prog AS "IT Programmers", sales_rep AS "Sales Reps"
FROM (
    SELECT department_id, job_id, salary
    FROM employees
)
PIVOT (
    AVG(salary)
    FOR job_id IN ('IT_PROG' AS it_prog, 'SA_REP' AS sales_rep)
);

-- PIVOT with numeric values
SELECT *
FROM (
    SELECT employee_id, TO_CHAR(hire_date, 'Q') AS quarter, salary
    FROM employees
)
PIVOT (
    SUM(salary)
    FOR quarter IN ('1' AS q1, '2' AS q2, '3' AS q3, '4' AS q4)
);

-- PIVOT with date columns
SELECT *
FROM (
    SELECT department_id, TO_CHAR(hire_date, 'YYYY') AS year, salary
    FROM employees
)
PIVOT (
    COUNT(*) AS emp_count
    FOR year IN ('2005', '2006', '2007', '2008')
);

-- PIVOT with GROUPING function
SELECT *
FROM (
    SELECT department_id, job_id, salary
    FROM employees
)
PIVOT (
    SUM(salary),
    COUNT(*)
    FOR job_id IN ('IT_PROG', 'SA_REP')
)
ORDER BY department_id;

-- UNPIVOT - convert columns to rows
SELECT *
FROM quarterly_sales
UNPIVOT (
    sales
    FOR quarter IN (q1, q2, q3, q4)
);

-- UNPIVOT with explicit column names
SELECT *
FROM quarterly_sales
UNPIVOT (
    sales_amount
    FOR quarter IN (
        q1_sales AS 'Q1',
        q2_sales AS 'Q2',
        q3_sales AS 'Q3',
        q4_sales AS 'Q4'
    )
);

-- UNPIVOT with multiple value columns
SELECT *
FROM yearly_summary
UNPIVOT (
    (quantity, amount)
    FOR year IN (
        (qty_2020, amt_2020) AS '2020',
        (qty_2021, amt_2021) AS '2021',
        (qty_2022, amt_2022) AS '2022'
    )
);

-- UNPIVOT with INCLUDE NULLS (11g+)
-- By default, UNPIVOT excludes NULL values
SELECT *
FROM quarterly_sales
UNPIVOT INCLUDE NULLS (
    sales
    FOR quarter IN (q1, q2, q3, q4)
);

-- UNPIVOT with EXCLUDE NULLS (explicit, default behavior)
SELECT *
FROM quarterly_sales
UNPIVOT EXCLUDE NULLS (
    sales
    FOR quarter IN (q1, q2, q3, q4)
);

-- PIVOT followed by UNPIVOT
SELECT *
FROM (
    SELECT *
    FROM (
        SELECT department_id, job_id, salary
        FROM employees
    )
    PIVOT (
        AVG(salary)
        FOR job_id IN ('IT_PROG' AS it, 'SA_REP' AS sales)
    )
)
UNPIVOT (
    avg_salary
    FOR job IN (it, sales)
);

-- PIVOT with JOIN
SELECT *
FROM (
    SELECT d.department_name, e.job_id, e.salary
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
)
PIVOT (
    AVG(salary)
    FOR job_id IN ('IT_PROG', 'SA_REP', 'ST_CLERK')
);

-- PIVOT with inline view and filtering
SELECT *
FROM (
    SELECT department_id, job_id, salary
    FROM employees
    WHERE department_id IN (50, 60, 80)
)
PIVOT (
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
    FOR job_id IN ('IT_PROG' AS it_prog, 'SA_REP' AS sales_rep)
)
WHERE department_id IS NOT NULL
ORDER BY department_id;

-- PIVOT with calculated columns
SELECT *
FROM (
    SELECT department_id, job_id, salary * 12 AS annual_salary
    FROM employees
)
PIVOT (
    SUM(annual_salary)
    FOR job_id IN ('IT_PROG', 'SA_REP')
);

-- Nested PIVOT operations
SELECT *
FROM (
    SELECT *
    FROM (
        SELECT department_id, job_id, TO_CHAR(hire_date, 'YYYY') AS year, salary
        FROM employees
    )
    PIVOT (
        SUM(salary)
        FOR year IN ('2005' AS y2005, '2006' AS y2006)
    )
)
PIVOT (
    SUM(y2005) AS total_2005,
    SUM(y2006) AS total_2006
    FOR job_id IN ('IT_PROG' AS it, 'SA_REP' AS sales)
);

-- PIVOT with DECODE (alternative to PIVOT for older versions)
SELECT department_id,
       SUM(DECODE(job_id, 'IT_PROG', salary)) AS it_prog_salary,
       SUM(DECODE(job_id, 'SA_REP', salary)) AS sales_rep_salary,
       SUM(DECODE(job_id, 'ST_CLERK', salary)) AS clerk_salary
FROM employees
GROUP BY department_id;

-- PIVOT with CASE (alternative approach)
SELECT department_id,
       SUM(CASE WHEN job_id = 'IT_PROG' THEN salary END) AS it_prog,
       SUM(CASE WHEN job_id = 'SA_REP' THEN salary END) AS sales_rep,
       SUM(CASE WHEN job_id = 'ST_CLERK' THEN salary END) AS clerk
FROM employees
GROUP BY department_id;

-- Complex PIVOT with subquery
SELECT *
FROM (
    SELECT d.department_name,
           e.job_id,
           e.salary,
           CASE
               WHEN e.salary < 5000 THEN 'Low'
               WHEN e.salary < 10000 THEN 'Medium'
               ELSE 'High'
           END AS salary_grade
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
)
PIVOT (
    COUNT(*) AS employee_count
    FOR salary_grade IN ('Low', 'Medium', 'High')
);

-- PIVOT for creating cross-tab reports
SELECT *
FROM (
    SELECT TO_CHAR(order_date, 'YYYY') AS year,
           TO_CHAR(order_date, 'Q') AS quarter,
           order_amount
    FROM orders
)
PIVOT (
    SUM(order_amount)
    FOR quarter IN ('1' AS q1, '2' AS q2, '3' AS q3, '4' AS q4)
)
ORDER BY year;

-- UNPIVOT for data normalization
SELECT product_id, year, sales_amount
FROM product_sales
UNPIVOT (
    sales_amount
    FOR year IN (
        sales_2020 AS '2020',
        sales_2021 AS '2021',
        sales_2022 AS '2022',
        sales_2023 AS '2023'
    )
);
