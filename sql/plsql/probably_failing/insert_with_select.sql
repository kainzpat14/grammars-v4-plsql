-- INSERT with SELECT (INSERT INTO ... SELECT)
-- Tests inserting data from queries

-- Basic INSERT INTO SELECT
INSERT INTO employees_backup
SELECT * FROM employees;

-- INSERT INTO SELECT with specific columns
INSERT INTO employee_summary (employee_id, full_name, annual_salary)
SELECT employee_id, first_name || ' ' || last_name, salary * 12
FROM employees;

-- INSERT INTO SELECT with WHERE clause
INSERT INTO high_earners (employee_id, first_name, last_name, salary)
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > 10000;

-- INSERT INTO SELECT with JOIN
INSERT INTO emp_dept_summary (employee_id, employee_name, department_name)
SELECT e.employee_id, e.first_name || ' ' || e.last_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- INSERT INTO SELECT with multiple JOINs
INSERT INTO employee_details
SELECT e.employee_id, e.first_name, e.last_name,
       d.department_name, j.job_title, l.city
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id
JOIN locations l ON d.location_id = l.location_id;

-- INSERT INTO SELECT with GROUP BY
INSERT INTO dept_statistics (department_id, emp_count, avg_salary, total_salary)
SELECT department_id, COUNT(*), AVG(salary), SUM(salary)
FROM employees
GROUP BY department_id;

-- INSERT INTO SELECT with ORDER BY
INSERT INTO employees_ranked
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC;

-- INSERT INTO SELECT with DISTINCT
INSERT INTO unique_departments (department_id)
SELECT DISTINCT department_id
FROM employees
WHERE department_id IS NOT NULL;

-- INSERT INTO SELECT with subquery
INSERT INTO dept_managers (department_id, manager_id)
SELECT department_id, manager_id
FROM employees e
WHERE employee_id IN (
    SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL
);

-- INSERT INTO SELECT with UNION
INSERT INTO all_people (person_id, person_name, person_type)
SELECT employee_id, first_name || ' ' || last_name, 'Employee'
FROM employees
UNION ALL
SELECT customer_id, customer_name, 'Customer'
FROM customers;

-- INSERT INTO SELECT with CASE
INSERT INTO employee_grades (employee_id, salary_grade)
SELECT employee_id,
       CASE
           WHEN salary > 10000 THEN 'High'
           WHEN salary > 5000 THEN 'Medium'
           ELSE 'Low'
       END
FROM employees;

-- INSERT INTO SELECT with analytical functions
INSERT INTO employee_rankings (employee_id, dept_rank)
SELECT employee_id,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC)
FROM employees;

-- INSERT INTO SELECT with aggregate window functions
INSERT INTO running_totals (employee_id, running_salary)
SELECT employee_id,
       SUM(salary) OVER (ORDER BY employee_id)
FROM employees;

-- INSERT INTO SELECT with FETCH FIRST
INSERT INTO top_earners
SELECT employee_id, first_name, salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;

-- INSERT INTO SELECT with OFFSET
INSERT INTO page_results
SELECT employee_id, first_name
FROM employees
ORDER BY employee_id
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;

-- INSERT INTO SELECT with inline view
INSERT INTO filtered_employees
SELECT *
FROM (
    SELECT employee_id, first_name, salary,
           ROW_NUMBER() OVER (ORDER BY salary DESC) as rn
    FROM employees
)
WHERE rn <= 100;

-- INSERT INTO SELECT with PIVOT
INSERT INTO quarterly_sales_summary
SELECT *
FROM (
    SELECT product_id, TO_CHAR(sale_date, 'Q') as quarter, amount
    FROM sales
)
PIVOT (
    SUM(amount)
    FOR quarter IN ('1' AS q1, '2' AS q2, '3' AS q3, '4' AS q4)
);

-- INSERT INTO SELECT with hierarchical query
INSERT INTO org_hierarchy (employee_id, level_num, manager_path)
SELECT employee_id, LEVEL,
       SYS_CONNECT_BY_PATH(employee_id, '/') as path
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- INSERT INTO SELECT from multiple tables with complex logic
INSERT INTO employee_performance_summary
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name as full_name,
       d.department_name,
       COUNT(p.project_id) as project_count,
       AVG(pr.rating) as avg_rating,
       CASE
           WHEN AVG(pr.rating) >= 4.5 THEN 'Excellent'
           WHEN AVG(pr.rating) >= 3.5 THEN 'Good'
           ELSE 'Needs Improvement'
       END as performance_category
FROM employees e
JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employee_projects ep ON e.employee_id = ep.employee_id
LEFT JOIN projects p ON ep.project_id = p.project_id
LEFT JOIN performance_reviews pr ON e.employee_id = pr.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, d.department_name
HAVING COUNT(p.project_id) > 0;

-- INSERT INTO SELECT with WITH clause (CTE)
INSERT INTO summary_data
WITH dept_totals AS (
    SELECT department_id, SUM(salary) as total_salary
    FROM employees
    GROUP BY department_id
),
dept_averages AS (
    SELECT department_id, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT dt.department_id, dt.total_salary, da.avg_salary
FROM dept_totals dt
JOIN dept_averages da ON dt.department_id = da.department_id;

-- INSERT INTO SELECT with recursive CTE
INSERT INTO number_sequence (num)
WITH RECURSIVE numbers(n) AS (
    SELECT 1 FROM DUAL
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 100
)
SELECT n FROM numbers;

-- INSERT INTO SELECT with CONNECT_BY_ROOT
INSERT INTO employee_hierarchy
SELECT employee_id,
       CONNECT_BY_ROOT employee_id as root_manager_id,
       LEVEL as org_level
FROM employees
CONNECT BY PRIOR employee_id = manager_id;

-- INSERT INTO SELECT from external table
INSERT INTO imported_data
SELECT * FROM external_csv_table;

-- INSERT INTO SELECT with table collection
INSERT INTO result_table
SELECT * FROM TABLE(my_pipelined_function(100));

-- INSERT INTO SELECT with XMLTABLE
INSERT INTO parsed_xml_data (id, name, value)
SELECT x.id, x.name, x.value
FROM xml_documents,
     XMLTABLE('/root/item'
         PASSING xml_content
         COLUMNS
             id NUMBER PATH '@id',
             name VARCHAR2(100) PATH 'name',
             value VARCHAR2(200) PATH 'value'
     ) x;

-- INSERT INTO SELECT with JSON_TABLE (12c+)
INSERT INTO parsed_json_data (id, name, email)
SELECT jt.id, jt.name, jt.email
FROM json_documents,
     JSON_TABLE(json_content, '$.users[*]'
         COLUMNS (
             id NUMBER PATH '$.id',
             name VARCHAR2(100) PATH '$.name',
             email VARCHAR2(200) PATH '$.email'
         )
     ) jt;

-- INSERT INTO SELECT with LATERAL inline view
INSERT INTO employee_top_skills
SELECT e.employee_id, e.first_name, top_skill.skill_name
FROM employees e,
     LATERAL (
         SELECT skill_name
         FROM employee_skills es
         WHERE es.employee_id = e.employee_id
         ORDER BY proficiency_level DESC
         FETCH FIRST 1 ROW ONLY
     ) top_skill;

-- INSERT INTO SELECT with CROSS APPLY equivalent
INSERT INTO employee_project_summary
SELECT e.employee_id, recent_projects.project_count
FROM employees e,
     LATERAL (
         SELECT COUNT(*) as project_count
         FROM employee_projects ep
         WHERE ep.employee_id = e.employee_id
           AND ep.start_date >= ADD_MONTHS(SYSDATE, -12)
     ) recent_projects;

-- INSERT INTO SELECT with set operators (INTERSECT, MINUS)
INSERT INTO active_in_both_systems
SELECT employee_id FROM system_a
INTERSECT
SELECT employee_id FROM system_b;

-- INSERT INTO SELECT excluding records
INSERT INTO unique_to_system_a
SELECT employee_id FROM system_a
MINUS
SELECT employee_id FROM system_b;

-- INSERT INTO SELECT with complex WHERE conditions
INSERT INTO filtered_results
SELECT *
FROM employees
WHERE (salary > 5000 AND department_id IN (10, 20, 30))
   OR (job_id = 'IT_PROG' AND hire_date > ADD_MONTHS(SYSDATE, -24))
   OR employee_id IN (SELECT manager_id FROM employees WHERE manager_id IS NOT NULL);

-- INSERT INTO SELECT with correlated subquery
INSERT INTO employee_salary_comparison (employee_id, salary, dept_avg)
SELECT e.employee_id, e.salary,
       (SELECT AVG(salary)
        FROM employees e2
        WHERE e2.department_id = e.department_id) as dept_avg
FROM employees e;

-- INSERT INTO SELECT with EXISTS
INSERT INTO employees_with_subordinates
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1 FROM employees sub
    WHERE sub.manager_id = e.employee_id
);

-- INSERT INTO SELECT using MERGE concepts
INSERT INTO target_table (id, name, value)
SELECT s.id, s.name, s.value
FROM source_table s
WHERE NOT EXISTS (
    SELECT 1 FROM target_table t
    WHERE t.id = s.id
);
