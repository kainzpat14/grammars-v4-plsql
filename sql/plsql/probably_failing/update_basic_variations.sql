-- UPDATE statement basic variations
-- Tests basic UPDATE syntax with various clauses and expressions

-- Basic UPDATE with WHERE clause
UPDATE employees
SET salary = 50000
WHERE employee_id = 100;

-- UPDATE multiple columns
UPDATE employees
SET salary = 60000,
    commission_pct = 0.15,
    job_id = 'SA_REP'
WHERE employee_id = 100;

-- UPDATE with arithmetic expressions
UPDATE employees
SET salary = salary * 1.1
WHERE department_id = 10;

-- UPDATE with concatenation
UPDATE employees
SET email = first_name || '.' || last_name || '@company.com'
WHERE email IS NULL;

-- UPDATE with CASE expression
UPDATE employees
SET salary = CASE
    WHEN job_id = 'IT_PROG' THEN salary * 1.15
    WHEN job_id = 'SA_REP' THEN salary * 1.10
    ELSE salary * 1.05
END
WHERE department_id IN (60, 80);

-- UPDATE with function calls
UPDATE employees
SET hire_date = TRUNC(hire_date),
    first_name = INITCAP(first_name),
    email = UPPER(email)
WHERE department_id = 20;

-- UPDATE with date arithmetic
UPDATE employees
SET hire_date = hire_date + 7
WHERE hire_date < DATE '2005-01-01';

-- UPDATE with NULL
UPDATE employees
SET commission_pct = NULL
WHERE job_id NOT IN ('SA_REP', 'SA_MAN');

-- UPDATE with DEFAULT keyword
UPDATE employees
SET salary = DEFAULT,
    commission_pct = DEFAULT
WHERE employee_id = 100;

-- UPDATE with SYSDATE/SYSTIMESTAMP
UPDATE employees
SET last_modified = SYSDATE
WHERE employee_id = 100;

-- UPDATE with complex WHERE clause
UPDATE employees
SET salary = salary * 1.1
WHERE department_id = 10
  AND hire_date < ADD_MONTHS(SYSDATE, -24)
  AND salary < 10000;

-- UPDATE with IN clause
UPDATE employees
SET department_id = 50
WHERE employee_id IN (100, 101, 102, 103);

-- UPDATE with BETWEEN
UPDATE employees
SET salary = salary * 1.05
WHERE salary BETWEEN 5000 AND 10000;

-- UPDATE with LIKE
UPDATE employees
SET email = LOWER(email)
WHERE email LIKE '%EXAMPLE.COM';

-- UPDATE with IS NULL/IS NOT NULL
UPDATE employees
SET commission_pct = 0
WHERE commission_pct IS NULL AND job_id = 'SA_REP';

-- UPDATE with multiple conditions (AND/OR)
UPDATE employees
SET bonus = salary * 0.1
WHERE (department_id = 80 OR job_id = 'SA_REP')
  AND salary > 8000;

-- UPDATE with NOT operator
UPDATE employees
SET active_flag = 'N'
WHERE NOT (hire_date >= ADD_MONTHS(SYSDATE, -12));

-- UPDATE all rows (no WHERE clause)
UPDATE employees
SET last_updated = SYSDATE;

-- UPDATE with column reference in SET
UPDATE employees
SET salary = salary + (salary * commission_pct)
WHERE commission_pct IS NOT NULL;

-- UPDATE with multiple table references (Oracle syntax)
UPDATE employees e
SET e.salary = 70000
WHERE e.employee_id = 100;

-- UPDATE with ROWNUM
UPDATE employees
SET processed_flag = 'Y'
WHERE ROWNUM <= 10;

-- UPDATE with ROWID (pseudo-column)
UPDATE employees
SET salary = 55000
WHERE ROWID = 'AAAA5nAABAAAVFqAAA';

-- UPDATE with string functions
UPDATE employees
SET first_name = SUBSTR(first_name, 1, 20),
    last_name = SUBSTR(last_name, 1, 25)
WHERE LENGTH(first_name) > 20 OR LENGTH(last_name) > 25;

-- UPDATE with numeric functions
UPDATE employees
SET salary = ROUND(salary, -2),
    commission_pct = ROUND(commission_pct, 2)
WHERE commission_pct IS NOT NULL;

-- UPDATE with date functions
UPDATE employees
SET hire_date = LAST_DAY(hire_date)
WHERE EXTRACT(DAY FROM hire_date) > 28;

-- UPDATE with conversion functions
UPDATE employees
SET employee_id_str = TO_CHAR(employee_id),
    hire_date = TO_DATE(hire_date_str, 'YYYY-MM-DD')
WHERE hire_date_str IS NOT NULL;

-- UPDATE with NVL/NVL2
UPDATE employees
SET commission_pct = NVL(commission_pct, 0),
    bonus = NVL2(commission_pct, salary * 0.1, 0)
WHERE job_id = 'SA_REP';

-- UPDATE with COALESCE
UPDATE employees
SET phone_number = COALESCE(phone_number, mobile_number, home_number, 'N/A')
WHERE phone_number IS NULL;

-- UPDATE with DECODE
UPDATE employees
SET salary_grade = DECODE(
    TRUNC(salary/10000),
    0, 'A',
    1, 'B',
    2, 'C',
    'D'
)
WHERE salary_grade IS NULL;

-- UPDATE with NULLIF
UPDATE employees
SET commission_pct = NULLIF(commission_pct, 0)
WHERE commission_pct IS NOT NULL;

-- UPDATE with GREATEST/LEAST
UPDATE employees
SET salary = GREATEST(salary, min_salary)
WHERE salary < min_salary;

-- UPDATE with interval arithmetic
UPDATE projects
SET end_date = start_date + INTERVAL '30' DAY
WHERE end_date IS NULL;

-- UPDATE with TIMESTAMP arithmetic
UPDATE events
SET event_timestamp = event_timestamp + INTERVAL '2' HOUR
WHERE timezone = 'PST';

-- UPDATE with EXTRACT
UPDATE employees
SET birth_year = EXTRACT(YEAR FROM birth_date)
WHERE birth_year IS NULL;

-- UPDATE with nested functions
UPDATE employees
SET full_name = UPPER(TRIM(first_name || ' ' || last_name))
WHERE full_name IS NULL;

-- UPDATE with mathematical operations
UPDATE products
SET price = ROUND(cost * 1.3, 2),
    discount = FLOOR(price * 0.1)
WHERE active = 'Y';

-- UPDATE with CLOB
UPDATE documents
SET content = content || CHR(10) || 'Additional text'
WHERE doc_type = 'TEXT';

-- UPDATE with BLOB (using EMPTY_BLOB)
UPDATE images
SET image_data = EMPTY_BLOB()
WHERE image_id = 100;

-- UPDATE with XMLTYPE
UPDATE xml_documents
SET xml_data = XMLTYPE('<root><element>value</element></root>')
WHERE doc_id = 1;

-- UPDATE with JSON (23ai)
UPDATE products_json
SET product_data = JSON('{"name": "Widget", "price": 19.99}')
WHERE product_id = 100;

-- UPDATE JSON field (23ai JSON dot notation)
UPDATE products_json
SET product_data.price = 24.99
WHERE product_id = 100;

-- UPDATE with VECTOR datatype (23ai)
UPDATE documents_vector
SET embedding = TO_VECTOR('[1.0, 2.0, 3.0]')
WHERE doc_id = 1;

-- UPDATE with BOOLEAN datatype (23ai)
UPDATE feature_flags
SET is_enabled = TRUE
WHERE flag_name = 'NEW_FEATURE';

-- UPDATE with boolean expression (23ai)
UPDATE tasks
SET is_completed = (status = 'DONE')
WHERE task_id = 100;

-- UPDATE with multiple CASE expressions
UPDATE employees
SET salary = CASE
        WHEN job_id LIKE 'IT_%' THEN salary * 1.15
        WHEN job_id LIKE 'SA_%' THEN salary * 1.12
        ELSE salary * 1.08
    END,
    bonus_pct = CASE
        WHEN salary > 10000 THEN 0.15
        WHEN salary > 5000 THEN 0.10
        ELSE 0.05
    END
WHERE active = 'Y';

-- UPDATE with searched CASE in WHERE
UPDATE employees
SET promotion_eligible = 'Y'
WHERE CASE
    WHEN hire_date < ADD_MONTHS(SYSDATE, -24) AND salary < 8000 THEN 1
    WHEN hire_date < ADD_MONTHS(SYSDATE, -36) THEN 1
    ELSE 0
END = 1;

-- UPDATE with simple CASE expression
UPDATE employees
SET status = CASE department_id
    WHEN 10 THEN 'ADMIN'
    WHEN 20 THEN 'HR'
    WHEN 30 THEN 'IT'
    ELSE 'OTHER'
END;

-- UPDATE with aggregate in scalar subquery (WHERE clause)
UPDATE employees
SET salary = salary * 1.1
WHERE salary < (SELECT AVG(salary) FROM employees);

-- UPDATE with user/system functions
UPDATE audit_log
SET modified_by = USER,
    modified_date = SYSDATE,
    session_id = SYS_CONTEXT('USERENV', 'SESSIONID')
WHERE log_id = 1000;

-- UPDATE with regular expression
UPDATE employees
SET phone_number = REGEXP_REPLACE(phone_number, '[^0-9]', '')
WHERE phone_number IS NOT NULL;

-- UPDATE with TRANSLATE
UPDATE employees
SET ssn = TRANSLATE(ssn, '0123456789', 'XXXXXXXXXX')
WHERE mask_sensitive = 'Y';

-- UPDATE with TRIM variations
UPDATE employees
SET first_name = TRIM(LEADING ' ' FROM first_name),
    last_name = TRIM(TRAILING ' ' FROM last_name),
    middle_name = TRIM(BOTH ' ' FROM middle_name)
WHERE employee_id = 100;

-- UPDATE with REPLACE
UPDATE employees
SET email = REPLACE(email, 'oldcompany.com', 'newcompany.com')
WHERE email LIKE '%oldcompany.com';

-- UPDATE with LPAD/RPAD
UPDATE employees
SET employee_code = LPAD(TO_CHAR(employee_id), 10, '0')
WHERE employee_code IS NULL;

-- UPDATE with INSTR
UPDATE employees
SET domain = SUBSTR(email, INSTR(email, '@') + 1)
WHERE email IS NOT NULL;

-- UPDATE with complex expression
UPDATE employees
SET annual_salary = (salary * 12) + NVL(commission_pct * salary * 12, 0),
    effective_date = ADD_MONTHS(TRUNC(SYSDATE, 'MM'), 1)
WHERE active = 'Y';

-- UPDATE with TO_NUMBER
UPDATE employees
SET salary = TO_NUMBER(salary_string)
WHERE salary_string IS NOT NULL;

-- UPDATE with TO_DATE
UPDATE employees
SET hire_date = TO_DATE(hire_date_string, 'MM/DD/YYYY')
WHERE hire_date_string IS NOT NULL;

-- UPDATE with TO_TIMESTAMP
UPDATE events
SET event_time = TO_TIMESTAMP(event_time_string, 'YYYY-MM-DD HH24:MI:SS.FF')
WHERE event_time_string IS NOT NULL;

-- UPDATE with TO_CLOB
UPDATE documents
SET large_text = TO_CLOB(text_content)
WHERE doc_id = 100;

-- UPDATE with CAST
UPDATE employees
SET salary_decimal = CAST(salary AS NUMBER(10,2)),
    hire_date_ts = CAST(hire_date AS TIMESTAMP)
WHERE employee_id = 100;

-- UPDATE with TREAT (object types)
UPDATE shape_table
SET area = TREAT(shape_data AS rectangle_type).calculate_area()
WHERE shape_type = 'RECTANGLE';

-- UPDATE with member method call (object types)
UPDATE person_objects
SET full_name = person_data.get_full_name()
WHERE person_id = 100;

-- UPDATE with nested table column
UPDATE departments
SET employee_list = employee_list MULTISET UNION employee_array_type(100, 101)
WHERE department_id = 10;

-- UPDATE with collection method
UPDATE departments
SET emp_count = employee_list.COUNT
WHERE department_id = 10;

-- UPDATE with hint
UPDATE /*+ INDEX(employees emp_dept_idx) */ employees
SET salary = salary * 1.05
WHERE department_id = 10;

-- UPDATE with parallel hint
UPDATE /*+ PARALLEL(employees, 4) */ employees
SET processed = 'Y'
WHERE status = 'PENDING';

-- UPDATE with NO_INDEX hint
UPDATE /*+ NO_INDEX(employees emp_name_idx) */ employees
SET status = 'ACTIVE'
WHERE first_name = 'John';

-- UPDATE with multiple hints
UPDATE /*+ PARALLEL(employees, 4) USE_HASH(employees) */ employees
SET last_processed = SYSDATE
WHERE department_id IN (10, 20, 30);
