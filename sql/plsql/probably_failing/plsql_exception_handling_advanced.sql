-- Advanced exception handling examples
-- Tests various exception handling features

-- User-defined exceptions with PRAGMA EXCEPTION_INIT
DECLARE
    e_custom_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_custom_error, -20001);
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Custom error message');
EXCEPTION
    WHEN e_custom_error THEN
        DBMS_OUTPUT.PUT_LINE('Caught custom error');
END;
/

-- Multiple exception handlers
DECLARE
    v_value NUMBER;
BEGIN
    SELECT salary INTO v_value
    FROM employees
    WHERE employee_id = 999999;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Too many rows');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Value error');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Other error: ' || SQLERRM);
        RAISE;  -- Re-raise the exception
END;
/

-- EXCEPTION_INIT with multiple exceptions
DECLARE
    e_parent_key_not_found EXCEPTION;
    e_child_record_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_parent_key_not_found, -2291);
    PRAGMA EXCEPTION_INIT(e_child_record_found, -2292);
BEGIN
    DELETE FROM parent_table WHERE id = 1;
EXCEPTION
    WHEN e_parent_key_not_found THEN
        DBMS_OUTPUT.PUT_LINE('Parent key not found');
    WHEN e_child_record_found THEN
        DBMS_OUTPUT.PUT_LINE('Child records exist');
END;
/

-- Exception with GOTO
DECLARE
    v_error_occurred BOOLEAN := FALSE;
BEGIN
    BEGIN
        -- Some operation that might fail
        SELECT 1/0 INTO v_error_occurred FROM DUAL;
    EXCEPTION
        WHEN ZERO_DIVIDE THEN
            v_error_occurred := TRUE;
            GOTO error_handler;
    END;

    DBMS_OUTPUT.PUT_LINE('No error occurred');
    RETURN;

    <<error_handler>>
    DBMS_OUTPUT.PUT_LINE('Error handled via GOTO');
END;
/

-- Nested exception handling
DECLARE
    v_outer NUMBER;
BEGIN
    BEGIN
        v_outer := 100;
        BEGIN
            v_outer := v_outer / 0;
        EXCEPTION
            WHEN ZERO_DIVIDE THEN
                DBMS_OUTPUT.PUT_LINE('Inner exception handler');
                RAISE;  -- Re-raise to outer handler
        END;
    EXCEPTION
        WHEN ZERO_DIVIDE THEN
            DBMS_OUTPUT.PUT_LINE('Outer exception handler');
    END;
END;
/

-- Exception handler with DML operations
DECLARE
    v_count NUMBER;
BEGIN
    INSERT INTO test_table VALUES (1, 'Test');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        UPDATE test_table SET value = 'Updated' WHERE id = 1;
        v_count := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('Updated ' || v_count || ' rows');
END;
/

-- FORALL with SQL%BULK_EXCEPTIONS
DECLARE
    TYPE id_tab IS TABLE OF NUMBER;
    l_ids id_tab := id_tab(1, 2, 3, 4, 5);
    l_dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(l_dml_errors, -24381);
BEGIN
    FORALL i IN l_ids.FIRST..l_ids.LAST SAVE EXCEPTIONS
        INSERT INTO test_table VALUES (l_ids(i), 'Value ' || l_ids(i));
EXCEPTION
    WHEN l_dml_errors THEN
        FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Error ' || i || ': Index = ' ||
                SQL%BULK_EXCEPTIONS(i).ERROR_INDEX ||
                ', Code = ' || SQL%BULK_EXCEPTIONS(i).ERROR_CODE ||
                ', Message = ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
        END LOOP;
END;
/

-- Exception with SQLCODE and SQLERRM
DECLARE
    v_error_code NUMBER;
    v_error_message VARCHAR2(4000);
BEGIN
    SELECT salary INTO v_error_code
    FROM employees
    WHERE 1=2;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        v_error_code := SQLCODE;
        v_error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('Error code: ' || v_error_code);
        DBMS_OUTPUT.PUT_LINE('Error message: ' || v_error_message);
        -- Log to error table
        INSERT INTO error_log (error_code, error_message, error_timestamp)
        VALUES (v_error_code, v_error_message, SYSTIMESTAMP);
END;
/

-- RAISE without exception name (re-raise current exception)
DECLARE
    v_attempts NUMBER := 0;
    c_max_attempts CONSTANT NUMBER := 3;
BEGIN
    LOOP
        BEGIN
            v_attempts := v_attempts + 1;
            -- Simulated operation that might fail
            IF v_attempts < c_max_attempts THEN
                RAISE NO_DATA_FOUND;
            END IF;
            EXIT;  -- Success
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                IF v_attempts >= c_max_attempts THEN
                    DBMS_OUTPUT.PUT_LINE('Max attempts reached');
                    RAISE;  -- Re-raise after max attempts
                ELSE
                    DBMS_OUTPUT.PUT_LINE('Retry attempt ' || v_attempts);
                END IF;
        END;
    END LOOP;
END;
/

-- Custom exception with RAISE_APPLICATION_ERROR
DECLARE
    c_invalid_salary CONSTANT NUMBER := -20100;
    v_salary NUMBER := -1000;
BEGIN
    IF v_salary < 0 THEN
        RAISE_APPLICATION_ERROR(c_invalid_salary,
            'Salary cannot be negative: ' || v_salary,
            TRUE);  -- Keep error stack
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error stack: ' || DBMS_UTILITY.FORMAT_ERROR_STACK);
        DBMS_OUTPUT.PUT_LINE('Call stack: ' || DBMS_UTILITY.FORMAT_CALL_STACK);
END;
/

-- Exception propagation across procedure calls
CREATE OR REPLACE PROCEDURE inner_proc IS
BEGIN
    RAISE NO_DATA_FOUND;
END;
/

CREATE OR REPLACE PROCEDURE outer_proc IS
BEGIN
    inner_proc;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Exception caught in outer_proc');
        -- Don't re-raise, exception stops here
END;
/

-- Call the procedure
BEGIN
    outer_proc;
    DBMS_OUTPUT.PUT_LINE('Execution continues');
END;
/

-- Exception with WHEN OTHERS and detailed error info
DECLARE
    v_operation VARCHAR2(100);
BEGIN
    v_operation := 'Step 1';
    -- Some operation
    v_operation := 'Step 2';
    SELECT 1/0 INTO v_operation FROM DUAL;
    v_operation := 'Step 3';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error at: ' || v_operation);
        DBMS_OUTPUT.PUT_LINE('SQLCODE: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQLERRM: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Format Error Backtrace: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END;
/

-- Exception in exception handler (not recommended but valid)
DECLARE
    v_value NUMBER;
BEGIN
    v_value := 1 / 0;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('First exception');
        -- This could raise another exception
        v_value := 'ABC';  -- TYPE MISMATCH
END;
/
