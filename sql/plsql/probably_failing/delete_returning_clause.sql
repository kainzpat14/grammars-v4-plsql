-- DELETE with RETURNING clause
-- Tests RETURNING INTO for retrieving deleted values
-- Must be used in PL/SQL context

-- Basic DELETE with RETURNING single column
DECLARE
    v_deleted_salary NUMBER;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING salary INTO v_deleted_salary;

    DBMS_OUTPUT.PUT_LINE('Deleted employee with salary: ' || v_deleted_salary);
END;
/

-- DELETE with RETURNING multiple columns
DECLARE
    v_emp_id NUMBER;
    v_name VARCHAR2(100);
    v_salary NUMBER;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING employee_id, first_name || ' ' || last_name, salary
    INTO v_emp_id, v_name, v_salary;

    DBMS_OUTPUT.PUT_LINE('Deleted: ' || v_name || ' (ID: ' || v_emp_id || ', Salary: ' || v_salary || ')');
END;
/

-- DELETE with RETURNING into record
DECLARE
    TYPE emp_record IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(200),
        emp_salary NUMBER
    );
    v_emp emp_record;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING employee_id, first_name || ' ' || last_name, salary
    INTO v_emp.emp_id, v_emp.emp_name, v_emp.emp_salary;

    DBMS_OUTPUT.PUT_LINE('Deleted employee: ' || v_emp.emp_name);
END;
/

-- DELETE with RETURNING expressions
DECLARE
    v_annual_salary NUMBER;
    v_years_employed NUMBER;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING salary * 12, TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12)
    INTO v_annual_salary, v_years_employed;

    DBMS_OUTPUT.PUT_LINE('Annual salary: ' || v_annual_salary);
    DBMS_OUTPUT.PUT_LINE('Years employed: ' || v_years_employed);
END;
/

-- DELETE with RETURNING function calls
DECLARE
    v_upper_name VARCHAR2(100);
    v_dept_name VARCHAR2(100);
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING UPPER(first_name || ' ' || last_name),
              (SELECT department_name FROM departments d WHERE d.department_id = employees.department_id)
    INTO v_upper_name, v_dept_name;

    DBMS_OUTPUT.PUT_LINE('Deleted: ' || v_upper_name || ' from ' || v_dept_name);
END;
/

-- DELETE with RETURNING ROWID
DECLARE
    v_rowid ROWID;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING ROWID INTO v_rowid;

    DBMS_OUTPUT.PUT_LINE('Deleted row ROWID: ' || v_rowid);
END;
/

-- DELETE multiple rows with RETURNING BULK COLLECT
DECLARE
    TYPE id_array IS TABLE OF NUMBER;
    TYPE name_array IS TABLE OF VARCHAR2(200);
    v_ids id_array;
    v_names name_array;
BEGIN
    DELETE FROM employees
    WHERE department_id = 10
    RETURNING employee_id, first_name || ' ' || last_name
    BULK COLLECT INTO v_ids, v_names;

    DBMS_OUTPUT.PUT_LINE('Deleted ' || v_ids.COUNT || ' employees:');
    FOR i IN 1..v_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || v_ids(i) || ': ' || v_names(i));
    END LOOP;
END;
/

-- DELETE with RETURNING and BULK COLLECT using %ROWTYPE
DECLARE
    TYPE emp_table IS TABLE OF employees%ROWTYPE;
    v_deleted_employees emp_table;
BEGIN
    DELETE FROM employees
    WHERE department_id = 20
    RETURNING employee_id, first_name, last_name, email, phone_number,
              hire_date, job_id, salary, commission_pct, manager_id, department_id
    BULK COLLECT INTO v_deleted_employees;

    DBMS_OUTPUT.PUT_LINE('Deleted ' || v_deleted_employees.COUNT || ' employees');
    FOR i IN 1..v_deleted_employees.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Deleted: ' || v_deleted_employees(i).first_name || ' ' ||
                            v_deleted_employees(i).last_name);
    END LOOP;
END;
/

-- DELETE with RETURNING in FORALL
DECLARE
    TYPE id_list IS TABLE OF NUMBER;
    v_emp_ids id_list := id_list(100, 101, 102, 103);
    TYPE salary_list IS TABLE OF NUMBER;
    v_deleted_salaries salary_list;
BEGIN
    FORALL i IN v_emp_ids.FIRST..v_emp_ids.LAST
        DELETE FROM employees
        WHERE employee_id = v_emp_ids(i)
        RETURNING salary BULK COLLECT INTO v_deleted_salaries;

    FOR i IN 1..v_deleted_salaries.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Deleted employee with salary: ' || v_deleted_salaries(i));
    END LOOP;
END;
/

-- DELETE with RETURNING and CASE expression
DECLARE
    v_salary_grade VARCHAR2(20);
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING CASE
        WHEN salary > 10000 THEN 'High'
        WHEN salary > 5000 THEN 'Medium'
        ELSE 'Low'
    END
    INTO v_salary_grade;

    DBMS_OUTPUT.PUT_LINE('Deleted employee from salary grade: ' || v_salary_grade);
END;
/

-- DELETE with RETURNING and NVL/COALESCE
DECLARE
    v_total_comp NUMBER;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING salary + NVL(commission_pct * salary, 0)
    INTO v_total_comp;

    DBMS_OUTPUT.PUT_LINE('Total compensation of deleted employee: ' || v_total_comp);
END;
/

-- DELETE with RETURNING for audit purposes
DECLARE
    TYPE audit_rec IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(200),
        salary NUMBER,
        dept_id NUMBER,
        deleted_by VARCHAR2(50),
        deleted_at TIMESTAMP
    );
    v_audit audit_rec;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING employee_id, first_name || ' ' || last_name, salary, department_id,
              USER, SYSTIMESTAMP
    INTO v_audit.emp_id, v_audit.emp_name, v_audit.salary, v_audit.dept_id,
         v_audit.deleted_by, v_audit.deleted_at;

    -- Insert audit record
    INSERT INTO employee_deletions (employee_id, employee_name, salary, department_id,
                                    deleted_by, deleted_at)
    VALUES (v_audit.emp_id, v_audit.emp_name, v_audit.salary, v_audit.dept_id,
            v_audit.deleted_by, v_audit.deleted_at);

    DBMS_OUTPUT.PUT_LINE('Deleted and audited: ' || v_audit.emp_name);
END;
/

-- DELETE with RETURNING date/timestamp values
DECLARE
    v_hire_date DATE;
    v_term_date DATE := SYSDATE;
    v_tenure_days NUMBER;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING hire_date, TRUNC(SYSDATE - hire_date)
    INTO v_hire_date, v_tenure_days;

    DBMS_OUTPUT.PUT_LINE('Employee hired: ' || v_hire_date);
    DBMS_OUTPUT.PUT_LINE('Days employed: ' || v_tenure_days);
END;
/

-- DELETE with RETURNING CLOB
DECLARE
    v_notes CLOB;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING notes INTO v_notes;

    DBMS_OUTPUT.PUT_LINE('Deleted employee notes length: ' || DBMS_LOB.GETLENGTH(v_notes));

    -- Archive the notes
    INSERT INTO archived_employee_notes (employee_id, notes, archived_date)
    VALUES (100, v_notes, SYSDATE);
END;
/

-- DELETE with RETURNING XMLTYPE
DECLARE
    v_xml_data XMLTYPE;
BEGIN
    DELETE FROM xml_documents
    WHERE doc_id = 1
    RETURNING xml_data INTO v_xml_data;

    DBMS_OUTPUT.PUT_LINE('Deleted XML: ' || v_xml_data.GETSTRINGVAL());
END;
/

-- DELETE with RETURNING JSON (23ai)
DECLARE
    v_json_data JSON;
BEGIN
    DELETE FROM products_json
    WHERE product_id = 100
    RETURNING product_data INTO v_json_data;

    DBMS_OUTPUT.PUT_LINE('Deleted product JSON: ' || v_json_data.TO_STRING);
END;
/

-- DELETE with RETURNING BOOLEAN (23ai)
DECLARE
    v_was_enabled BOOLEAN;
BEGIN
    DELETE FROM feature_flags
    WHERE flag_id = 1
    RETURNING is_enabled INTO v_was_enabled;

    IF v_was_enabled THEN
        DBMS_OUTPUT.PUT_LINE('Deleted flag was enabled');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Deleted flag was disabled');
    END IF;
END;
/

-- DELETE with RETURNING object type
DECLARE
    v_address address_type;
BEGIN
    DELETE FROM customers
    WHERE customer_id = 100
    RETURNING address INTO v_address;

    DBMS_OUTPUT.PUT_LINE('Deleted customer from: ' || v_address.city || ', ' || v_address.state);
END;
/

-- DELETE with RETURNING nested table
DECLARE
    TYPE phone_list IS TABLE OF VARCHAR2(20);
    v_phones phone_list;
BEGIN
    DELETE FROM customers
    WHERE customer_id = 100
    RETURNING phone_numbers INTO v_phones;

    DBMS_OUTPUT.PUT_LINE('Deleted customer had ' || v_phones.COUNT || ' phone numbers');
END;
/

-- DELETE with RETURNING varray
DECLARE
    TYPE score_array IS VARRAY(10) OF NUMBER;
    v_scores score_array;
    v_average NUMBER := 0;
BEGIN
    DELETE FROM students
    WHERE student_id = 100
    RETURNING test_scores INTO v_scores;

    FOR i IN 1..v_scores.COUNT LOOP
        v_average := v_average + v_scores(i);
    END LOOP;
    v_average := v_average / v_scores.COUNT;

    DBMS_OUTPUT.PUT_LINE('Deleted student had average score: ' || ROUND(v_average, 2));
END;
/

-- DELETE with RETURNING in exception handler
DECLARE
    v_emp_name VARCHAR2(200);
    e_no_employee EXCEPTION;
BEGIN
    DELETE FROM employees
    WHERE employee_id = 999999
    RETURNING first_name || ' ' || last_name INTO v_emp_name;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE e_no_employee;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Deleted: ' || v_emp_name);
EXCEPTION
    WHEN e_no_employee THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- DELETE with RETURNING and immediate archival
DECLARE
    TYPE emp_rec IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(200),
        salary NUMBER,
        hire_date DATE
    );
    TYPE emp_table IS TABLE OF emp_rec;
    v_deleted_emps emp_table;
BEGIN
    DELETE FROM employees
    WHERE department_id = 10
    RETURNING employee_id, first_name || ' ' || last_name, salary, hire_date
    BULK COLLECT INTO v_deleted_emps;

    -- Archive the deleted employees
    FORALL i IN 1..v_deleted_emps.COUNT
        INSERT INTO archived_employees (employee_id, employee_name, salary, hire_date, archived_date)
        VALUES (v_deleted_emps(i).emp_id, v_deleted_emps(i).emp_name,
                v_deleted_emps(i).salary, v_deleted_emps(i).hire_date, SYSDATE);

    DBMS_OUTPUT.PUT_LINE('Deleted and archived ' || v_deleted_emps.COUNT || ' employees');
END;
/

-- DELETE with RETURNING multiple rows and statistical processing
DECLARE
    TYPE salary_list IS TABLE OF NUMBER;
    v_salaries salary_list;
    v_total NUMBER := 0;
    v_avg NUMBER;
    v_max NUMBER;
    v_min NUMBER;
BEGIN
    DELETE FROM employees
    WHERE department_id = 20
    RETURNING salary BULK COLLECT INTO v_salaries;

    IF v_salaries.COUNT > 0 THEN
        FOR i IN 1..v_salaries.COUNT LOOP
            v_total := v_total + v_salaries(i);
        END LOOP;

        v_avg := v_total / v_salaries.COUNT;
        v_max := v_salaries(1);
        v_min := v_salaries(1);

        FOR i IN 1..v_salaries.COUNT LOOP
            IF v_salaries(i) > v_max THEN v_max := v_salaries(i); END IF;
            IF v_salaries(i) < v_min THEN v_min := v_salaries(i); END IF;
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Deleted ' || v_salaries.COUNT || ' employees');
        DBMS_OUTPUT.PUT_LINE('Total salary: ' || v_total);
        DBMS_OUTPUT.PUT_LINE('Average salary: ' || ROUND(v_avg, 2));
        DBMS_OUTPUT.PUT_LINE('Max salary: ' || v_max);
        DBMS_OUTPUT.PUT_LINE('Min salary: ' || v_min);
    END IF;
END;
/

-- DELETE with RETURNING and complex expression
DECLARE
    v_summary VARCHAR2(500);
BEGIN
    DELETE FROM employees
    WHERE employee_id = 100
    RETURNING 'Employee ' || employee_id || ' (' || first_name || ' ' || last_name || ')' ||
              ' - Salary: ' || TO_CHAR(salary, '$999,999.99') ||
              ', Hired: ' || TO_CHAR(hire_date, 'YYYY-MM-DD') ||
              ', Tenure: ' || TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12) || ' years'
    INTO v_summary;

    DBMS_OUTPUT.PUT_LINE(v_summary);
END;
/

-- DELETE with RETURNING LIMIT clause (using FORALL)
DECLARE
    TYPE id_list IS TABLE OF NUMBER;
    v_ids id_list := id_list(100, 101, 102, 103, 104);
    TYPE name_list IS TABLE OF VARCHAR2(200);
    v_names name_list;
    v_count NUMBER := 0;
BEGIN
    FORALL i IN v_ids.FIRST..v_ids.LAST
        DELETE FROM employees
        WHERE employee_id = v_ids(i)
        RETURNING first_name || ' ' || last_name BULK COLLECT INTO v_names;

    DBMS_OUTPUT.PUT_LINE('Deleted ' || v_names.COUNT || ' employees:');
    FOR i IN 1..v_names.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || v_names(i));
    END LOOP;
END;
/

-- DELETE with RETURNING and SQL%BULK_ROWCOUNT
DECLARE
    TYPE id_list IS TABLE OF NUMBER;
    v_ids id_list := id_list(100, 101, 102, 103, 104);
BEGIN
    FORALL i IN v_ids.FIRST..v_ids.LAST
        DELETE FROM employees
        WHERE employee_id = v_ids(i);

    FOR i IN v_ids.FIRST..v_ids.LAST LOOP
        IF SQL%BULK_ROWCOUNT(i) > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Deleted employee_id: ' || v_ids(i));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Employee_id not found: ' || v_ids(i));
        END IF;
    END LOOP;
END;
/

-- DELETE with RETURNING and cursor variable processing
DECLARE
    TYPE emp_rec IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(200),
        dept_id NUMBER,
        salary NUMBER
    );
    TYPE emp_table IS TABLE OF emp_rec;
    v_deleted_emps emp_table;
BEGIN
    DELETE FROM employees
    WHERE status = 'TERMINATED'
    RETURNING employee_id, first_name || ' ' || last_name, department_id, salary
    BULK COLLECT INTO v_deleted_emps;

    -- Process deleted employees
    FOR i IN 1..v_deleted_emps.COUNT LOOP
        -- Log to audit table
        INSERT INTO employee_audit_log (
            action, employee_id, employee_name, department_id,
            salary, action_date, action_by
        ) VALUES (
            'DELETE', v_deleted_emps(i).emp_id, v_deleted_emps(i).emp_name,
            v_deleted_emps(i).dept_id, v_deleted_emps(i).salary,
            SYSDATE, USER
        );

        -- Update department statistics
        UPDATE department_stats
        SET employee_count = employee_count - 1,
            total_salary = total_salary - v_deleted_emps(i).salary
        WHERE department_id = v_deleted_emps(i).dept_id;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Processed ' || v_deleted_emps.COUNT || ' deletions');
END;
/

-- DELETE with RETURNING and conditional processing
DECLARE
    TYPE emp_rec IS RECORD (
        emp_id NUMBER,
        salary NUMBER,
        commission NUMBER
    );
    TYPE emp_table IS TABLE OF emp_rec;
    v_deleted_emps emp_table;
    v_high_earners NUMBER := 0;
    v_total_cost NUMBER := 0;
BEGIN
    DELETE FROM employees
    WHERE department_id = 30
    RETURNING employee_id, salary, NVL(commission_pct, 0) * salary
    BULK COLLECT INTO v_deleted_emps;

    FOR i IN 1..v_deleted_emps.COUNT LOOP
        v_total_cost := v_total_cost + v_deleted_emps(i).salary + v_deleted_emps(i).commission;

        IF v_deleted_emps(i).salary > 10000 THEN
            v_high_earners := v_high_earners + 1;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Deleted ' || v_deleted_emps.COUNT || ' employees');
    DBMS_OUTPUT.PUT_LINE('High earners deleted: ' || v_high_earners);
    DBMS_OUTPUT.PUT_LINE('Total cost savings: $' || TO_CHAR(v_total_cost, '999,999,999.99'));
END;
/

-- DELETE with RETURNING for soft delete pattern
DECLARE
    TYPE id_array IS TABLE OF NUMBER;
    v_deleted_ids id_array;
BEGIN
    -- "Delete" by moving to archive table
    DELETE FROM employees
    WHERE last_activity_date < ADD_MONTHS(SYSDATE, -24)
    RETURNING employee_id BULK COLLECT INTO v_deleted_ids;

    -- Could insert into archive table here using v_deleted_ids
    DBMS_OUTPUT.PUT_LINE('Soft deleted ' || v_deleted_ids.COUNT || ' inactive employees');

    FOR i IN 1..v_deleted_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('  Employee ID: ' || v_deleted_ids(i));
    END LOOP;
END;
/
