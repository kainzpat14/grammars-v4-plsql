-- PL/SQL PRAGMA directive examples
-- Tests various pragma directives that may not be fully supported

-- PRAGMA AUTONOMOUS_TRANSACTION in procedure
CREATE OR REPLACE PROCEDURE log_error(
    p_error_code IN NUMBER,
    p_error_message IN VARCHAR2
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO error_log (error_code, error_message, log_timestamp)
    VALUES (p_error_code, p_error_message, SYSTIMESTAMP);
    COMMIT;  -- Commits only this transaction
END;
/

-- PRAGMA AUTONOMOUS_TRANSACTION in function
CREATE OR REPLACE FUNCTION get_sequence_value RETURN NUMBER IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_next_val NUMBER;
BEGIN
    SELECT my_sequence.NEXTVAL INTO v_next_val FROM DUAL;
    COMMIT;
    RETURN v_next_val;
END;
/

-- PRAGMA EXCEPTION_INIT
DECLARE
    e_deadlock_detected EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_deadlock_detected, -60);

    e_timeout_on_resource EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_timeout_on_resource, -51);
BEGIN
    -- Some operation
    NULL;
EXCEPTION
    WHEN e_deadlock_detected THEN
        DBMS_OUTPUT.PUT_LINE('Deadlock detected');
    WHEN e_timeout_on_resource THEN
        DBMS_OUTPUT.PUT_LINE('Timeout on resource');
END;
/

-- PRAGMA SERIALLY_REUSABLE in package
CREATE OR REPLACE PACKAGE pkg_session_data IS
    PRAGMA SERIALLY_REUSABLE;

    g_session_value NUMBER;

    PROCEDURE set_value(p_value NUMBER);
    FUNCTION get_value RETURN NUMBER;
END;
/

CREATE OR REPLACE PACKAGE BODY pkg_session_data IS
    PRAGMA SERIALLY_REUSABLE;

    PROCEDURE set_value(p_value NUMBER) IS
    BEGIN
        g_session_value := p_value;
    END;

    FUNCTION get_value RETURN NUMBER IS
    BEGIN
        RETURN g_session_value;
    END;
END;
/

-- PRAGMA INLINE
CREATE OR REPLACE FUNCTION calculate_bonus(p_salary NUMBER) RETURN NUMBER IS
    PRAGMA INLINE (compute_tax, 'YES');

    FUNCTION compute_tax(p_amount NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_amount * 0.3;
    END;
BEGIN
    RETURN p_salary * 0.1 - compute_tax(p_salary * 0.1);
END;
/

-- PRAGMA INLINE with NO
CREATE OR REPLACE FUNCTION complex_calc(p_value NUMBER) RETURN NUMBER IS
    PRAGMA INLINE (expensive_function, 'NO');

    FUNCTION expensive_function(p_val NUMBER) RETURN NUMBER IS
    BEGIN
        -- Complex calculation
        RETURN p_val * p_val + p_val;
    END;
BEGIN
    RETURN expensive_function(p_value);
END;
/

-- PRAGMA RESTRICT_REFERENCES (deprecated but still valid)
CREATE OR REPLACE PACKAGE pkg_pure_functions IS
    FUNCTION pure_func(p_value NUMBER) RETURN NUMBER;
    PRAGMA RESTRICT_REFERENCES(pure_func, WNDS, WNPS, RNDS, RNPS);
END;
/

CREATE OR REPLACE PACKAGE BODY pkg_pure_functions IS
    FUNCTION pure_func(p_value NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_value * 2;
    END;
END;
/

-- PRAGMA RESTRICT_REFERENCES with DEFAULT
CREATE OR REPLACE PACKAGE pkg_default_restrict IS
    PRAGMA RESTRICT_REFERENCES(DEFAULT, WNDS, RNDS);

    FUNCTION func1(p_val NUMBER) RETURN NUMBER;
    FUNCTION func2(p_val NUMBER) RETURN NUMBER;
END;
/

-- PRAGMA UDF (User-Defined Function optimization)
CREATE OR REPLACE FUNCTION optimized_func(p_value NUMBER) RETURN NUMBER IS
    PRAGMA UDF;
BEGIN
    RETURN p_value * 2;
END;
/

-- PRAGMA DEPRECATE (12.2+)
CREATE OR REPLACE PACKAGE pkg_deprecated IS
    PROCEDURE old_procedure(p_value NUMBER);
    PRAGMA DEPRECATE(old_procedure, 'Use new_procedure instead');

    PROCEDURE new_procedure(p_value NUMBER);
END;
/

CREATE OR REPLACE PACKAGE BODY pkg_deprecated IS
    PROCEDURE old_procedure(p_value NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Old procedure: ' || p_value);
    END;

    PROCEDURE new_procedure(p_value NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('New procedure: ' || p_value);
    END;
END;
/

-- PRAGMA DEPRECATE with custom message
CREATE OR REPLACE FUNCTION deprecated_func RETURN NUMBER IS
    PRAGMA DEPRECATE(deprecated_func, 'This function is deprecated. Use new_func instead.');
BEGIN
    RETURN 0;
END;
/

-- PRAGMA COVERAGE (for testing coverage)
CREATE OR REPLACE PROCEDURE test_coverage IS
    PRAGMA COVERAGE('NOT_FEASIBLE');
BEGIN
    -- This code is marked as not feasible for testing
    IF 1 = 0 THEN
        DBMS_OUTPUT.PUT_LINE('This will never execute');
    END IF;
END;
/

-- Multiple pragmas in one subprogram
CREATE OR REPLACE FUNCTION multi_pragma_func(p_value NUMBER) RETURN NUMBER IS
    PRAGMA UDF;
    PRAGMA INLINE(helper_func, 'YES');

    FUNCTION helper_func(p_val NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_val + 10;
    END;
BEGIN
    RETURN helper_func(p_value) * 2;
END;
/

-- PRAGMA in nested procedure
CREATE OR REPLACE PROCEDURE outer_procedure IS
    PROCEDURE inner_autonomous IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO audit_table (action, action_time)
        VALUES ('Action logged', SYSTIMESTAMP);
        COMMIT;
    END;
BEGIN
    -- Main procedure logic
    inner_autonomous;
    -- Continue with main transaction
END;
/

-- PRAGMA with conditional compilation
CREATE OR REPLACE PACKAGE pkg_conditional IS
    $IF $$PLSQL_OPTIMIZE_LEVEL >= 2 $THEN
        FUNCTION optimized_func(p_value NUMBER) RETURN NUMBER;
        PRAGMA INLINE(optimized_func, 'YES');
    $ELSE
        FUNCTION optimized_func(p_value NUMBER) RETURN NUMBER;
    $END
END;
/

-- PRAGMA EXCEPTION_INIT with user-defined error codes
DECLARE
    e_custom_1 EXCEPTION;
    e_custom_2 EXCEPTION;
    e_custom_3 EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_custom_1, -20001);
    PRAGMA EXCEPTION_INIT(e_custom_2, -20002);
    PRAGMA EXCEPTION_INIT(e_custom_3, -20003);
BEGIN
    IF FALSE THEN
        RAISE_APPLICATION_ERROR(-20001, 'Custom error 1');
    ELSIF FALSE THEN
        RAISE_APPLICATION_ERROR(-20002, 'Custom error 2');
    END IF;
EXCEPTION
    WHEN e_custom_1 THEN
        DBMS_OUTPUT.PUT_LINE('Caught custom error 1');
    WHEN e_custom_2 THEN
        DBMS_OUTPUT.PUT_LINE('Caught custom error 2');
    WHEN e_custom_3 THEN
        DBMS_OUTPUT.PUT_LINE('Caught custom error 3');
END;
/
