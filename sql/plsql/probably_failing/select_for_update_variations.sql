-- SELECT FOR UPDATE clause variations
-- Tests row locking for updates

-- Basic FOR UPDATE
SELECT * FROM employees WHERE department_id = 10 FOR UPDATE;

-- FOR UPDATE OF specific columns
SELECT e.*, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id = 10
FOR UPDATE OF e.salary;

-- FOR UPDATE OF multiple columns
SELECT e.*, d.*
FROM employees e
JOIN departments d ON e.department_id = d.department_id
FOR UPDATE OF e.salary, e.commission_pct;

-- FOR UPDATE with NOWAIT
-- Returns immediately if rows are locked by another session
SELECT * FROM employees WHERE employee_id = 100 FOR UPDATE NOWAIT;

-- FOR UPDATE with WAIT n
-- Waits up to n seconds for locked rows
SELECT * FROM employees WHERE employee_id = 100 FOR UPDATE WAIT 5;

-- FOR UPDATE with SKIP LOCKED (11g+)
-- Skips rows that are already locked
SELECT * FROM employees WHERE department_id = 10 FOR UPDATE SKIP LOCKED;

-- FOR UPDATE with SKIP LOCKED for queue processing
-- Useful for work queue patterns
SELECT task_id, task_data
FROM work_queue
WHERE status = 'PENDING'
ORDER BY priority DESC
FETCH FIRST 10 ROWS ONLY
FOR UPDATE SKIP LOCKED;

-- FOR UPDATE NOWAIT with OF clause
SELECT e.employee_id, e.salary
FROM employees e
WHERE e.department_id = 10
FOR UPDATE OF e.salary NOWAIT;

-- FOR UPDATE WAIT with OF clause
SELECT * FROM employees WHERE department_id = 10 FOR UPDATE OF salary WAIT 10;

-- FOR UPDATE SKIP LOCKED with OF clause
SELECT * FROM employees WHERE department_id = 10 FOR UPDATE OF salary SKIP LOCKED;

-- FOR UPDATE in join - lock only specific table
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id = 10
FOR UPDATE OF e.salary;

-- FOR UPDATE with ORDER BY
SELECT * FROM employees
WHERE department_id = 10
ORDER BY employee_id
FOR UPDATE;

-- FOR UPDATE with subquery (inline view)
SELECT * FROM (
    SELECT employee_id, first_name, salary
    FROM employees
    WHERE department_id = 10
) FOR UPDATE;

-- FOR UPDATE with complex join
SELECT e.employee_id, e.salary, d.department_name, j.job_title
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN jobs j ON e.job_id = j.job_id
WHERE e.department_id = 10
FOR UPDATE OF e.salary NOWAIT;

-- FOR UPDATE with WHERE CURRENT OF (in cursor context - shown for reference)
-- Used in PL/SQL blocks:
-- DECLARE
--   CURSOR c IS SELECT * FROM employees WHERE department_id = 10 FOR UPDATE;
-- BEGIN
--   FOR rec IN c LOOP
--     UPDATE employees SET salary = salary * 1.1 WHERE CURRENT OF c;
--   END LOOP;
-- END;

-- FOR UPDATE with aggregation (note: limited support)
SELECT department_id, COUNT(*) as emp_count
FROM employees
WHERE department_id IN (10, 20)
GROUP BY department_id
FOR UPDATE;

-- FOR UPDATE with UNION (each SELECT can have its own FOR UPDATE)
SELECT employee_id, first_name FROM employees WHERE department_id = 10
UNION ALL
SELECT employee_id, first_name FROM employees WHERE department_id = 20 FOR UPDATE;

-- Multiple tables with FOR UPDATE OF
SELECT e.employee_id, e.salary, d.budget
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id = 10
FOR UPDATE OF e.salary, d.budget NOWAIT;

-- FOR UPDATE with OUTER JOIN
SELECT e.employee_id, d.department_name
FROM employees e
LEFT OUTER JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id < 110
FOR UPDATE OF e.salary;

-- FOR UPDATE with FETCH FIRST (12c+)
SELECT * FROM employees
WHERE department_id = 10
ORDER BY salary DESC
FETCH FIRST 5 ROWS ONLY
FOR UPDATE SKIP LOCKED;

-- FOR UPDATE in WITH clause
WITH high_earners AS (
    SELECT * FROM employees WHERE salary > 10000
)
SELECT * FROM high_earners FOR UPDATE NOWAIT;

-- FOR UPDATE with DISTINCT (note: may have limitations)
SELECT DISTINCT department_id
FROM employees
WHERE department_id IN (10, 20)
FOR UPDATE;

-- Practical example: Queue processing with priority
SELECT job_id, job_data, priority
FROM job_queue
WHERE status = 'READY'
  AND scheduled_time <= SYSTIMESTAMP
ORDER BY priority DESC, scheduled_time ASC
FETCH FIRST 1 ROW ONLY
FOR UPDATE SKIP LOCKED;

-- Practical example: Batch processing
SELECT *
FROM transactions
WHERE processed_flag = 'N'
  AND transaction_date >= TRUNC(SYSDATE)
ORDER BY transaction_id
FETCH FIRST 1000 ROWS ONLY
FOR UPDATE SKIP LOCKED;
