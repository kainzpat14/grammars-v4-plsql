-- UPDATE with LOG ERRORS clause (10g R2+)
-- Tests error logging for constraint violations during bulk updates

-- Basic UPDATE with LOG ERRORS
UPDATE employees
SET salary = salary * 1.1
WHERE department_id = 10
LOG ERRORS REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS and specific reject limit
UPDATE employees
SET salary = salary * 1.1,
    commission_pct = 0.15
WHERE department_id IN (10, 20, 30)
LOG ERRORS REJECT LIMIT 100;

-- UPDATE with LOG ERRORS into specific error table
UPDATE employees
SET email = LOWER(first_name || '.' || last_name || '@company.com')
WHERE email IS NULL
LOG ERRORS INTO emp_error_log REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS and error tag
UPDATE employees
SET salary = salary * 1.1
WHERE department_id = 10
LOG ERRORS INTO emp_error_log ('SALARY_UPDATE_2024_01') REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - numeric reject limit
UPDATE employees
SET department_id = 50
WHERE employee_id BETWEEN 1000 AND 2000
LOG ERRORS REJECT LIMIT 50;

-- UPDATE with LOG ERRORS and zero reject limit (fail on first error)
UPDATE employees
SET manager_id = 100
WHERE department_id = 10
LOG ERRORS REJECT LIMIT 0;

-- UPDATE with LOG ERRORS using complex WHERE clause
UPDATE employees
SET salary = salary * 1.15,
    commission_pct = 0.2
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
)
LOG ERRORS REJECT LIMIT 25;

-- UPDATE with LOG ERRORS and JOIN pattern (inline view)
UPDATE (
    SELECT e.salary, e.commission_pct
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_name = 'Sales'
)
SET salary = salary * 1.1,
    commission_pct = 0.2
LOG ERRORS REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS for constraint violations
-- Useful when updating with values that might violate check constraints
UPDATE employees
SET salary = new_salary_value,
    commission_pct = new_commission_value
WHERE employee_id IN (
    SELECT employee_id FROM salary_updates
)
LOG ERRORS INTO emp_update_errors ('BULK_UPDATE_Q1') REJECT LIMIT 500;

-- UPDATE with LOG ERRORS - testing unique constraint violations
UPDATE employees
SET email = 'duplicate@company.com'
WHERE department_id = 10
LOG ERRORS REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - testing foreign key constraint violations
UPDATE employees
SET department_id = 999  -- Non-existent department
WHERE employee_id BETWEEN 100 AND 200
LOG ERRORS INTO emp_fk_errors REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - testing check constraint violations
UPDATE employees
SET salary = -1000  -- Negative salary violates check constraint
WHERE department_id = 10
LOG ERRORS INTO emp_check_errors ('CHECK_VIOLATION_TEST') REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - testing NOT NULL constraint violations
UPDATE employees
SET email = NULL  -- Assuming email has NOT NULL constraint
WHERE department_id = 10
LOG ERRORS REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS from staging table
UPDATE employees e
SET (salary, commission_pct, department_id) = (
    SELECT new_salary, new_commission, new_dept_id
    FROM employee_updates eu
    WHERE eu.employee_id = e.employee_id
)
WHERE EXISTS (
    SELECT 1 FROM employee_updates eu
    WHERE eu.employee_id = e.employee_id
)
LOG ERRORS INTO emp_update_errors ('STAGING_LOAD') REJECT LIMIT 1000;

-- UPDATE with LOG ERRORS and error table querying
UPDATE employees
SET salary = salary * 1.2
WHERE department_id = 50
LOG ERRORS INTO emp_error_log ('BATCH_A') REJECT LIMIT UNLIMITED;

-- Query the error log after update
SELECT ora_err_number$, ora_err_mesg$, ora_err_tag$, employee_id, salary
FROM emp_error_log
WHERE ora_err_tag$ = 'BATCH_A';

-- UPDATE with LOG ERRORS - multiple constraint types
UPDATE employees
SET employee_id = employee_id + 10000,  -- May violate primary key
    email = first_name || '@test.com',  -- May violate unique constraint
    department_id = 999,                -- May violate foreign key
    salary = -100                       -- May violate check constraint
WHERE department_id = 10
LOG ERRORS INTO emp_multi_errors ('MULTI_CONSTRAINT_TEST') REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - conditional updates
UPDATE employees
SET salary = CASE
        WHEN job_id = 'IT_PROG' THEN salary * 1.15
        WHEN job_id = 'SA_REP' THEN salary * 1.20
        ELSE salary * 1.10
    END,
    last_updated = SYSDATE
WHERE department_id IN (10, 20, 30)
LOG ERRORS REJECT LIMIT 100;

-- UPDATE with LOG ERRORS - using subquery in SET
UPDATE employees e
SET salary = (
        SELECT AVG(salary) * 1.2
        FROM employees
        WHERE department_id = e.department_id
    )
WHERE employee_id IN (SELECT employee_id FROM high_performers)
LOG ERRORS INTO emp_avg_errors ('AVG_SALARY_UPDATE') REJECT LIMIT 50;

-- UPDATE with LOG ERRORS - date/timestamp updates
UPDATE employees
SET hire_date = hire_date + INTERVAL '1' YEAR,
    last_modified = SYSTIMESTAMP
WHERE department_id = 10
LOG ERRORS REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - CLOB/BLOB updates
UPDATE documents
SET content = content || CHR(10) || 'Additional content',
    last_modified = SYSDATE
WHERE doc_type = 'TEXT'
  AND content IS NOT NULL
LOG ERRORS INTO doc_error_log REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - JSON updates (23ai)
UPDATE products_json
SET product_data = JSON_MERGEPATCH(
        product_data,
        '{"updated": true, "lastModified": "2024-01-01"}'
    )
WHERE category = 'Electronics'
LOG ERRORS INTO product_errors REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - complex inline view
UPDATE (
    SELECT e.salary, e.commission_pct, d.budget
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE d.budget > 100000
)
SET salary = salary * 1.1,
    commission_pct = GREATEST(commission_pct, 0.1)
LOG ERRORS INTO emp_budget_errors ('HIGH_BUDGET_DEPTS') REJECT LIMIT 200;

-- UPDATE with LOG ERRORS - using WITH clause
WITH dept_bonuses AS (
    SELECT department_id, bonus_multiplier
    FROM department_bonus_rates
    WHERE effective_date = TRUNC(SYSDATE)
)
UPDATE employees e
SET salary = salary * (1 + db.bonus_multiplier)
FROM dept_bonuses db
WHERE e.department_id = db.department_id
LOG ERRORS REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - batch processing pattern
UPDATE employees
SET processed_flag = 'Y',
    processed_date = SYSDATE
WHERE processed_flag = 'N'
  AND ROWNUM <= 10000
LOG ERRORS INTO emp_batch_errors ('BATCH_PROCESS') REJECT LIMIT 100;

-- UPDATE with LOG ERRORS - multiple column updates with functions
UPDATE employees
SET first_name = INITCAP(TRIM(first_name)),
    last_name = INITCAP(TRIM(last_name)),
    email = UPPER(TRIM(email)),
    phone_number = REGEXP_REPLACE(phone_number, '[^0-9]', '')
WHERE employee_id > 1000
LOG ERRORS INTO emp_cleanup_errors ('DATA_CLEANUP') REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - handling division by zero
UPDATE sales_data
SET margin_pct = (revenue - cost) / NULLIF(revenue, 0) * 100
WHERE sale_date >= TRUNC(SYSDATE, 'MM')
LOG ERRORS INTO sales_calc_errors REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - aggregation in subquery
UPDATE departments d
SET total_salary = (
        SELECT SUM(salary)
        FROM employees e
        WHERE e.department_id = d.department_id
    ),
    avg_salary = (
        SELECT AVG(salary)
        FROM employees e
        WHERE e.department_id = d.department_id
    ),
    emp_count = (
        SELECT COUNT(*)
        FROM employees e
        WHERE e.department_id = d.department_id
    )
WHERE d.department_id IN (10, 20, 30)
LOG ERRORS INTO dept_summary_errors REJECT LIMIT 10;

-- UPDATE with LOG ERRORS - XMLTYPE updates
UPDATE xml_documents
SET xml_data = UPDATEXML(
        xml_data,
        '/root/status/text()',
        'UPDATED'
    ),
    modified_date = SYSDATE
WHERE doc_type = 'ORDER'
LOG ERRORS INTO xml_update_errors REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - collection updates
UPDATE departments
SET employee_ids = CAST(MULTISET(
        SELECT employee_id
        FROM employees e
        WHERE e.department_id = departments.department_id
    ) AS number_array_type)
WHERE department_id IN (10, 20)
LOG ERRORS REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - monitoring errors during execution
UPDATE employees
SET salary = new_salary_table.new_salary
FROM (
    SELECT employee_id, salary * 1.15 as new_salary
    FROM employees
    WHERE performance_rating >= 4
) new_salary_table
WHERE employees.employee_id = new_salary_table.employee_id
LOG ERRORS INTO emp_perf_errors ('PERFORMANCE_RAISE') REJECT LIMIT UNLIMITED;

-- Check error count
SELECT COUNT(*) as error_count,
       ora_err_tag$,
       ora_err_number$,
       COUNT(DISTINCT ora_err_mesg$) as distinct_errors
FROM emp_perf_errors
WHERE ora_err_tag$ = 'PERFORMANCE_RAISE'
GROUP BY ora_err_tag$, ora_err_number$;

-- UPDATE with LOG ERRORS - complex business logic
UPDATE employees e
SET salary = CASE
        WHEN (SELECT COUNT(*) FROM projects p WHERE p.manager_id = e.employee_id) > 5
            THEN salary * 1.20
        WHEN EXISTS (SELECT 1 FROM awards a WHERE a.employee_id = e.employee_id AND a.year = EXTRACT(YEAR FROM SYSDATE))
            THEN salary * 1.15
        WHEN MONTHS_BETWEEN(SYSDATE, hire_date) / 12 >= 10
            THEN salary * 1.10
        ELSE salary * 1.05
    END,
    last_review_date = SYSDATE
WHERE active = 'Y'
LOG ERRORS INTO emp_complex_errors ('ANNUAL_REVIEW') REJECT LIMIT 500;

-- UPDATE with LOG ERRORS - geographical data
UPDATE locations
SET coordinates = SDO_GEOMETRY(
        2001,
        8307,
        SDO_POINT_TYPE(longitude, latitude, NULL),
        NULL,
        NULL
    )
WHERE coordinates IS NULL
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL
LOG ERRORS INTO location_geo_errors REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - partitioned table
UPDATE sales_history PARTITION (sales_q1_2024)
SET processed = 'Y',
    verification_date = SYSDATE
WHERE processed = 'N'
LOG ERRORS INTO sales_partition_errors ('Q1_2024_PROCESS') REJECT LIMIT 100;

-- UPDATE with LOG ERRORS - global temporary table
UPDATE /*+ APPEND */ global_temp_employees
SET temp_salary = salary * bonus_multiplier
WHERE session_id = SYS_CONTEXT('USERENV', 'SESSIONID')
LOG ERRORS INTO temp_update_errors REJECT LIMIT UNLIMITED;

-- UPDATE with LOG ERRORS - with hints
UPDATE /*+ PARALLEL(employees, 4) */ employees
SET last_accessed = SYSDATE,
    access_count = access_count + 1
WHERE last_accessed < TRUNC(SYSDATE)
LOG ERRORS REJECT LIMIT 1000;

-- Cleanup: Query and analyze error log
SELECT ora_err_number$,
       ora_err_mesg$,
       ora_err_rowid$,
       ora_err_optyp$,
       ora_err_tag$,
       employee_id,
       salary
FROM emp_error_log
WHERE ora_err_tag$ LIKE 'BATCH%'
ORDER BY ora_err_timestamp$ DESC;

-- UPDATE with LOG ERRORS - recovering from errors
-- First attempt with error logging
UPDATE employees
SET salary = problematic_value
WHERE employee_id IN (SELECT employee_id FROM updates_to_apply)
LOG ERRORS INTO emp_recovery_errors ('ATTEMPT_1') REJECT LIMIT UNLIMITED;

-- Identify and fix errors
UPDATE employees
SET salary = corrected_value
WHERE employee_id IN (
    SELECT employee_id
    FROM emp_recovery_errors
    WHERE ora_err_tag$ = 'ATTEMPT_1'
);

-- Retry original update without errored rows
UPDATE employees
SET salary = problematic_value
WHERE employee_id IN (
    SELECT employee_id FROM updates_to_apply
    MINUS
    SELECT employee_id FROM emp_recovery_errors WHERE ora_err_tag$ = 'ATTEMPT_1'
)
LOG ERRORS INTO emp_recovery_errors ('ATTEMPT_2') REJECT LIMIT UNLIMITED;
