-- CREATE TRIGGER statement variations
-- Tests CREATE TRIGGER with various types and options

-- Basic BEFORE INSERT trigger
CREATE OR REPLACE TRIGGER emp_before_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :NEW.created_date := SYSDATE;
    :NEW.created_by := USER;
END;
/

-- AFTER INSERT trigger
CREATE OR REPLACE TRIGGER emp_after_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (table_name, action, action_date)
    VALUES ('EMPLOYEES', 'INSERT', SYSDATE);
END;
/

-- BEFORE UPDATE trigger
CREATE OR REPLACE TRIGGER emp_before_update
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    :NEW.last_modified := SYSDATE;
    :NEW.modified_by := USER;
END;
/

-- AFTER UPDATE trigger
CREATE OR REPLACE TRIGGER emp_after_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_changes (employee_id, old_salary, new_salary, change_date)
    VALUES (:OLD.employee_id, :OLD.salary, :NEW.salary, SYSDATE);
END;
/

-- BEFORE DELETE trigger
CREATE OR REPLACE TRIGGER emp_before_delete
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    IF :OLD.status = 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot delete active employee');
    END IF;
END;
/

-- AFTER DELETE trigger
CREATE OR REPLACE TRIGGER emp_after_delete
AFTER DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO deleted_employees (employee_id, deleted_date, deleted_by)
    VALUES (:OLD.employee_id, SYSDATE, USER);
END;
/

-- BEFORE INSERT OR UPDATE trigger
CREATE OR REPLACE TRIGGER emp_before_ins_upd
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    :NEW.last_modified := SYSDATE;
END;
/

-- AFTER INSERT OR UPDATE OR DELETE trigger
CREATE OR REPLACE TRIGGER emp_audit_trigger
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO audit_log VALUES ('INSERT', SYSDATE);
    ELSIF UPDATING THEN
        INSERT INTO audit_log VALUES ('UPDATE', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO audit_log VALUES ('DELETE', SYSDATE);
    END IF;
END;
/

-- Statement-level trigger (no FOR EACH ROW)
CREATE OR REPLACE TRIGGER emp_statement_trigger
AFTER INSERT ON employees
BEGIN
    DBMS_OUTPUT.PUT_LINE('Rows inserted into employees table');
END;
/

-- BEFORE statement trigger
CREATE OR REPLACE TRIGGER emp_before_stmt
BEFORE INSERT ON employees
BEGIN
    -- Check business rules before any inserts
    IF TO_CHAR(SYSDATE, 'D') IN ('1', '7') THEN
        RAISE_APPLICATION_ERROR(-20002, 'No inserts allowed on weekends');
    END IF;
END;
/

-- AFTER statement trigger
CREATE OR REPLACE TRIGGER emp_after_stmt
AFTER UPDATE ON employees
BEGIN
    -- Refresh materialized view after updates
    DBMS_MVIEW.REFRESH('EMP_SUMMARY_MV');
END;
/

-- Trigger with WHEN clause
CREATE OR REPLACE TRIGGER emp_salary_check
BEFORE UPDATE OF salary ON employees
FOR EACH ROW
WHEN (NEW.salary > OLD.salary * 1.5)
BEGIN
    RAISE_APPLICATION_ERROR(-20003, 'Salary increase exceeds 50%');
END;
/

-- Trigger with complex WHEN clause
CREATE OR REPLACE TRIGGER emp_complex_when
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary > 10000 AND OLD.status = 'PROBATION')
BEGIN
    :NEW.status := 'PERMANENT';
END;
/

-- Trigger with UPDATE OF specific columns
CREATE OR REPLACE TRIGGER emp_salary_dept_update
AFTER UPDATE OF salary, department_id ON employees
FOR EACH ROW
BEGIN
    INSERT INTO sensitive_changes (employee_id, changed_date)
    VALUES (:NEW.employee_id, SYSDATE);
END;
/

-- INSTEAD OF trigger (for views)
CREATE OR REPLACE TRIGGER emp_view_instead_of_insert
INSTEAD OF INSERT ON emp_dept_view
FOR EACH ROW
BEGIN
    INSERT INTO employees (employee_id, first_name, last_name, department_id)
    VALUES (:NEW.employee_id, :NEW.first_name, :NEW.last_name, :NEW.department_id);
END;
/

-- INSTEAD OF UPDATE trigger on view
CREATE OR REPLACE TRIGGER emp_view_instead_of_update
INSTEAD OF UPDATE ON emp_dept_view
FOR EACH ROW
BEGIN
    UPDATE employees
    SET first_name = :NEW.first_name,
        last_name = :NEW.last_name,
        department_id = :NEW.department_id
    WHERE employee_id = :OLD.employee_id;
END;
/

-- INSTEAD OF DELETE trigger on view
CREATE OR REPLACE TRIGGER emp_view_instead_of_delete
INSTEAD OF DELETE ON emp_dept_view
FOR EACH ROW
BEGIN
    DELETE FROM employees WHERE employee_id = :OLD.employee_id;
END;
/

-- Compound trigger (11g+)
CREATE OR REPLACE TRIGGER emp_compound_trigger
FOR INSERT OR UPDATE OR DELETE ON employees
COMPOUND TRIGGER

    -- Global variables
    TYPE t_emp_ids IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    g_emp_ids t_emp_ids;
    g_index PLS_INTEGER := 0;

    -- BEFORE STATEMENT
    BEFORE STATEMENT IS
    BEGIN
        g_index := 0;
        g_emp_ids.DELETE;
    END BEFORE STATEMENT;

    -- BEFORE EACH ROW
    BEFORE EACH ROW IS
    BEGIN
        IF INSERTING OR UPDATING THEN
            :NEW.last_modified := SYSDATE;
        END IF;
    END BEFORE EACH ROW;

    -- AFTER EACH ROW
    AFTER EACH ROW IS
    BEGIN
        g_index := g_index + 1;
        IF INSERTING OR UPDATING THEN
            g_emp_ids(g_index) := :NEW.employee_id;
        ELSE
            g_emp_ids(g_index) := :OLD.employee_id;
        END IF;
    END AFTER EACH ROW;

    -- AFTER STATEMENT
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1..g_index LOOP
            -- Process collected employee IDs
            NULL;
        END LOOP;
    END AFTER STATEMENT;

END emp_compound_trigger;
/

-- Trigger with REFERENCING clause
CREATE OR REPLACE TRIGGER emp_with_referencing
BEFORE UPDATE ON employees
REFERENCING OLD AS old_values NEW AS new_values
FOR EACH ROW
BEGIN
    IF :new_values.salary < :old_values.salary THEN
        RAISE_APPLICATION_ERROR(-20004, 'Salary cannot be decreased');
    END IF;
END;
/

-- Trigger with FOLLOWS clause (11g+)
CREATE OR REPLACE TRIGGER emp_trigger_a
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :NEW.created_date := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER emp_trigger_b
BEFORE INSERT ON employees
FOR EACH ROW
FOLLOWS emp_trigger_a
BEGIN
    :NEW.created_by := USER;
END;
/

-- Trigger with PRECEDES clause (11g+)
CREATE OR REPLACE TRIGGER emp_trigger_c
BEFORE INSERT ON employees
FOR EACH ROW
PRECEDES emp_trigger_a
BEGIN
    -- This executes before emp_trigger_a
    NULL;
END;
/

-- Trigger with ENABLE/DISABLE
CREATE OR REPLACE TRIGGER emp_disabled_trigger
BEFORE INSERT ON employees
FOR EACH ROW
DISABLE
BEGIN
    NULL;
END;
/

-- Trigger on nested table column
CREATE OR REPLACE TRIGGER dept_nested_table_trigger
BEFORE UPDATE OF employee_list ON departments
FOR EACH ROW
BEGIN
    :NEW.last_updated := SYSDATE;
END;
/

-- Trigger with PRAGMA AUTONOMOUS_TRANSACTION
CREATE OR REPLACE TRIGGER emp_autonomous_trigger
AFTER INSERT ON employees
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO audit_log (action, action_date)
    VALUES ('Employee inserted', SYSDATE);
    COMMIT;  -- Independent transaction
END;
/

-- Trigger with exception handling
CREATE OR REPLACE TRIGGER emp_exception_handling
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
    BEGIN
        -- Validate email format
        IF :NEW.email NOT LIKE '%@%.%' THEN
            RAISE_APPLICATION_ERROR(-20005, 'Invalid email format');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error and re-raise
            INSERT INTO error_log (error_message, error_date)
            VALUES (SQLERRM, SYSDATE);
            RAISE;
    END;
END;
/

-- Trigger with WHEN OTHERS exception
CREATE OR REPLACE TRIGGER emp_catch_all
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    -- Some processing
    NULL;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Trigger calling procedure
CREATE OR REPLACE TRIGGER emp_call_procedure
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    log_employee_change(:OLD.employee_id, :NEW.employee_id);
END;
/

-- Trigger calling function
CREATE OR REPLACE TRIGGER emp_call_function
BEFORE INSERT ON employees
FOR EACH ROW
DECLARE
    v_result NUMBER;
BEGIN
    v_result := validate_employee(:NEW.employee_id, :NEW.department_id);
    IF v_result = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Employee validation failed');
    END IF;
END;
/

-- Trigger with SELECT INTO
CREATE OR REPLACE TRIGGER emp_select_into
BEFORE INSERT ON employees
FOR EACH ROW
DECLARE
    v_dept_name VARCHAR2(100);
BEGIN
    SELECT department_name INTO v_dept_name
    FROM departments
    WHERE department_id = :NEW.department_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 'Invalid department ID');
END;
/

-- Trigger with cursor
CREATE OR REPLACE TRIGGER emp_with_cursor
AFTER INSERT ON employees
FOR EACH ROW
DECLARE
    CURSOR c_manager IS
        SELECT manager_id FROM departments
        WHERE department_id = :NEW.department_id;
    v_manager_id NUMBER;
BEGIN
    OPEN c_manager;
    FETCH c_manager INTO v_manager_id;
    CLOSE c_manager;

    :NEW.manager_id := v_manager_id;
END;
/

-- Trigger with FOR loop
CREATE OR REPLACE TRIGGER emp_for_loop
AFTER UPDATE ON departments
FOR EACH ROW
BEGIN
    FOR emp_rec IN (
        SELECT employee_id FROM employees
        WHERE department_id = :OLD.department_id
    ) LOOP
        UPDATE employees
        SET department_id = :NEW.department_id
        WHERE employee_id = emp_rec.employee_id;
    END LOOP;
END;
/

-- Trigger with IF-THEN-ELSE
CREATE OR REPLACE TRIGGER emp_conditional
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary > :OLD.salary THEN
        :NEW.last_raise_date := SYSDATE;
    ELSIF :NEW.salary < :OLD.salary THEN
        :NEW.last_decrease_date := SYSDATE;
    END IF;
END;
/

-- Trigger with CASE statement
CREATE OR REPLACE TRIGGER emp_case_stmt
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    CASE :NEW.job_id
        WHEN 'IT_PROG' THEN
            :NEW.department_id := 60;
        WHEN 'SA_REP' THEN
            :NEW.department_id := 80;
        ELSE
            :NEW.department_id := 10;
    END CASE;
END;
/

-- Trigger with BULK COLLECT
CREATE OR REPLACE TRIGGER emp_bulk_collect
AFTER UPDATE ON departments
FOR EACH ROW
DECLARE
    TYPE t_emp_ids IS TABLE OF NUMBER;
    v_emp_ids t_emp_ids;
BEGIN
    SELECT employee_id
    BULK COLLECT INTO v_emp_ids
    FROM employees
    WHERE department_id = :OLD.department_id;

    FOR i IN 1..v_emp_ids.COUNT LOOP
        NULL; -- Process each employee
    END LOOP;
END;
/

-- Trigger with FORALL
CREATE OR REPLACE TRIGGER emp_forall
AFTER INSERT ON employees
FOR EACH ROW
DECLARE
    TYPE t_numbers IS TABLE OF NUMBER;
    v_ids t_numbers := t_numbers(:NEW.employee_id);
BEGIN
    FORALL i IN v_ids.FIRST..v_ids.LAST
        UPDATE employee_stats
        SET insert_count = insert_count + 1
        WHERE employee_id = v_ids(i);
END;
/

-- Trigger with dynamic SQL
CREATE OR REPLACE TRIGGER emp_dynamic_sql
AFTER UPDATE ON employees
FOR EACH ROW
DECLARE
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'INSERT INTO audit_' || TO_CHAR(SYSDATE, 'YYYY') ||
             ' VALUES (:1, :2)';
    EXECUTE IMMEDIATE v_sql USING :NEW.employee_id, SYSDATE;
END;
/

-- Trigger with DBMS packages
CREATE OR REPLACE TRIGGER emp_dbms_output
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Inserted employee: ' || :NEW.first_name);
    DBMS_APPLICATION_INFO.SET_MODULE('HR', 'Employee Insert');
END;
/

-- Trigger with UTL_MAIL (requires configuration)
CREATE OR REPLACE TRIGGER emp_send_notification
AFTER INSERT ON employees
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    UTL_MAIL.SEND(
        sender => 'hr@company.com',
        recipients => 'manager@company.com',
        subject => 'New Employee',
        message => 'New employee hired: ' || :NEW.first_name || ' ' || :NEW.last_name
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Ignore email errors
END;
/

-- Trigger accessing ROWID
CREATE OR REPLACE TRIGGER emp_rowid_access
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_rowids (employee_id, row_id)
    VALUES (:NEW.employee_id, :NEW.ROWID);
END;
/

-- Trigger with user/session info
CREATE OR REPLACE TRIGGER emp_session_info
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :NEW.created_by := SYS_CONTEXT('USERENV', 'SESSION_USER');
    :NEW.session_id := SYS_CONTEXT('USERENV', 'SESSIONID');
    :NEW.ip_address := SYS_CONTEXT('USERENV', 'IP_ADDRESS');
END;
/

-- Trigger on system event (DDL trigger)
CREATE OR REPLACE TRIGGER ddl_audit_trigger
AFTER CREATE ON SCHEMA
BEGIN
    INSERT INTO ddl_audit_log (
        event_type,
        object_type,
        object_name,
        event_date,
        username
    ) VALUES (
        SYS.SYSEVENT,
        SYS.DICTIONARY_OBJ_TYPE,
        SYS.DICTIONARY_OBJ_NAME,
        SYSDATE,
        USER
    );
END;
/

-- Trigger on DROP
CREATE OR REPLACE TRIGGER ddl_drop_trigger
BEFORE DROP ON SCHEMA
BEGIN
    IF SYS.DICTIONARY_OBJ_TYPE = 'TABLE' THEN
        RAISE_APPLICATION_ERROR(-20008, 'Cannot drop tables in production');
    END IF;
END;
/

-- Trigger on ALTER
CREATE OR REPLACE TRIGGER ddl_alter_trigger
AFTER ALTER ON SCHEMA
BEGIN
    INSERT INTO schema_changes (
        object_name,
        object_type,
        change_date
    ) VALUES (
        SYS.DICTIONARY_OBJ_NAME,
        SYS.DICTIONARY_OBJ_TYPE,
        SYSDATE
    );
END;
/

-- Database-level trigger (STARTUP/SHUTDOWN)
CREATE OR REPLACE TRIGGER db_startup_trigger
AFTER STARTUP ON DATABASE
BEGIN
    INSERT INTO db_events (event_type, event_date)
    VALUES ('STARTUP', SYSDATE);
    COMMIT;
END;
/

-- Logon trigger
CREATE OR REPLACE TRIGGER logon_audit_trigger
AFTER LOGON ON SCHEMA
BEGIN
    INSERT INTO logon_audit (
        username,
        logon_time,
        ip_address
    ) VALUES (
        USER,
        SYSDATE,
        SYS_CONTEXT('USERENV', 'IP_ADDRESS')
    );
    COMMIT;
END;
/

-- Logoff trigger
CREATE OR REPLACE TRIGGER logoff_audit_trigger
BEFORE LOGOFF ON SCHEMA
BEGIN
    INSERT INTO logoff_audit (
        username,
        logoff_time
    ) VALUES (
        USER,
        SYSDATE
    );
    COMMIT;
END;
/

-- SERVERERROR trigger
CREATE OR REPLACE TRIGGER error_logging_trigger
AFTER SERVERERROR ON SCHEMA
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_sql_text ORA_NAME_LIST_T;
    v_sql VARCHAR2(4000);
BEGIN
    FOR i IN 1..ORA_SERVER_ERROR_DEPTH LOOP
        INSERT INTO error_log (
            error_code,
            error_message,
            event_date
        ) VALUES (
            ORA_SERVER_ERROR(i),
            ORA_SERVER_ERROR_MSG(i),
            SYSDATE
        );
    END LOOP;
    COMMIT;
END;
/

-- Trigger with collection type
CREATE OR REPLACE TRIGGER emp_collection_type
BEFORE INSERT ON employees
FOR EACH ROW
DECLARE
    TYPE t_dept_list IS TABLE OF NUMBER;
    v_valid_depts t_dept_list := t_dept_list(10, 20, 30, 40, 50);
BEGIN
    IF :NEW.department_id NOT MEMBER OF v_valid_depts THEN
        RAISE_APPLICATION_ERROR(-20009, 'Invalid department');
    END IF;
END;
/

-- Trigger with record type
CREATE OR REPLACE TRIGGER emp_record_type
AFTER UPDATE ON employees
FOR EACH ROW
DECLARE
    TYPE t_emp_rec IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(200),
        emp_salary NUMBER
    );
    v_emp t_emp_rec;
BEGIN
    v_emp.emp_id := :NEW.employee_id;
    v_emp.emp_name := :NEW.first_name || ' ' || :NEW.last_name;
    v_emp.emp_salary := :NEW.salary;
    -- Process record
END;
/

-- Trigger with BOOLEAN (23ai)
CREATE OR REPLACE TRIGGER emp_boolean_trigger
BEFORE INSERT ON employees
FOR EACH ROW
DECLARE
    v_is_valid BOOLEAN := TRUE;
BEGIN
    IF :NEW.email IS NULL THEN
        v_is_valid := FALSE;
    END IF;

    IF NOT v_is_valid THEN
        RAISE_APPLICATION_ERROR(-20010, 'Employee validation failed');
    END IF;
END;
/

-- Trigger on TRUNCATE (12c+)
CREATE OR REPLACE TRIGGER emp_truncate_trigger
BEFORE TRUNCATE ON employees
BEGIN
    RAISE_APPLICATION_ERROR(-20011, 'TRUNCATE not allowed on employees table');
END;
/

-- Crossedition trigger (11g R2+)
CREATE OR REPLACE CROSSEDITION TRIGGER emp_crossedition
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :NEW.created_date := SYSDATE;
END;
/

-- Forward crossedition trigger
CREATE OR REPLACE FORWARD CROSSEDITION TRIGGER emp_forward_crossedition
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Handle changes during edition transition
    NULL;
END;
/

-- Reverse crossedition trigger
CREATE OR REPLACE REVERSE CROSSEDITION TRIGGER emp_reverse_crossedition
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    -- Handle reverse edition changes
    NULL;
END;
/
