-- UPDATE with RETURNING clause
-- Tests RETURNING INTO for retrieving updated values
-- Must be used in PL/SQL context

-- Basic UPDATE with RETURNING single column
DECLARE
    v_new_salary NUMBER;
BEGIN
    UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = 100
    RETURNING salary INTO v_new_salary;

    DBMS_OUTPUT.PUT_LINE('New salary: ' || v_new_salary);
END;
/

-- UPDATE with RETURNING multiple columns
DECLARE
    v_salary NUMBER;
    v_commission NUMBER;
    v_total NUMBER;
BEGIN
    UPDATE employees
    SET salary = salary * 1.1,
        commission_pct = 0.15
    WHERE employee_id = 100
    RETURNING salary, commission_pct, salary * (1 + NVL(commission_pct, 0))
    INTO v_salary, v_commission, v_total;

    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_salary);
    DBMS_OUTPUT.PUT_LINE('Commission: ' || v_commission);
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total);
END;
/

-- UPDATE with RETURNING into record
DECLARE
    TYPE emp_record IS RECORD (
        emp_id NUMBER,
        emp_salary NUMBER,
        emp_dept NUMBER
    );
    v_emp emp_record;
BEGIN
    UPDATE employees
    SET salary = 60000
    WHERE employee_id = 100
    RETURNING employee_id, salary, department_id
    INTO v_emp.emp_id, v_emp.emp_salary, v_emp.emp_dept;

    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_emp.emp_id);
END;
/

-- UPDATE with RETURNING expressions
DECLARE
    v_annual_salary NUMBER;
    v_full_name VARCHAR2(200);
BEGIN
    UPDATE employees
    SET salary = 55000
    WHERE employee_id = 100
    RETURNING salary * 12, first_name || ' ' || last_name
    INTO v_annual_salary, v_full_name;

    DBMS_OUTPUT.PUT_LINE('Annual salary for ' || v_full_name || ': ' || v_annual_salary);
END;
/

-- UPDATE with RETURNING function calls
DECLARE
    v_upper_name VARCHAR2(100);
    v_hire_year NUMBER;
BEGIN
    UPDATE employees
    SET email = LOWER(email)
    WHERE employee_id = 100
    RETURNING UPPER(first_name || ' ' || last_name), EXTRACT(YEAR FROM hire_date)
    INTO v_upper_name, v_hire_year;

    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_upper_name || ', Hired: ' || v_hire_year);
END;
/

-- UPDATE with RETURNING ROWID
DECLARE
    v_rowid ROWID;
BEGIN
    UPDATE employees
    SET salary = salary * 1.05
    WHERE employee_id = 100
    RETURNING ROWID INTO v_rowid;

    DBMS_OUTPUT.PUT_LINE('Updated row ROWID: ' || v_rowid);
END;
/

-- UPDATE multiple rows with RETURNING BULK COLLECT
DECLARE
    TYPE id_array IS TABLE OF NUMBER;
    TYPE salary_array IS TABLE OF NUMBER;
    v_ids id_array;
    v_salaries salary_array;
BEGIN
    UPDATE employees
    SET salary = salary * 1.1
    WHERE department_id = 10
    RETURNING employee_id, salary
    BULK COLLECT INTO v_ids, v_salaries;

    FOR i IN 1..v_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ' || v_ids(i) || ': ' || v_salaries(i));
    END LOOP;
END;
/

-- UPDATE with RETURNING and BULK COLLECT using %ROWTYPE
DECLARE
    TYPE emp_table IS TABLE OF employees%ROWTYPE;
    v_employees emp_table;
BEGIN
    UPDATE employees
    SET salary = salary * 1.15
    WHERE department_id = 20
    RETURNING employee_id, first_name, last_name, email, phone_number,
              hire_date, job_id, salary, commission_pct, manager_id, department_id
    BULK COLLECT INTO v_employees;

    FOR i IN 1..v_employees.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Updated: ' || v_employees(i).first_name);
    END LOOP;
END;
/

-- UPDATE with RETURNING in FORALL
DECLARE
    TYPE id_list IS TABLE OF NUMBER;
    v_emp_ids id_list := id_list(100, 101, 102, 103, 104);
    TYPE salary_list IS TABLE OF NUMBER;
    v_new_salaries salary_list;
BEGIN
    FORALL i IN v_emp_ids.FIRST..v_emp_ids.LAST
        UPDATE employees
        SET salary = salary * 1.1
        WHERE employee_id = v_emp_ids(i)
        RETURNING salary BULK COLLECT INTO v_new_salaries;

    FOR i IN 1..v_new_salaries.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('New salary: ' || v_new_salaries(i));
    END LOOP;
END;
/

-- UPDATE with RETURNING and CASE expression
DECLARE
    v_salary_grade VARCHAR2(20);
BEGIN
    UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = 100
    RETURNING CASE
        WHEN salary > 10000 THEN 'High'
        WHEN salary > 5000 THEN 'Medium'
        ELSE 'Low'
    END
    INTO v_salary_grade;

    DBMS_OUTPUT.PUT_LINE('Salary grade: ' || v_salary_grade);
END;
/

-- UPDATE with RETURNING and aggregate expression (scalar subquery context)
DECLARE
    v_pct_of_avg NUMBER;
BEGIN
    UPDATE employees
    SET salary = 65000
    WHERE employee_id = 100
    RETURNING salary / (SELECT AVG(salary) FROM employees) * 100
    INTO v_pct_of_avg;

    DBMS_OUTPUT.PUT_LINE('Percentage of average: ' || ROUND(v_pct_of_avg, 2));
END;
/

-- UPDATE with RETURNING and NVL/COALESCE
DECLARE
    v_total_comp NUMBER;
BEGIN
    UPDATE employees
    SET salary = 70000
    WHERE employee_id = 100
    RETURNING salary + NVL(commission_pct * salary, 0)
    INTO v_total_comp;

    DBMS_OUTPUT.PUT_LINE('Total compensation: ' || v_total_comp);
END;
/

-- UPDATE with RETURNING OLD values (using a copy)
DECLARE
    v_old_salary NUMBER;
    v_new_salary NUMBER;
    v_emp_id NUMBER := 100;
BEGIN
    -- Get old value first
    SELECT salary INTO v_old_salary
    FROM employees
    WHERE employee_id = v_emp_id;

    -- Update and get new value
    UPDATE employees
    SET salary = salary * 1.2
    WHERE employee_id = v_emp_id
    RETURNING salary INTO v_new_salary;

    DBMS_OUTPUT.PUT_LINE('Old: ' || v_old_salary || ', New: ' || v_new_salary);
    DBMS_OUTPUT.PUT_LINE('Increase: ' || (v_new_salary - v_old_salary));
END;
/

-- UPDATE with RETURNING date/timestamp values
DECLARE
    v_hire_date DATE;
    v_modified_ts TIMESTAMP;
BEGIN
    UPDATE employees
    SET last_modified = SYSTIMESTAMP
    WHERE employee_id = 100
    RETURNING hire_date, last_modified
    INTO v_hire_date, v_modified_ts;

    DBMS_OUTPUT.PUT_LINE('Hired: ' || v_hire_date);
    DBMS_OUTPUT.PUT_LINE('Modified: ' || v_modified_ts);
END;
/

-- UPDATE with RETURNING CLOB
DECLARE
    v_notes CLOB;
BEGIN
    UPDATE employees
    SET notes = notes || CHR(10) || 'Updated on ' || TO_CHAR(SYSDATE, 'YYYY-MM-DD')
    WHERE employee_id = 100
    RETURNING notes INTO v_notes;

    DBMS_OUTPUT.PUT_LINE('Notes length: ' || DBMS_LOB.GETLENGTH(v_notes));
END;
/

-- UPDATE with RETURNING XMLTYPE
DECLARE
    v_xml_data XMLTYPE;
BEGIN
    UPDATE xml_documents
    SET xml_data = XMLTYPE('<root><status>updated</status></root>')
    WHERE doc_id = 1
    RETURNING xml_data INTO v_xml_data;

    DBMS_OUTPUT.PUT_LINE('XML: ' || v_xml_data.GETSTRINGVAL());
END;
/

-- UPDATE with RETURNING JSON (23ai)
DECLARE
    v_json_data JSON;
BEGIN
    UPDATE products_json
    SET product_data = JSON('{"name": "Widget", "price": 29.99, "updated": true}')
    WHERE product_id = 100
    RETURNING product_data INTO v_json_data;

    DBMS_OUTPUT.PUT_LINE('JSON: ' || v_json_data.TO_STRING);
END;
/

-- UPDATE with RETURNING BOOLEAN (23ai)
DECLARE
    v_is_active BOOLEAN;
BEGIN
    UPDATE feature_flags
    SET is_enabled = TRUE
    WHERE flag_id = 1
    RETURNING is_enabled INTO v_is_active;

    IF v_is_active THEN
        DBMS_OUTPUT.PUT_LINE('Flag is now active');
    END IF;
END;
/

-- UPDATE with RETURNING object type
DECLARE
    v_address address_type;
BEGIN
    UPDATE customers
    SET address = address_type('123 Main St', 'New York', 'NY', '10001')
    WHERE customer_id = 100
    RETURNING address INTO v_address;

    DBMS_OUTPUT.PUT_LINE('City: ' || v_address.city);
END;
/

-- UPDATE with RETURNING nested table
DECLARE
    TYPE phone_list IS TABLE OF VARCHAR2(20);
    v_phones phone_list;
BEGIN
    UPDATE customers
    SET phone_numbers = phone_list('555-1234', '555-5678')
    WHERE customer_id = 100
    RETURNING phone_numbers INTO v_phones;

    FOR i IN 1..v_phones.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Phone: ' || v_phones(i));
    END LOOP;
END;
/

-- UPDATE with RETURNING varray
DECLARE
    TYPE score_array IS VARRAY(10) OF NUMBER;
    v_scores score_array;
BEGIN
    UPDATE students
    SET test_scores = score_array(85, 90, 92, 88)
    WHERE student_id = 100
    RETURNING test_scores INTO v_scores;

    FOR i IN 1..v_scores.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Score ' || i || ': ' || v_scores(i));
    END LOOP;
END;
/

-- UPDATE with RETURNING computed collection
DECLARE
    TYPE name_list IS TABLE OF VARCHAR2(100);
    v_names name_list;
BEGIN
    UPDATE departments
    SET employee_names = (
        SELECT CAST(COLLECT(first_name || ' ' || last_name) AS name_list)
        FROM employees
        WHERE department_id = departments.department_id
    )
    WHERE department_id = 10
    RETURNING employee_names INTO v_names;

    FOR i IN 1..v_names.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Employee: ' || v_names(i));
    END LOOP;
END;
/

-- UPDATE with RETURNING in exception handler
DECLARE
    v_new_salary NUMBER;
    e_update_failed EXCEPTION;
BEGIN
    UPDATE employees
    SET salary = 80000
    WHERE employee_id = 100
    RETURNING salary INTO v_new_salary;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_update_failed;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Updated salary: ' || v_new_salary);
EXCEPTION
    WHEN e_update_failed THEN
        DBMS_OUTPUT.PUT_LINE('No rows updated');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- UPDATE with RETURNING and immediate use of value
DECLARE
    v_new_salary NUMBER;
BEGIN
    UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = 100
    RETURNING salary INTO v_new_salary;

    -- Use returned value immediately in another operation
    INSERT INTO salary_history (employee_id, salary, change_date)
    VALUES (100, v_new_salary, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Salary updated and logged: ' || v_new_salary);
END;
/

-- UPDATE with RETURNING multiple rows and processing
DECLARE
    TYPE emp_rec IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(100),
        emp_salary NUMBER
    );
    TYPE emp_table IS TABLE OF emp_rec;
    v_updated_emps emp_table;
BEGIN
    UPDATE employees
    SET salary = salary * 1.1
    WHERE department_id = 10
    RETURNING employee_id, first_name || ' ' || last_name, salary
    BULK COLLECT INTO v_updated_emps;

    DBMS_OUTPUT.PUT_LINE('Updated ' || v_updated_emps.COUNT || ' employees:');
    FOR i IN 1..v_updated_emps.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || v_updated_emps(i).emp_id ||
            ', Name: ' || v_updated_emps(i).emp_name ||
            ', Salary: ' || v_updated_emps(i).emp_salary
        );
    END LOOP;
END;
/

-- UPDATE with RETURNING and cursor variable
DECLARE
    TYPE refcur IS REF CURSOR;
    v_cur refcur;
    v_emp_id NUMBER;
    v_salary NUMBER;
    TYPE id_array IS TABLE OF NUMBER;
    TYPE sal_array IS TABLE OF NUMBER;
    v_ids id_array;
    v_salaries sal_array;
BEGIN
    UPDATE employees
    SET salary = salary * 1.15
    WHERE department_id = 20
    RETURNING employee_id, salary
    BULK COLLECT INTO v_ids, v_salaries;

    -- Process the returned data
    FOR i IN 1..v_ids.COUNT LOOP
        IF v_salaries(i) > 10000 THEN
            INSERT INTO high_earners (employee_id, salary)
            VALUES (v_ids(i), v_salaries(i));
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Processed ' || v_ids.COUNT || ' updates');
END;
/

-- UPDATE with RETURNING and complex expression
DECLARE
    v_comp_info VARCHAR2(500);
BEGIN
    UPDATE employees
    SET salary = 75000, commission_pct = 0.15
    WHERE employee_id = 100
    RETURNING 'Employee ' || employee_id || ': Base=' || salary ||
              ', Commission=' || (salary * commission_pct) ||
              ', Total=' || (salary * (1 + NVL(commission_pct, 0)))
    INTO v_comp_info;

    DBMS_OUTPUT.PUT_LINE(v_comp_info);
END;
/

-- UPDATE with RETURNING LIMIT clause (FORALL)
DECLARE
    TYPE id_list IS TABLE OF NUMBER;
    v_ids id_list := id_list(100, 101, 102);
    TYPE salary_list IS TABLE OF NUMBER;
    v_salaries salary_list;
    v_total NUMBER := 0;
BEGIN
    FORALL i IN v_ids.FIRST..v_ids.LAST
        UPDATE employees
        SET salary = salary * 1.1
        WHERE employee_id = v_ids(i)
        RETURNING salary BULK COLLECT INTO v_salaries;

    FOR i IN 1..v_salaries.COUNT LOOP
        v_total := v_total + v_salaries(i);
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Total new salaries: ' || v_total);
END;
/

-- UPDATE with RETURNING and DML error logging
DECLARE
    TYPE id_array IS TABLE OF NUMBER;
    v_updated_ids id_array;
BEGIN
    UPDATE employees
    SET salary = salary * 1.1
    WHERE department_id = 10
      AND salary IS NOT NULL
    RETURNING employee_id
    BULK COLLECT INTO v_updated_ids;

    DBMS_OUTPUT.PUT_LINE('Successfully updated ' || v_updated_ids.COUNT || ' rows');

    FOR i IN 1..v_updated_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Updated employee_id: ' || v_updated_ids(i));
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error during update: ' || SQLERRM);
        ROLLBACK;
END;
/
