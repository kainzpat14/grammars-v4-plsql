-- DELETE statement basic variations
-- Tests basic DELETE syntax with various clauses and conditions

-- Basic DELETE with WHERE clause
DELETE FROM employees
WHERE employee_id = 100;

-- DELETE multiple rows
DELETE FROM employees
WHERE department_id = 10;

-- DELETE with complex WHERE clause
DELETE FROM employees
WHERE department_id = 10
  AND hire_date < DATE '2010-01-01'
  AND salary < 5000;

-- DELETE with IN clause
DELETE FROM employees
WHERE employee_id IN (100, 101, 102, 103);

-- DELETE with BETWEEN
DELETE FROM employees
WHERE salary BETWEEN 3000 AND 4000;

-- DELETE with LIKE
DELETE FROM employees
WHERE email LIKE '%@oldcompany.com';

-- DELETE with IS NULL
DELETE FROM employees
WHERE commission_pct IS NULL AND job_id = 'SA_REP';

-- DELETE with IS NOT NULL
DELETE FROM employees
WHERE email IS NOT NULL AND active_flag = 'N';

-- DELETE with multiple conditions (AND/OR)
DELETE FROM employees
WHERE (department_id = 10 OR department_id = 20)
  AND hire_date < ADD_MONTHS(SYSDATE, -24);

-- DELETE with NOT operator
DELETE FROM employees
WHERE NOT (status = 'ACTIVE');

-- DELETE all rows (no WHERE clause - dangerous!)
DELETE FROM temp_employees;

-- DELETE with date comparison
DELETE FROM log_entries
WHERE log_date < TRUNC(SYSDATE) - 30;

-- DELETE with timestamp comparison
DELETE FROM audit_records
WHERE audit_timestamp < SYSTIMESTAMP - INTERVAL '90' DAY;

-- DELETE with arithmetic expression
DELETE FROM products
WHERE price < cost * 1.1;

-- DELETE with function call
DELETE FROM employees
WHERE UPPER(email) LIKE '%INVALID%';

-- DELETE with SUBSTR
DELETE FROM employees
WHERE SUBSTR(phone_number, 1, 3) = '555';

-- DELETE with LENGTH
DELETE FROM employees
WHERE LENGTH(last_name) > 20;

-- DELETE with INSTR
DELETE FROM employees
WHERE INSTR(email, '@') = 0;

-- DELETE with TRIM
DELETE FROM employees
WHERE TRIM(first_name) IS NULL OR TRIM(first_name) = '';

-- DELETE with TO_CHAR
DELETE FROM employees
WHERE TO_CHAR(hire_date, 'YYYY') = '2005';

-- DELETE with EXTRACT
DELETE FROM employees
WHERE EXTRACT(YEAR FROM hire_date) < 2010;

-- DELETE with CASE in WHERE
DELETE FROM employees
WHERE CASE
    WHEN department_id = 10 THEN 1
    WHEN department_id = 20 THEN 1
    ELSE 0
END = 1;

-- DELETE with ROWNUM
DELETE FROM employees
WHERE department_id = 10
  AND ROWNUM <= 5;

-- DELETE with ROWID
DELETE FROM employees
WHERE ROWID = 'AAAA5nAABAAAVFqAAA';

-- DELETE with NVL
DELETE FROM employees
WHERE NVL(commission_pct, 0) = 0;

-- DELETE with COALESCE
DELETE FROM employees
WHERE COALESCE(phone_number, mobile_number, '000') = '000';

-- DELETE with DECODE
DELETE FROM employees
WHERE DECODE(department_id, 10, 'Y', 20, 'Y', 'N') = 'Y';

-- DELETE with NULLIF
DELETE FROM employees
WHERE NULLIF(status, 'INACTIVE') IS NULL;

-- DELETE with GREATEST/LEAST
DELETE FROM products
WHERE LEAST(quantity_on_hand, reorder_point) = 0;

-- DELETE with interval arithmetic
DELETE FROM sessions
WHERE last_activity < SYSTIMESTAMP - INTERVAL '2' HOUR;

-- DELETE with date functions
DELETE FROM employees
WHERE LAST_DAY(hire_date) < LAST_DAY(DATE '2010-01-01');

-- DELETE with ADD_MONTHS
DELETE FROM contracts
WHERE end_date < ADD_MONTHS(SYSDATE, -12);

-- DELETE with MONTHS_BETWEEN
DELETE FROM employees
WHERE MONTHS_BETWEEN(SYSDATE, hire_date) > 120;

-- DELETE with TRUNC
DELETE FROM daily_stats
WHERE TRUNC(stat_date) < TRUNC(SYSDATE) - 7;

-- DELETE with ROUND (numeric)
DELETE FROM price_changes
WHERE ROUND(price_change_pct, 0) = 0;

-- DELETE with ABS
DELETE FROM transactions
WHERE ABS(amount) < 0.01;

-- DELETE with SIGN
DELETE FROM balances
WHERE SIGN(balance_amount) = -1;

-- DELETE with MOD
DELETE FROM employees
WHERE MOD(employee_id, 2) = 0;

-- DELETE with POWER
DELETE FROM calculations
WHERE POWER(base_value, 2) > 1000;

-- DELETE with SQRT
DELETE FROM measurements
WHERE SQRT(value) < 10;

-- DELETE with FLOOR/CEIL
DELETE FROM products
WHERE FLOOR(price) != CEIL(cost * markup_factor);

-- DELETE with CONCAT/concatenation operator
DELETE FROM employees
WHERE first_name || ' ' || last_name = 'John Doe';

-- DELETE with REPLACE
DELETE FROM employees
WHERE REPLACE(phone_number, '-', '') LIKE '555%';

-- DELETE with TRANSLATE
DELETE FROM products
WHERE TRANSLATE(product_code, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'obsolete';

-- DELETE with LPAD/RPAD
DELETE FROM employees
WHERE LPAD(employee_id, 10, '0') LIKE '0000000%';

-- DELETE with LTRIM/RTRIM
DELETE FROM customers
WHERE RTRIM(customer_name) = '';

-- DELETE with INITCAP
DELETE FROM employees
WHERE INITCAP(last_name) != last_name;

-- DELETE with LOWER/UPPER
DELETE FROM users
WHERE LOWER(username) = 'anonymous';

-- DELETE with regular expressions
DELETE FROM employees
WHERE REGEXP_LIKE(email, '^[0-9]+@');

-- DELETE with REGEXP_REPLACE
DELETE FROM employees
WHERE REGEXP_REPLACE(phone_number, '[^0-9]', '') LIKE '555%';

-- DELETE with REGEXP_SUBSTR
DELETE FROM products
WHERE REGEXP_SUBSTR(product_code, '[A-Z]+') = 'OLD';

-- DELETE with EXISTS (scalar subquery)
DELETE FROM employees
WHERE (SELECT COUNT(*) FROM job_history WHERE employee_id = employees.employee_id) = 0;

-- DELETE with table alias
DELETE FROM employees e
WHERE e.department_id = 10;

-- DELETE with schema qualification
DELETE FROM hr.employees
WHERE department_id = 10;

-- DELETE with CAST
DELETE FROM employees
WHERE CAST(hire_date AS TIMESTAMP) < TIMESTAMP '2010-01-01 00:00:00';

-- DELETE with TO_NUMBER
DELETE FROM employees
WHERE TO_NUMBER(employee_id_str) < 1000;

-- DELETE with TO_DATE
DELETE FROM events
WHERE TO_DATE(event_date_str, 'YYYY-MM-DD') < DATE '2020-01-01';

-- DELETE with TO_TIMESTAMP
DELETE FROM logs
WHERE TO_TIMESTAMP(log_time_str, 'YYYY-MM-DD HH24:MI:SS') < TIMESTAMP '2024-01-01 00:00:00';

-- DELETE with JSON condition (23ai)
DELETE FROM products_json
WHERE JSON_VALUE(product_data, '$.active') = 'false';

-- DELETE with JSON_EXISTS (12c+)
DELETE FROM documents_json
WHERE JSON_EXISTS(doc_data, '$.archived');

-- DELETE with BOOLEAN condition (23ai)
DELETE FROM feature_flags
WHERE is_enabled = FALSE;

-- DELETE with boolean expression (23ai)
DELETE FROM tasks
WHERE is_completed = TRUE AND completion_date < SYSDATE - 90;

-- DELETE with XML condition
DELETE FROM xml_documents
WHERE EXTRACTVALUE(xml_data, '/root/status') = 'DELETED';

-- DELETE with XMLEXISTS (11g+)
DELETE FROM xml_documents
WHERE XMLEXISTS('/root/archived[text()="true"]' PASSING xml_data);

-- DELETE with collection condition
DELETE FROM departments
WHERE employee_list.COUNT = 0;

-- DELETE with nested table condition
DELETE FROM departments
WHERE 100 MEMBER OF employee_list;

-- DELETE with MULTISET condition
DELETE FROM departments
WHERE employee_list IS EMPTY;

-- DELETE with object type condition
DELETE FROM customers
WHERE address.city = 'Unknown';

-- DELETE with user/session functions
DELETE FROM sessions
WHERE user_id = USER;

-- DELETE with SYS_CONTEXT
DELETE FROM audit_log
WHERE session_id = SYS_CONTEXT('USERENV', 'SESSIONID');

-- DELETE with SYSDATE/SYSTIMESTAMP
DELETE FROM temp_data
WHERE created_date < SYSDATE;

-- DELETE with CURRENT_DATE/CURRENT_TIMESTAMP
DELETE FROM user_sessions
WHERE last_activity < CURRENT_TIMESTAMP - INTERVAL '30' MINUTE;

-- DELETE with hint (index)
DELETE /*+ INDEX(employees emp_dept_idx) */ FROM employees
WHERE department_id = 10;

-- DELETE with hint (full scan)
DELETE /*+ FULL(employees) */ FROM employees
WHERE status = 'INACTIVE';

-- DELETE with hint (parallel)
DELETE /*+ PARALLEL(employees, 4) */ FROM employees
WHERE processed_flag = 'Y';

-- DELETE with multiple hints
DELETE /*+ PARALLEL(logs, 4) USE_NL(logs) */ FROM logs
WHERE log_date < TRUNC(SYSDATE) - 365;

-- DELETE from partition
DELETE FROM sales PARTITION (sales_q1_2024)
WHERE sale_date < DATE '2024-04-01';

-- DELETE from subpartition
DELETE FROM sales SUBPARTITION (sales_jan_2024)
WHERE sale_date < DATE '2024-02-01';

-- DELETE with ONLY (for object tables)
DELETE FROM ONLY(person_objects)
WHERE person_id = 100;

-- DELETE with complex boolean logic
DELETE FROM employees
WHERE (department_id IN (10, 20) AND salary < 5000)
   OR (department_id IN (30, 40) AND hire_date < DATE '2010-01-01')
   OR (commission_pct IS NULL AND job_id NOT LIKE '%_MAN');

-- DELETE with nested conditions
DELETE FROM products
WHERE (category_id IN (
        SELECT category_id FROM categories WHERE active = 'N'
      )
      OR discontinued = 'Y')
  AND quantity_on_hand = 0;

-- DELETE with expression in WHERE
DELETE FROM employees
WHERE (salary * 12) + NVL(commission_pct * salary * 12, 0) < 30000;

-- DELETE with computed column comparison
DELETE FROM orders
WHERE (quantity * unit_price) - discount < minimum_order_amount;

-- DELETE with string pattern matching
DELETE FROM users
WHERE username LIKE 'test\_%' ESCAPE '\';

-- DELETE with multiple LIKE conditions
DELETE FROM products
WHERE product_name LIKE '%obsolete%'
   OR product_code LIKE 'OLD-%'
   OR description LIKE '%discontinued%';

-- DELETE with range conditions
DELETE FROM measurements
WHERE value NOT BETWEEN lower_threshold AND upper_threshold;

-- DELETE with temporal validity (12c+)
DELETE FROM employees
WHERE employee_id = 100
  AND valid_time_start < SYSTIMESTAMP;

-- DELETE with edition-based redefinition context
DELETE FROM employees
WHERE department_id = 10
  AND edition_name = SYS_CONTEXT('USERENV', 'CURRENT_EDITION_NAME');

-- DELETE old test data
DELETE FROM test_results
WHERE test_date < ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -12);

-- DELETE duplicates (using ROWID)
DELETE FROM employees e1
WHERE ROWID > (
    SELECT MIN(ROWID)
    FROM employees e2
    WHERE e1.email = e2.email
);

-- DELETE with composite condition
DELETE FROM order_items
WHERE (order_id, line_item) IN (
    SELECT order_id, line_item
    FROM cancelled_items
);

-- DELETE with qualified column names
DELETE FROM employees e
WHERE e.department_id = 10
  AND e.hire_date < DATE '2010-01-01'
  AND e.status = 'INACTIVE';
