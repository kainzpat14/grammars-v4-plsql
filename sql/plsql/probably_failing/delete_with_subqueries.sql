-- DELETE with subqueries
-- Tests DELETE statements using scalar subqueries, correlated subqueries, and EXISTS

-- DELETE with subquery in WHERE clause (IN)
DELETE FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
);

-- DELETE with subquery using EXISTS
DELETE FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
      AND jh.end_date < ADD_MONTHS(SYSDATE, -60)
);

-- DELETE with NOT EXISTS
DELETE FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);

-- DELETE with subquery using NOT IN
DELETE FROM employees
WHERE employee_id NOT IN (
    SELECT employee_id
    FROM active_projects
);

-- DELETE with subquery using ANY
DELETE FROM products
WHERE price < ANY (
    SELECT cost * 1.2
    FROM competitor_products
    WHERE category_id = products.category_id
);

-- DELETE with subquery using ALL
DELETE FROM employees
WHERE salary < ALL (
    SELECT AVG(salary)
    FROM employees
    GROUP BY department_id
);

-- DELETE with correlated subquery
DELETE FROM employees e
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id = e.department_id
);

-- DELETE with multiple correlated subqueries
DELETE FROM employees e
WHERE salary < (
        SELECT AVG(salary)
        FROM employees
        WHERE department_id = e.department_id
    )
  AND hire_date < (
        SELECT MIN(hire_date)
        FROM employees
        WHERE department_id = e.department_id
    );

-- DELETE with nested subqueries
DELETE FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE manager_id IN (
        SELECT employee_id
        FROM employees
        WHERE hire_date < DATE '2010-01-01'
    )
);

-- DELETE with subquery using GROUP BY
DELETE FROM departments d
WHERE department_id IN (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    HAVING COUNT(*) = 0
);

-- DELETE with subquery using HAVING
DELETE FROM products p
WHERE category_id IN (
    SELECT category_id
    FROM products
    GROUP BY category_id
    HAVING AVG(price) < 10
);

-- DELETE with subquery using aggregate functions
DELETE FROM employees e
WHERE salary_rank > (
    SELECT COUNT(*) * 0.8
    FROM employees
    WHERE department_id = e.department_id
);

-- DELETE with subquery using DISTINCT
DELETE FROM products
WHERE manufacturer_id NOT IN (
    SELECT DISTINCT manufacturer_id
    FROM approved_manufacturers
);

-- DELETE with subquery using ORDER BY and ROWNUM
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM (
        SELECT employee_id
        FROM employees
        WHERE department_id = 10
        ORDER BY hire_date DESC
    )
    WHERE ROWNUM <= 5
);

-- DELETE with subquery using JOIN
DELETE FROM employees
WHERE employee_id IN (
    SELECT e.employee_id
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.location_id = 1700
);

-- DELETE with subquery using multiple JOINs
DELETE FROM order_items
WHERE order_id IN (
    SELECT o.order_id
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN customer_status cs ON c.customer_id = cs.customer_id
    WHERE cs.status = 'INACTIVE'
);

-- DELETE with subquery using LEFT JOIN
DELETE FROM employees
WHERE employee_id IN (
    SELECT e.employee_id
    FROM employees e
    LEFT JOIN job_history jh ON e.employee_id = jh.employee_id
    WHERE jh.employee_id IS NULL
);

-- DELETE with subquery using UNION
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id FROM inactive_employees
    UNION
    SELECT employee_id FROM terminated_employees
);

-- DELETE with subquery using INTERSECT
DELETE FROM products
WHERE product_id IN (
    SELECT product_id FROM discontinued_products
    INTERSECT
    SELECT product_id FROM zero_inventory_products
);

-- DELETE with subquery using MINUS
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id FROM all_employees
    MINUS
    SELECT employee_id FROM current_employees
);

-- DELETE with subquery using WITH clause (CTE)
DELETE FROM employees
WHERE department_id IN (
    WITH inactive_depts AS (
        SELECT department_id
        FROM departments
        WHERE status = 'INACTIVE'
    )
    SELECT department_id FROM inactive_depts
);

-- DELETE with multiple CTEs in subquery
DELETE FROM employees
WHERE employee_id IN (
    WITH low_performers AS (
        SELECT employee_id
        FROM performance_reviews
        WHERE rating < 2
    ),
    excessive_absences AS (
        SELECT employee_id
        FROM attendance_records
        GROUP BY employee_id
        HAVING COUNT(*) > 20
    )
    SELECT employee_id FROM low_performers
    INTERSECT
    SELECT employee_id FROM excessive_absences
);

-- DELETE with recursive CTE in subquery
DELETE FROM employees
WHERE employee_id IN (
    WITH RECURSIVE subordinates (employee_id, manager_id) AS (
        SELECT employee_id, manager_id
        FROM employees
        WHERE manager_id = 100
        UNION ALL
        SELECT e.employee_id, e.manager_id
        FROM employees e
        JOIN subordinates s ON e.manager_id = s.employee_id
    )
    SELECT employee_id FROM subordinates
);

-- DELETE with subquery using analytic functions
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM (
        SELECT employee_id,
               PERCENT_RANK() OVER (ORDER BY salary) as salary_percentile
        FROM employees
    )
    WHERE salary_percentile < 0.1
);

-- DELETE with subquery using window functions
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM (
        SELECT employee_id,
               RANK() OVER (PARTITION BY department_id ORDER BY salary) as rank
        FROM employees
    )
    WHERE rank > 20
);

-- DELETE with subquery using ROW_NUMBER
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM (
        SELECT employee_id,
               ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY hire_date DESC) as rn
        FROM employees
    )
    WHERE rn > 50
);

-- DELETE with subquery using LAG/LEAD
DELETE FROM price_history
WHERE (product_id, effective_date) IN (
    SELECT product_id, effective_date
    FROM (
        SELECT product_id, effective_date,
               LAG(price) OVER (PARTITION BY product_id ORDER BY effective_date) as prev_price,
               price
        FROM price_history
    )
    WHERE price = prev_price
);

-- DELETE with subquery using FIRST_VALUE/LAST_VALUE
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM (
        SELECT employee_id,
               FIRST_VALUE(employee_id) OVER (
                   PARTITION BY department_id
                   ORDER BY salary DESC
                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
               ) as highest_paid_id
        FROM employees
    )
    WHERE employee_id = highest_paid_id
);

-- DELETE with subquery using LISTAGG
DELETE FROM departments
WHERE department_id IN (
    SELECT department_id
    FROM (
        SELECT d.department_id,
               LISTAGG(e.employee_id, ',') WITHIN GROUP (ORDER BY e.hire_date) as emp_list
        FROM departments d
        LEFT JOIN employees e ON d.department_id = e.department_id
        GROUP BY d.department_id
    )
    WHERE emp_list IS NULL
);

-- DELETE with subquery using PIVOT
DELETE FROM summary_records
WHERE record_id IN (
    SELECT record_id
    FROM (
        SELECT record_id
        FROM sales_data
        PIVOT (
            SUM(sales_amount)
            FOR quarter IN ('Q1', 'Q2', 'Q3', 'Q4')
        )
        WHERE q1 IS NULL AND q2 IS NULL AND q3 IS NULL AND q4 IS NULL
    )
);

-- DELETE with subquery using HIERARCHICAL query
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    START WITH manager_id = 100
    CONNECT BY PRIOR employee_id = manager_id
);

-- DELETE with subquery using CONNECT_BY_ROOT
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE CONNECT_BY_ROOT employee_id = 100
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
);

-- DELETE with subquery using SYS_CONNECT_BY_PATH
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE SYS_CONNECT_BY_PATH(department_id, '/') LIKE '%/10/%'
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
);

-- DELETE with subquery using LEVEL
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE LEVEL > 5
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
);

-- DELETE with subquery using CONNECT_BY_ISLEAF
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE CONNECT_BY_ISLEAF = 1
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
);

-- DELETE with subquery using XMLAGG
DELETE FROM departments
WHERE department_id NOT IN (
    SELECT DISTINCT department_id
    FROM employees
);

-- DELETE with subquery using JSON functions (12c+)
DELETE FROM products
WHERE product_id IN (
    SELECT product_id
    FROM products_json
    WHERE JSON_VALUE(product_data, '$.discontinued') = 'true'
);

-- DELETE with subquery using JSON_TABLE (12c+)
DELETE FROM products
WHERE product_id IN (
    SELECT p.product_id
    FROM products_json p,
         JSON_TABLE(
             p.product_data,
             '$' COLUMNS (
                 is_active VARCHAR2(10) PATH '$.active'
             )
         ) jt
    WHERE jt.is_active = 'false'
);

-- DELETE with subquery using LATERAL (12c+)
DELETE FROM employees
WHERE employee_id IN (
    SELECT e.employee_id
    FROM employees e,
         LATERAL (
             SELECT MAX(salary) as max_dept_salary
             FROM employees
             WHERE department_id = e.department_id
         ) dept_max
    WHERE e.salary < dept_max.max_dept_salary * 0.5
);

-- DELETE with subquery using CROSS APPLY (12c+)
DELETE FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM TABLE(get_termination_candidates(e.department_id)) tc
    WHERE tc.employee_id = e.employee_id
);

-- DELETE with multiple levels of correlation
DELETE FROM employees e1
WHERE EXISTS (
    SELECT 1
    FROM employees e2
    WHERE e2.department_id = e1.department_id
      AND e2.job_id = e1.job_id
      AND e2.salary > e1.salary * 2
      AND e2.hire_date < e1.hire_date
);

-- DELETE with EXISTS using complex correlation
DELETE FROM products p
WHERE EXISTS (
    SELECT 1
    FROM order_items oi
    WHERE oi.product_id = p.product_id
      AND oi.order_date > (
          SELECT MAX(last_order_date)
          FROM customer_orders
          WHERE product_id = p.product_id
      )
);

-- DELETE with subquery using set operators in correlation
DELETE FROM employees e
WHERE e.employee_id IN (
    SELECT employee_id FROM poor_performers
    UNION
    SELECT employee_id FROM disciplinary_actions
)
AND NOT EXISTS (
    SELECT 1
    FROM protected_employees pe
    WHERE pe.employee_id = e.employee_id
);

-- DELETE using scalar subquery with NULL handling
DELETE FROM employees e
WHERE department_id = (
    SELECT department_id
    FROM departments
    WHERE department_name = 'Obsolete'
);

-- DELETE with subquery using FETCH FIRST (12c+)
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE department_id = 10
    ORDER BY hire_date
    FETCH FIRST 5 ROWS ONLY
);

-- DELETE with subquery using OFFSET (12c+)
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE department_id = 10
    ORDER BY salary
    OFFSET 100 ROWS
    FETCH NEXT 10 ROWS ONLY
);

-- DELETE with complex subquery combining multiple clauses
DELETE FROM employees e
WHERE e.employee_id IN (
    WITH dept_stats AS (
        SELECT department_id, AVG(salary) as avg_salary, COUNT(*) as emp_count
        FROM employees
        GROUP BY department_id
    )
    SELECT e.employee_id
    FROM employees e
    JOIN dept_stats ds ON e.department_id = ds.department_id
    WHERE e.salary < ds.avg_salary * 0.6
      AND ds.emp_count > 10
      AND EXISTS (
          SELECT 1
          FROM performance_reviews pr
          WHERE pr.employee_id = e.employee_id
            AND pr.rating < 2
            AND pr.review_date > ADD_MONTHS(SYSDATE, -12)
      )
);

-- DELETE with subquery referencing multiple tables
DELETE FROM order_items
WHERE order_id IN (
    SELECT o.order_id
    FROM orders o
    WHERE o.customer_id IN (
        SELECT c.customer_id
        FROM customers c
        WHERE c.account_status = 'CLOSED'
          AND NOT EXISTS (
              SELECT 1
              FROM customer_contacts cc
              WHERE cc.customer_id = c.customer_id
                AND cc.contact_date > ADD_MONTHS(SYSDATE, -6)
          )
    )
);

-- DELETE with anti-join pattern
DELETE FROM staging_data s
WHERE NOT EXISTS (
    SELECT 1
    FROM master_data m
    WHERE m.record_id = s.record_id
);

-- DELETE with semi-join pattern
DELETE FROM temporary_data t
WHERE EXISTS (
    SELECT 1
    FROM processed_data p
    WHERE p.temp_id = t.temp_id
      AND p.status = 'COMPLETED'
);

-- DELETE orphaned records
DELETE FROM child_table c
WHERE NOT EXISTS (
    SELECT 1
    FROM parent_table p
    WHERE p.parent_id = c.parent_id
);

-- DELETE with subquery using inline view
DELETE FROM employees
WHERE (employee_id, department_id) IN (
    SELECT employee_id, department_id
    FROM (
        SELECT employee_id, department_id,
               ROW_NUMBER() OVER (PARTITION BY email ORDER BY employee_id) as rn
        FROM employees
    )
    WHERE rn > 1
);

-- DELETE duplicates using correlated subquery
DELETE FROM employees e1
WHERE ROWID NOT IN (
    SELECT MIN(ROWID)
    FROM employees e2
    WHERE e2.email = e1.email
    GROUP BY email
);

-- DELETE with complex EXISTS clause
DELETE FROM products p
WHERE EXISTS (
    SELECT 1
    FROM (
        SELECT product_id, SUM(quantity_sold) as total_sold
        FROM sales_history
        WHERE sale_date >= ADD_MONTHS(SYSDATE, -24)
        GROUP BY product_id
    ) sales
    WHERE sales.product_id = p.product_id
      AND sales.total_sold = 0
)
AND NOT EXISTS (
    SELECT 1
    FROM pending_orders po
    WHERE po.product_id = p.product_id
);

-- DELETE with subquery using CASE
DELETE FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM employees
    WHERE CASE
        WHEN department_id = 10 AND salary < 3000 THEN 1
        WHEN department_id = 20 AND salary < 4000 THEN 1
        WHEN hire_date < DATE '2000-01-01' THEN 1
        ELSE 0
    END = 1
);
