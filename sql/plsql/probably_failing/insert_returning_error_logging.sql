-- INSERT with RETURNING and error logging clauses
-- Tests RETURNING INTO and LOG ERRORS

-- INSERT with RETURNING single value (must be in PL/SQL block)
DECLARE
    v_new_id NUMBER;
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name)
    VALUES (emp_seq.NEXTVAL, 'John', 'Doe')
    RETURNING employee_id INTO v_new_id;

    DBMS_OUTPUT.PUT_LINE('New employee ID: ' || v_new_id);
END;
/

-- INSERT with RETURNING multiple columns
DECLARE
    v_emp_id NUMBER;
    v_hire_date DATE;
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, hire_date)
    VALUES (emp_seq.NEXTVAL, 'Jane', 'Smith', SYSDATE)
    RETURNING employee_id, hire_date INTO v_emp_id, v_hire_date;

    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_emp_id || ', Hire Date: ' || v_hire_date);
END;
/

-- INSERT with RETURNING and expressions
DECLARE
    v_annual_salary NUMBER;
BEGIN
    INSERT INTO employees (employee_id, first_name, salary)
    VALUES (emp_seq.NEXTVAL, 'Bob', 5000)
    RETURNING salary * 12 INTO v_annual_salary;

    DBMS_OUTPUT.PUT_LINE('Annual salary: ' || v_annual_salary);
END;
/

-- INSERT with RETURNING and computed values
DECLARE
    v_full_name VARCHAR2(200);
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name)
    VALUES (emp_seq.NEXTVAL, 'Alice', 'Johnson')
    RETURNING first_name || ' ' || last_name INTO v_full_name;

    DBMS_OUTPUT.PUT_LINE('Full name: ' || v_full_name);
END;
/

-- INSERT with RETURNING multiple rows using BULK COLLECT
DECLARE
    TYPE id_array IS TABLE OF NUMBER;
    TYPE name_array IS TABLE OF VARCHAR2(100);
    v_ids id_array;
    v_names name_array;
BEGIN
    FORALL i IN 1..10
        INSERT INTO employees (employee_id, first_name)
        VALUES (emp_seq.NEXTVAL, 'Employee' || i)
        RETURNING employee_id, first_name
        BULK COLLECT INTO v_ids, v_names;

    FOR i IN 1..v_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_ids(i) || ', Name: ' || v_names(i));
    END LOOP;
END;
/

-- INSERT with RETURNING ROWID
DECLARE
    v_rowid ROWID;
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name)
    VALUES (emp_seq.NEXTVAL, 'Charlie', 'Brown')
    RETURNING ROWID INTO v_rowid;

    DBMS_OUTPUT.PUT_LINE('New row ROWID: ' || v_rowid);
END;
/

-- INSERT with LOG ERRORS clause (10g+)
-- Logs constraint violations to error logging table
INSERT INTO employees (employee_id, first_name, last_name, email)
SELECT employee_id, first_name, last_name, email
FROM employee_staging
LOG ERRORS REJECT LIMIT UNLIMITED;

-- INSERT with LOG ERRORS and specific error table
INSERT INTO employees (employee_id, first_name, last_name)
SELECT employee_id, first_name, last_name
FROM employee_staging
LOG ERRORS INTO emp_error_log REJECT LIMIT 100;

-- INSERT with LOG ERRORS and error tag
INSERT INTO employees (employee_id, first_name, last_name, email)
SELECT employee_id, first_name, last_name, email
FROM employee_staging
LOG ERRORS INTO emp_error_log ('Import_2024_01') REJECT LIMIT UNLIMITED;

-- INSERT with LOG ERRORS and limited rejections
INSERT INTO departments (department_id, department_name)
SELECT department_id, department_name
FROM department_staging
LOG ERRORS REJECT LIMIT 50;

-- INSERT with LOG ERRORS and no reject limit
INSERT INTO products (product_id, product_name, price)
SELECT product_id, product_name, price
FROM product_staging
LOG ERRORS REJECT LIMIT UNLIMITED;

-- INSERT with LOG ERRORS - numeric reject limit
INSERT INTO orders (order_id, customer_id, order_date)
SELECT order_id, customer_id, order_date
FROM order_staging
LOG ERRORS REJECT LIMIT 1000;

-- Complex INSERT with both RETURNING and in PL/SQL context
DECLARE
    TYPE emp_record IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(200),
        emp_salary NUMBER
    );
    TYPE emp_table IS TABLE OF emp_record;
    v_new_employees emp_table;
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, salary)
    SELECT emp_seq.NEXTVAL, first_name, last_name, salary
    FROM employee_staging
    WHERE department_id = 50
    RETURNING employee_id, first_name || ' ' || last_name, salary
    BULK COLLECT INTO v_new_employees;

    FOR i IN 1..v_new_employees.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Added: ' || v_new_employees(i).emp_name);
    END LOOP;
END;
/

-- INSERT with RETURNING and sequence
DECLARE
    v_new_dept_id NUMBER;
BEGIN
    INSERT INTO departments (department_id, department_name)
    VALUES (dept_seq.NEXTVAL, 'New Department')
    RETURNING department_id INTO v_new_dept_id;

    -- Use the returned ID immediately
    INSERT INTO department_metadata (department_id, created_date)
    VALUES (v_new_dept_id, SYSDATE);
END;
/

-- INSERT with RETURNING and default values
DECLARE
    v_status VARCHAR2(20);
    v_created_date DATE;
BEGIN
    INSERT INTO tasks (task_id, task_name, status, created_date)
    VALUES (task_seq.NEXTVAL, 'New Task', DEFAULT, DEFAULT)
    RETURNING status, created_date INTO v_status, v_created_date;

    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status || ', Created: ' || v_created_date);
END;
/

-- INSERT with LOG ERRORS in complex SELECT
INSERT INTO employee_summary (employee_id, full_name, dept_name, annual_salary)
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name,
       d.department_name,
       e.salary * 12
FROM employee_staging e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.hire_date >= ADD_MONTHS(SYSDATE, -12)
LOG ERRORS INTO emp_summary_errors ('Batch_2024_Q1') REJECT LIMIT 500;

-- INSERT with RETURNING in FORALL statement
DECLARE
    TYPE id_list IS TABLE OF NUMBER;
    v_source_ids id_list := id_list(1, 2, 3, 4, 5);
    v_new_ids id_list;
BEGIN
    FORALL i IN v_source_ids.FIRST..v_source_ids.LAST
        INSERT INTO target_table (id, source_id, created_date)
        VALUES (target_seq.NEXTVAL, v_source_ids(i), SYSDATE)
        RETURNING id BULK COLLECT INTO v_new_ids;

    DBMS_OUTPUT.PUT_LINE('Inserted ' || v_new_ids.COUNT || ' rows');
END;
/

-- INSERT with RETURNING %ROWTYPE
DECLARE
    v_new_employee employees%ROWTYPE;
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, email, hire_date)
    VALUES (emp_seq.NEXTVAL, 'David', 'Wilson', 'dwilson@example.com', SYSDATE)
    RETURNING employee_id, first_name, last_name, email, hire_date, salary,
              commission_pct, manager_id, department_id, job_id
    INTO v_new_employee.employee_id, v_new_employee.first_name, v_new_employee.last_name,
         v_new_employee.email, v_new_employee.hire_date, v_new_employee.salary,
         v_new_employee.commission_pct, v_new_employee.manager_id,
         v_new_employee.department_id, v_new_employee.job_id;

    DBMS_OUTPUT.PUT_LINE('New employee: ' || v_new_employee.first_name);
END;
/

-- INSERT with LOG ERRORS and WHERE clause
INSERT INTO products (product_id, product_name, category_id, price)
SELECT product_id, product_name, category_id, price
FROM product_staging ps
WHERE EXISTS (SELECT 1 FROM categories c WHERE c.category_id = ps.category_id)
  AND price > 0
LOG ERRORS REJECT LIMIT UNLIMITED;

-- INSERT with LOG ERRORS and JOIN
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, price)
SELECT order_item_seq.NEXTVAL, oi.order_id, oi.product_id, oi.quantity, p.price
FROM order_items_staging oi
JOIN products p ON oi.product_id = p.product_id
WHERE oi.quantity > 0
LOG ERRORS INTO order_item_errors REJECT LIMIT 1000;

-- INSERT with RETURNING and trigger-generated values
DECLARE
    v_generated_code VARCHAR2(50);
BEGIN
    -- Assuming trigger generates a code
    INSERT INTO products (product_id, product_name)
    VALUES (product_seq.NEXTVAL, 'New Product')
    RETURNING product_code INTO v_generated_code;

    DBMS_OUTPUT.PUT_LINE('Generated product code: ' || v_generated_code);
END;
/

-- INSERT with RETURNING and JSON/XML data (12c+)
DECLARE
    v_json_data CLOB;
BEGIN
    INSERT INTO documents (doc_id, title, content)
    VALUES (doc_seq.NEXTVAL, 'Report', 'Document content here')
    RETURNING JSON_OBJECT(
        'id' VALUE doc_id,
        'title' VALUE title,
        'content' VALUE content
    ) INTO v_json_data;

    DBMS_OUTPUT.PUT_LINE('JSON: ' || v_json_data);
END;
/

-- INSERT with LOG ERRORS - monitoring error table
-- Query the error logging table after insert
INSERT INTO employees (employee_id, first_name, last_name, email)
SELECT employee_id, first_name, last_name, email
FROM employee_staging
LOG ERRORS INTO emp_error_log ('Batch_XYZ') REJECT LIMIT UNLIMITED;

-- Check errors
SELECT ora_err_number$, ora_err_mesg$, employee_id, email
FROM emp_error_log
WHERE ora_err_tag$ = 'Batch_XYZ';

-- INSERT with RETURNING and conditional INSERT (multi-table)
DECLARE
    TYPE id_array IS TABLE OF NUMBER;
    v_high_earner_ids id_array;
BEGIN
    -- Note: RETURNING with multi-table INSERT has limitations
    INSERT ALL
        WHEN salary > 10000 THEN
            INTO high_earners VALUES (employee_id, first_name, salary)
    SELECT employee_id, first_name, salary
    FROM employee_staging;

    -- Retrieve the IDs in a separate query
    SELECT employee_id BULK COLLECT INTO v_high_earner_ids
    FROM high_earners
    WHERE created_date >= SYSDATE - INTERVAL '1' SECOND;
END;
/

-- INSERT with error logging and large batch
INSERT /*+ APPEND */ INTO employees_archive
SELECT * FROM employees
WHERE hire_date < ADD_MONTHS(SYSDATE, -120)
LOG ERRORS REJECT LIMIT UNLIMITED;

-- INSERT with RETURNING and BOOLEAN (23ai)
DECLARE
    v_is_active BOOLEAN;
BEGIN
    INSERT INTO accounts (account_id, account_name, is_active)
    VALUES (account_seq.NEXTVAL, 'New Account', TRUE)
    RETURNING is_active INTO v_is_active;

    IF v_is_active THEN
        DBMS_OUTPUT.PUT_LINE('Account is active');
    END IF;
END;
/

-- INSERT with LOG ERRORS and complex constraints
INSERT INTO project_assignments (assignment_id, project_id, employee_id, start_date, end_date)
SELECT assignment_seq.NEXTVAL, project_id, employee_id, start_date, end_date
FROM project_staging ps
WHERE start_date < end_date
  AND EXISTS (SELECT 1 FROM projects p WHERE p.project_id = ps.project_id)
  AND EXISTS (SELECT 1 FROM employees e WHERE e.employee_id = ps.employee_id)
LOG ERRORS INTO assignment_errors ('Import_Q1_2024') REJECT LIMIT 100;
