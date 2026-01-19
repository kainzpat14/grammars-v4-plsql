-- Advanced anonymous block examples
-- Tests various PL/SQL block features that may not be fully supported

-- Anonymous block with nested blocks and labels
<<outer_block>>
DECLARE
    v_counter NUMBER := 0;
    v_total NUMBER := 0;
BEGIN
    <<inner_block>>
    DECLARE
        v_local NUMBER := 10;
    BEGIN
        v_total := v_counter + v_local;
        DBMS_OUTPUT.PUT_LINE('Inner block: ' || v_total);
    END inner_block;

    v_counter := v_counter + 1;
    DBMS_OUTPUT.PUT_LINE('Outer block: ' || v_counter);
END outer_block;
/

-- Anonymous block with bulk collect into collection
DECLARE
    TYPE emp_tab_type IS TABLE OF employees%ROWTYPE;
    l_emps emp_tab_type;
BEGIN
    SELECT * BULK COLLECT INTO l_emps
    FROM employees
    WHERE department_id = 10;

    FOR i IN 1..l_emps.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(l_emps(i).last_name);
    END LOOP;
END;
/

-- Anonymous block with FORALL and SAVE EXCEPTIONS
DECLARE
    TYPE num_tab IS TABLE OF NUMBER;
    l_ids num_tab := num_tab(1, 2, 3, 4, 5);
    l_errors NUMBER;
BEGIN
    FORALL i IN l_ids.FIRST..l_ids.LAST SAVE EXCEPTIONS
        DELETE FROM test_table WHERE id = l_ids(i);
EXCEPTION
    WHEN OTHERS THEN
        l_errors := SQL%BULK_EXCEPTIONS.COUNT;
        FOR i IN 1..l_errors LOOP
            DBMS_OUTPUT.PUT_LINE('Error ' || i || ': ' || SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
        END LOOP;
END;
/

-- Anonymous block with dynamic SQL and USING clause
DECLARE
    v_table_name VARCHAR2(30) := 'EMPLOYEES';
    v_dept_id NUMBER := 10;
    v_count NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_table_name || ' WHERE department_id = :dept'
        INTO v_count
        USING v_dept_id;
    DBMS_OUTPUT.PUT_LINE('Count: ' || v_count);
END;
/

-- Anonymous block with dynamic SQL and RETURNING clause
DECLARE
    v_sql VARCHAR2(500);
    v_new_id NUMBER;
BEGIN
    v_sql := 'INSERT INTO test_table (name) VALUES (:name) RETURNING id INTO :ret_id';
    EXECUTE IMMEDIATE v_sql
        USING 'Test Name'
        RETURNING INTO v_new_id;
    DBMS_OUTPUT.PUT_LINE('New ID: ' || v_new_id);
END;
/

-- Anonymous block with qualified expressions (18c+)
DECLARE
    TYPE rec_type IS RECORD (
        id NUMBER,
        name VARCHAR2(50)
    );
    l_rec rec_type;
BEGIN
    -- Simple qualified expression
    l_rec := rec_type(100, 'Test Name');
    DBMS_OUTPUT.PUT_LINE(l_rec.name);

    -- Alternative syntax
    l_rec := rec_type(id => 200, name => 'Another Name');
    DBMS_OUTPUT.PUT_LINE(l_rec.id);
END;
/

-- Anonymous block with associative array using qualified expression
DECLARE
    TYPE aa_type IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    l_array aa_type;
BEGIN
    l_array := aa_type(1 => 'First', 2 => 'Second', 3 => 'Third');
    FOR i IN 1..l_array.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(l_array(i));
    END LOOP;
END;
/

-- Anonymous block with CONTINUE WHEN
DECLARE
    v_total NUMBER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        CONTINUE WHEN MOD(i, 2) = 0;  -- Skip even numbers
        v_total := v_total + i;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total of odd numbers: ' || v_total);
END;
/

-- Anonymous block with conditional compilation
DECLARE
    $IF $$DEBUG_MODE $THEN
        c_debug CONSTANT BOOLEAN := TRUE;
    $ELSE
        c_debug CONSTANT BOOLEAN := FALSE;
    $END
BEGIN
    $IF $$DEBUG_MODE $THEN
        DBMS_OUTPUT.PUT_LINE('Debug mode is ON');
    $END
    NULL;
END;
/

-- Anonymous block with BOOLEAN datatype (23ai)
DECLARE
    v_is_active BOOLEAN := TRUE;
    v_is_valid BOOLEAN;
    v_result BOOLEAN;
BEGIN
    v_is_valid := FALSE;
    v_result := v_is_active AND NOT v_is_valid;

    IF v_result THEN
        DBMS_OUTPUT.PUT_LINE('Result is TRUE');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Result is FALSE');
    END IF;

    -- BOOLEAN with NULL
    v_result := NULL;
    IF v_result IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Result is NULL');
    END IF;
END;
/

-- Anonymous block with inline pragma
DECLARE
    FUNCTION slow_func(p_val NUMBER) RETURN NUMBER IS
        PRAGMA INLINE (expensive_call, 'YES');
    BEGIN
        RETURN p_val * 2;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE(slow_func(5));
END;
/

-- Anonymous block with collection operations
DECLARE
    TYPE num_list IS TABLE OF NUMBER;
    l_nums num_list := num_list(1, 2, 3, 4, 5);
BEGIN
    -- MULTISET operations
    l_nums := l_nums MULTISET UNION num_list(6, 7, 8);
    l_nums := l_nums MULTISET EXCEPT num_list(2, 4);

    FOR i IN 1..l_nums.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(l_nums(i));
    END LOOP;
END;
/

-- Anonymous block with polymorphic table function call (18c+)
DECLARE
    v_result SYS_REFCURSOR;
BEGIN
    -- Call polymorphic table function
    OPEN v_result FOR
        SELECT * FROM TABLE(my_ptf(CURSOR(SELECT * FROM employees)));
    CLOSE v_result;
END;
/

-- Anonymous block with SELECT without FROM (23ai)
DECLARE
    v_value NUMBER;
BEGIN
    SELECT 100 + 200 INTO v_value;
    DBMS_OUTPUT.PUT_LINE('Value: ' || v_value);
END;
/

-- Anonymous block with JSON operations (23ai)
DECLARE
    v_json JSON;
    v_value VARCHAR2(100);
BEGIN
    v_json := JSON('{"name": "John", "age": 30}');
    v_value := JSON_VALUE(v_json, '$.name');
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_value);
END;
/
