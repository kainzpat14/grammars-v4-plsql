-- UPDATE with subqueries
-- Tests UPDATE statements using scalar subqueries, correlated subqueries, and EXISTS

-- UPDATE with scalar subquery in SET clause
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees WHERE department_id = 10)
WHERE employee_id = 100;

-- UPDATE with multiple scalar subqueries
UPDATE employees
SET salary = (SELECT AVG(salary) FROM employees WHERE department_id = employees.department_id),
    commission_pct = (SELECT AVG(commission_pct) FROM employees WHERE job_id = employees.job_id)
WHERE employee_id = 100;

-- UPDATE with correlated subquery
UPDATE employees e
SET salary = (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
)
WHERE e.department_id = 10;

-- UPDATE with subquery in WHERE clause (IN)
UPDATE employees
SET salary = salary * 1.1
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
);

-- UPDATE with subquery using EXISTS
UPDATE employees e
SET salary = salary * 1.15
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
      AND jh.end_date >= ADD_MONTHS(SYSDATE, -12)
);

-- UPDATE with NOT EXISTS
UPDATE employees e
SET status = 'INACTIVE'
WHERE NOT EXISTS (
    SELECT 1
    FROM timesheet t
    WHERE t.employee_id = e.employee_id
      AND t.entry_date >= ADD_MONTHS(SYSDATE, -3)
);

-- UPDATE with subquery using NOT IN
UPDATE employees
SET bonus_eligible = 'N'
WHERE employee_id NOT IN (
    SELECT employee_id
    FROM performance_reviews
    WHERE rating >= 4
);

-- UPDATE with subquery using ANY
UPDATE employees
SET salary = salary * 1.1
WHERE salary < ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 80
);

-- UPDATE with subquery using ALL
UPDATE employees
SET top_performer = 'Y'
WHERE salary > ALL (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department_id
);

-- UPDATE with multiple correlated subqueries
UPDATE employees e
SET salary = (
        SELECT MAX(salary)
        FROM employees
        WHERE department_id = e.department_id
          AND job_id = e.job_id
    ),
    last_review_date = (
        SELECT MAX(review_date)
        FROM performance_reviews
        WHERE employee_id = e.employee_id
    )
WHERE e.employee_id = 100;

-- UPDATE with subquery referencing updated table
UPDATE departments d
SET total_salary = (
    SELECT SUM(salary)
    FROM employees e
    WHERE e.department_id = d.department_id
)
WHERE d.department_id IN (10, 20, 30);

-- UPDATE with nested subqueries
UPDATE employees
SET salary = salary * 1.1
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE manager_id IN (
        SELECT employee_id
        FROM employees
        WHERE hire_date < DATE '2010-01-01'
    )
);

-- UPDATE with subquery in CASE expression
UPDATE employees e
SET bonus = CASE
    WHEN EXISTS (
        SELECT 1 FROM sales WHERE salesperson_id = e.employee_id AND sale_amount > 100000
    ) THEN salary * 0.15
    WHEN EXISTS (
        SELECT 1 FROM sales WHERE salesperson_id = e.employee_id AND sale_amount > 50000
    ) THEN salary * 0.10
    ELSE salary * 0.05
END
WHERE job_id = 'SA_REP';

-- UPDATE with subquery using GROUP BY
UPDATE departments d
SET avg_salary = (
    SELECT AVG(salary)
    FROM employees e
    WHERE e.department_id = d.department_id
    GROUP BY department_id
)
WHERE d.department_id IN (10, 20, 30);

-- UPDATE with subquery using HAVING
UPDATE departments d
SET high_earner_count = (
    SELECT COUNT(*)
    FROM employees e
    WHERE e.department_id = d.department_id
    GROUP BY department_id
    HAVING AVG(salary) > 8000
);

-- UPDATE with subquery using aggregate functions
UPDATE employees e
SET salary_rank = (
    SELECT COUNT(*) + 1
    FROM employees
    WHERE department_id = e.department_id
      AND salary > e.salary
)
WHERE e.department_id = 10;

-- UPDATE with subquery using DISTINCT
UPDATE employees
SET unique_job_count = (
    SELECT COUNT(DISTINCT job_id)
    FROM job_history jh
    WHERE jh.employee_id = employees.employee_id
)
WHERE employee_id IN (100, 101, 102);

-- UPDATE with subquery using ORDER BY and ROWNUM
UPDATE employees e
SET manager_id = (
    SELECT employee_id
    FROM employees
    WHERE department_id = e.department_id
      AND job_id LIKE '%_MAN'
      AND ROWNUM = 1
    ORDER BY hire_date
)
WHERE e.manager_id IS NULL;

-- UPDATE with subquery using JOIN
UPDATE employees e
SET department_name = (
    SELECT d.department_name
    FROM departments d
    WHERE d.department_id = e.department_id
)
WHERE e.department_name IS NULL;

-- UPDATE with subquery using multiple JOINs
UPDATE employees e
SET location_city = (
    SELECT l.city
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    WHERE d.department_id = e.department_id
)
WHERE e.employee_id = 100;

-- UPDATE with subquery using LEFT JOIN
UPDATE employees e
SET dept_budget = (
    SELECT d.budget
    FROM departments d
    LEFT JOIN dept_budgets db ON d.department_id = db.department_id
    WHERE d.department_id = e.department_id
)
WHERE e.department_id IN (10, 20);

-- UPDATE with subquery using UNION
UPDATE employees
SET status = 'SPECIAL'
WHERE employee_id IN (
    SELECT employee_id FROM top_performers
    UNION
    SELECT employee_id FROM long_tenure_employees
);

-- UPDATE with subquery using INTERSECT
UPDATE employees
SET bonus_eligible = 'Y'
WHERE employee_id IN (
    SELECT employee_id FROM high_performers
    INTERSECT
    SELECT employee_id FROM active_employees
);

-- UPDATE with subquery using MINUS
UPDATE employees
SET training_required = 'Y'
WHERE employee_id IN (
    SELECT employee_id FROM all_employees
    MINUS
    SELECT employee_id FROM trained_employees
);

-- UPDATE with subquery using WITH clause (CTE)
UPDATE employees
SET salary = salary * 1.1
WHERE department_id IN (
    WITH dept_avg AS (
        SELECT department_id, AVG(salary) as avg_sal
        FROM employees
        GROUP BY department_id
    )
    SELECT department_id
    FROM dept_avg
    WHERE avg_sal < 8000
);

-- UPDATE with multiple CTEs in subquery
UPDATE employees e
SET salary = salary * 1.15
WHERE EXISTS (
    WITH high_depts AS (
        SELECT department_id
        FROM employees
        GROUP BY department_id
        HAVING AVG(salary) > 10000
    ),
    recent_hires AS (
        SELECT employee_id
        FROM employees
        WHERE hire_date >= ADD_MONTHS(SYSDATE, -12)
    )
    SELECT 1
    FROM high_depts hd
    WHERE hd.department_id = e.department_id
      AND e.employee_id IN (SELECT employee_id FROM recent_hires)
);

-- UPDATE with recursive CTE in subquery
UPDATE employees
SET reporting_chain_depth = (
    WITH RECURSIVE emp_hierarchy (employee_id, manager_id, depth) AS (
        SELECT employee_id, manager_id, 1
        FROM employees
        WHERE employee_id = employees.employee_id
        UNION ALL
        SELECT e.employee_id, e.manager_id, eh.depth + 1
        FROM employees e
        JOIN emp_hierarchy eh ON e.manager_id = eh.employee_id
        WHERE e.manager_id IS NOT NULL
    )
    SELECT MAX(depth)
    FROM emp_hierarchy
)
WHERE employee_id = 100;

-- UPDATE with subquery using analytic functions
UPDATE employees e
SET salary_percentile = (
    SELECT PERCENT_RANK() OVER (ORDER BY salary)
    FROM employees
    WHERE employee_id = e.employee_id
)
WHERE e.department_id = 10;

-- UPDATE with subquery using window functions
UPDATE employees e
SET dept_salary_rank = (
    SELECT RANK() OVER (PARTITION BY department_id ORDER BY salary DESC)
    FROM employees
    WHERE employee_id = e.employee_id
);

-- UPDATE with subquery using LAG/LEAD
UPDATE employees e
SET previous_salary = (
    SELECT LAG(salary) OVER (ORDER BY hire_date)
    FROM employees
    WHERE department_id = e.department_id
      AND employee_id = e.employee_id
);

-- UPDATE with subquery using ROW_NUMBER
UPDATE employees e
SET hire_sequence = (
    SELECT ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY hire_date)
    FROM employees
    WHERE employee_id = e.employee_id
);

-- UPDATE with subquery using FIRST_VALUE/LAST_VALUE
UPDATE employees e
SET first_dept_hire = (
    SELECT FIRST_VALUE(employee_id) OVER (
        PARTITION BY department_id
        ORDER BY hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
    FROM employees
    WHERE employee_id = e.employee_id
);

-- UPDATE with subquery using LISTAGG
UPDATE departments d
SET employee_names = (
    SELECT LISTAGG(first_name || ' ' || last_name, ', ')
           WITHIN GROUP (ORDER BY last_name)
    FROM employees e
    WHERE e.department_id = d.department_id
)
WHERE d.department_id IN (10, 20);

-- UPDATE with subquery using PIVOT
UPDATE summary_table
SET sales_by_quarter = (
    SELECT *
    FROM (
        SELECT product_id, quarter, sales_amount
        FROM sales
        WHERE product_id = summary_table.product_id
    )
    PIVOT (
        SUM(sales_amount)
        FOR quarter IN ('Q1', 'Q2', 'Q3', 'Q4')
    )
);

-- UPDATE with subquery using HIERARCHICAL query
UPDATE employees e
SET subordinate_count = (
    SELECT COUNT(*) - 1
    FROM employees
    START WITH employee_id = e.employee_id
    CONNECT BY PRIOR employee_id = manager_id
);

-- UPDATE with subquery using CONNECT_BY_ROOT
UPDATE employees e
SET top_manager = (
    SELECT CONNECT_BY_ROOT employee_id
    FROM employees
    WHERE employee_id = e.employee_id
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
);

-- UPDATE with subquery using SYS_CONNECT_BY_PATH
UPDATE employees e
SET management_path = (
    SELECT SYS_CONNECT_BY_PATH(first_name, ' -> ')
    FROM employees
    WHERE employee_id = e.employee_id
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
);

-- UPDATE with subquery using XMLAGG
UPDATE departments d
SET employee_xml = (
    SELECT XMLAGG(XMLELEMENT("employee", e.first_name || ' ' || e.last_name))
    FROM employees e
    WHERE e.department_id = d.department_id
)
WHERE d.department_id = 10;

-- UPDATE with subquery using JSON functions (12c+)
UPDATE departments d
SET employees_json = (
    SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
            'id' VALUE employee_id,
            'name' VALUE first_name || ' ' || last_name,
            'salary' VALUE salary
        )
    )
    FROM employees e
    WHERE e.department_id = d.department_id
)
WHERE d.department_id IN (10, 20);

-- UPDATE with subquery using JSON_TABLE (12c+)
UPDATE products
SET category = (
    SELECT jt.category
    FROM JSON_TABLE(
        product_data,
        '$' COLUMNS (
            category VARCHAR2(50) PATH '$.category'
        )
    ) jt
    WHERE ROWNUM = 1
)
WHERE product_id = 100;

-- UPDATE with subquery using LATERAL (12c+)
UPDATE employees e
SET latest_project = (
    SELECT p.project_name
    FROM LATERAL (
        SELECT project_name
        FROM projects
        WHERE manager_id = e.employee_id
        ORDER BY start_date DESC
        FETCH FIRST 1 ROW ONLY
    ) p
);

-- UPDATE with subquery using CROSS APPLY (12c+)
UPDATE employees e
SET top_sale_amount = (
    SELECT s.sale_amount
    FROM TABLE(get_employee_sales(e.employee_id)) s
    WHERE ROWNUM = 1
    ORDER BY s.sale_amount DESC
);

-- UPDATE with subquery using multiple levels of correlation
UPDATE employees e1
SET avg_peer_salary = (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
      AND e2.job_id = e1.job_id
      AND e2.employee_id != e1.employee_id
      AND e2.hire_date BETWEEN ADD_MONTHS(e1.hire_date, -12)
                           AND ADD_MONTHS(e1.hire_date, 12)
)
WHERE e1.department_id = 10;

-- UPDATE with EXISTS using complex correlation
UPDATE departments d
SET has_high_earners = 'Y'
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
      AND e.salary > (
          SELECT AVG(salary) * 1.5
          FROM employees
          WHERE department_id = d.department_id
      )
);

-- UPDATE with subquery using set operators in correlation
UPDATE employees e
SET multi_dept_experience = 'Y'
WHERE e.employee_id IN (
    SELECT employee_id FROM job_history WHERE department_id = 10
    INTERSECT
    SELECT employee_id FROM job_history WHERE department_id = 20
)
AND EXISTS (
    SELECT 1 FROM job_history jh
    WHERE jh.employee_id = e.employee_id
    GROUP BY employee_id
    HAVING COUNT(DISTINCT department_id) >= 2
);

-- UPDATE with scalar subquery returning NULL handling
UPDATE employees e
SET manager_name = (
    SELECT first_name || ' ' || last_name
    FROM employees
    WHERE employee_id = e.manager_id
)
WHERE e.manager_id IS NOT NULL;

-- UPDATE with subquery using FETCH FIRST (12c+)
UPDATE employees e
SET highest_dept_salary = (
    SELECT salary
    FROM employees
    WHERE department_id = e.department_id
    ORDER BY salary DESC
    FETCH FIRST 1 ROW ONLY
);

-- UPDATE with subquery using OFFSET (12c+)
UPDATE employees e
SET second_highest_salary = (
    SELECT salary
    FROM employees
    WHERE department_id = e.department_id
    ORDER BY salary DESC
    OFFSET 1 ROW
    FETCH FIRST 1 ROW ONLY
);

-- UPDATE using inline view in FROM-like pattern (Oracle allows subquery in SET)
UPDATE (
    SELECT e.salary, e.commission_pct, d.department_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = 'Sales'
)
SET salary = salary * 1.1,
    commission_pct = 0.15;

-- UPDATE with complex inline view
UPDATE (
    SELECT e1.salary as emp_salary,
           e2.salary as mgr_salary,
           e1.employee_id
    FROM employees e1
    JOIN employees e2 ON e1.manager_id = e2.employee_id
    WHERE e1.department_id = 10
)
SET emp_salary = mgr_salary * 0.8
WHERE emp_salary > mgr_salary;

-- UPDATE with inline view using aggregation
UPDATE (
    SELECT d.department_id, d.total_salary, SUM(e.salary) as calc_total
    FROM departments d
    JOIN employees e ON d.department_id = e.department_id
    GROUP BY d.department_id, d.total_salary
)
SET total_salary = calc_total;

-- UPDATE with inline view and WHERE clause
UPDATE (
    SELECT employee_id, salary, department_id
    FROM employees
    WHERE department_id = 10
)
SET salary = salary * 1.1
WHERE salary < 8000;
