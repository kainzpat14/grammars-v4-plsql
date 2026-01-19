-- Bulk operations and dynamic SQL examples
-- Tests BULK COLLECT, FORALL, EXECUTE IMMEDIATE variations

-- BULK COLLECT INTO with LIMIT
DECLARE
    TYPE emp_tab IS TABLE OF employees%ROWTYPE;
    l_employees emp_tab;
    CURSOR c_emp IS SELECT * FROM employees;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp BULK COLLECT INTO l_employees LIMIT 100;
        EXIT WHEN l_employees.COUNT = 0;

        FOR i IN 1..l_employees.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(l_employees(i).last_name);
        END LOOP;
    END LOOP;
    CLOSE c_emp;
END;
/

-- FORALL with INDICES OF
DECLARE
    TYPE id_tab IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE name_tab IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;

    l_ids id_tab;
    l_names name_tab;
    l_valid_indices id_tab;
BEGIN
    -- Populate collections
    FOR i IN 1..10 LOOP
        l_ids(i) := i;
        IF MOD(i, 2) = 0 THEN
            l_names(i) := 'Name ' || i;
            l_valid_indices(i) := i;
        END IF;
    END LOOP;

    -- Update only rows corresponding to valid indices
    FORALL i IN INDICES OF l_valid_indices
        UPDATE employees
        SET last_name = l_names(i)
        WHERE employee_id = l_ids(i);
END;
/

-- FORALL with INDICES OF BETWEEN
DECLARE
    TYPE num_tab IS TABLE OF NUMBER;
    l_ids num_tab := num_tab(10, 20, 30, 40, 50, 60, 70);
BEGIN
    FORALL i IN INDICES OF l_ids BETWEEN 2 AND 5
        DELETE FROM test_table WHERE id = l_ids(i);
    DBMS_OUTPUT.PUT_LINE('Deleted ' || SQL%ROWCOUNT || ' rows');
END;
/

-- FORALL with VALUES OF
DECLARE
    TYPE id_tab IS TABLE OF NUMBER;
    TYPE index_tab IS TABLE OF PLS_INTEGER;

    l_ids id_tab := id_tab(100, 200, 300, 400, 500);
    l_indices index_tab := index_tab(1, 3, 5);  -- Process only these indices
BEGIN
    FORALL i IN VALUES OF l_indices
        UPDATE employees
        SET salary = salary * 1.1
        WHERE employee_id = l_ids(i);
END;
/

-- EXECUTE IMMEDIATE with BULK COLLECT
DECLARE
    TYPE emp_rec IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(100)
    );
    TYPE emp_tab IS TABLE OF emp_rec;
    l_emps emp_tab;
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'SELECT employee_id, first_name || '' '' || last_name FROM employees WHERE department_id = :dept';
    EXECUTE IMMEDIATE v_sql BULK COLLECT INTO l_emps USING 10;

    FOR i IN 1..l_emps.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(l_emps(i).emp_id || ': ' || l_emps(i).emp_name);
    END LOOP;
END;
/

-- EXECUTE IMMEDIATE with RETURNING BULK COLLECT
DECLARE
    TYPE id_tab IS TABLE OF NUMBER;
    l_old_ids id_tab;
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'DELETE FROM employees WHERE department_id = :dept RETURNING employee_id INTO :ret_ids';
    EXECUTE IMMEDIATE v_sql
        USING 90
        RETURNING BULK COLLECT INTO l_old_ids;

    DBMS_OUTPUT.PUT_LINE('Deleted ' || l_old_ids.COUNT || ' employees');
END;
/

-- Dynamic SQL with multiple USING clauses
DECLARE
    v_table_name VARCHAR2(30) := 'EMPLOYEES';
    v_col_name VARCHAR2(30) := 'SALARY';
    v_min_value NUMBER := 5000;
    v_max_value NUMBER := 10000;
    v_result NUMBER;
BEGIN
    EXECUTE IMMEDIATE
        'SELECT COUNT(*) FROM ' || v_table_name ||
        ' WHERE ' || v_col_name || ' BETWEEN :min AND :max'
        INTO v_result
        USING v_min_value, v_max_value;
    DBMS_OUTPUT.PUT_LINE('Count: ' || v_result);
END;
/

-- Dynamic SQL with IN OUT parameter
DECLARE
    v_sql VARCHAR2(500);
    v_value NUMBER := 100;
BEGIN
    v_sql := 'BEGIN :val := :val * 2; END;';
    EXECUTE IMMEDIATE v_sql USING IN OUT v_value;
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_value);
END;
/

-- OPEN FOR with dynamic SQL
DECLARE
    TYPE rc IS REF CURSOR;
    c_emp rc;
    v_sql VARCHAR2(1000);
    v_emp_id NUMBER;
    v_emp_name VARCHAR2(100);
BEGIN
    v_sql := 'SELECT employee_id, last_name FROM employees WHERE department_id = :dept';
    OPEN c_emp FOR v_sql USING 10;
    LOOP
        FETCH c_emp INTO v_emp_id, v_emp_name;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_emp_id || ': ' || v_emp_name);
    END LOOP;
    CLOSE c_emp;
END;
/

-- BULK COLLECT with RETURNING clause
DECLARE
    TYPE id_tab IS TABLE OF NUMBER;
    TYPE sal_tab IS TABLE OF NUMBER;
    l_ids id_tab := id_tab(100, 101, 102);
    l_old_salaries sal_tab;
BEGIN
    FORALL i IN l_ids.FIRST..l_ids.LAST
        UPDATE employees
        SET salary = salary * 1.1
        WHERE employee_id = l_ids(i)
        RETURNING salary BULK COLLECT INTO l_old_salaries;

    FOR i IN 1..l_old_salaries.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('New salary: ' || l_old_salaries(i));
    END LOOP;
END;
/

-- FORALL with complex DML
DECLARE
    TYPE emp_rec IS RECORD (
        emp_id NUMBER,
        new_salary NUMBER
    );
    TYPE emp_tab IS TABLE OF emp_rec;
    l_updates emp_tab := emp_tab(
        emp_rec(100, 50000),
        emp_rec(101, 60000),
        emp_rec(102, 55000)
    );
BEGIN
    FORALL i IN l_updates.FIRST..l_updates.LAST
        UPDATE employees
        SET salary = l_updates(i).new_salary,
            last_update_date = SYSDATE
        WHERE employee_id = l_updates(i).emp_id;
END;
/

-- EXECUTE IMMEDIATE with USING and RETURNING
DECLARE
    v_emp_id NUMBER := 100;
    v_new_salary NUMBER := 75000;
    v_old_salary NUMBER;
    v_sql VARCHAR2(500);
BEGIN
    v_sql := 'UPDATE employees SET salary = :new_sal WHERE employee_id = :emp_id RETURNING salary INTO :old_sal';
    EXECUTE IMMEDIATE v_sql
        USING v_new_salary, v_emp_id
        RETURNING INTO v_old_salary;
    DBMS_OUTPUT.PUT_LINE('Old salary: ' || v_old_salary);
END;
/

-- Bulk operations with associative arrays
DECLARE
    TYPE emp_aa IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    l_names emp_aa;
    l_indices DBMS_SQL.NUMBER_TABLE;
BEGIN
    -- Populate sparse array
    l_names(1) := 'Alice';
    l_names(5) := 'Bob';
    l_names(10) := 'Charlie';

    -- Get indices
    l_indices(1) := 1;
    l_indices(2) := 5;
    l_indices(3) := 10;

    FORALL i IN VALUES OF l_indices
        INSERT INTO test_table VALUES (i, l_names(i));
END;
/

-- Dynamic PL/SQL block execution
DECLARE
    v_plsql_block VARCHAR2(1000);
    v_result NUMBER;
BEGIN
    v_plsql_block := '
        DECLARE
            v_sum NUMBER := 0;
        BEGIN
            FOR i IN 1..10 LOOP
                v_sum := v_sum + i;
            END LOOP;
            :result := v_sum;
        END;';

    EXECUTE IMMEDIATE v_plsql_block USING OUT v_result;
    DBMS_OUTPUT.PUT_LINE('Sum: ' || v_result);
END;
/

-- DBMS_SQL for dynamic SQL with unknown column count
DECLARE
    v_cursor INTEGER;
    v_sql VARCHAR2(1000) := 'SELECT * FROM employees WHERE department_id = :dept';
    v_col_count INTEGER;
    v_dept_id NUMBER := 10;
    v_ret INTEGER;
BEGIN
    v_cursor := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(v_cursor, v_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':dept', v_dept_id);

    -- Execute and fetch
    v_ret := DBMS_SQL.EXECUTE(v_cursor);
    v_ret := DBMS_SQL.FETCH_ROWS(v_cursor);

    DBMS_SQL.CLOSE_CURSOR(v_cursor);
    DBMS_OUTPUT.PUT_LINE('Processed ' || v_ret || ' rows');
END;
/

-- BULK COLLECT with multiple INTO targets
DECLARE
    TYPE id_tab IS TABLE OF NUMBER;
    TYPE name_tab IS TABLE OF VARCHAR2(100);
    l_ids id_tab;
    l_names name_tab;
BEGIN
    SELECT employee_id, last_name
    BULK COLLECT INTO l_ids, l_names
    FROM employees
    WHERE department_id = 10;

    FOR i IN 1..l_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(l_ids(i) || ': ' || l_names(i));
    END LOOP;
END;
/

-- FORALL with INSERT using SELECT
DECLARE
    TYPE dept_tab IS TABLE OF NUMBER;
    l_depts dept_tab := dept_tab(10, 20, 30);
BEGIN
    FORALL i IN l_depts.FIRST..l_depts.LAST
        INSERT INTO dept_summary (dept_id, emp_count, avg_salary)
        SELECT l_depts(i), COUNT(*), AVG(salary)
        FROM employees
        WHERE department_id = l_depts(i);
END;
/
