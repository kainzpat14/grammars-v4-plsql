-- Advanced control structure examples
-- Tests CONTINUE, GOTO, CASE, and other control flow features

-- CONTINUE statement in FOR loop
DECLARE
    v_sum NUMBER := 0;
BEGIN
    FOR i IN 1..10 LOOP
        IF MOD(i, 2) = 0 THEN
            CONTINUE; -- Skip even numbers
        END IF;
        v_sum := v_sum + i;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Sum of odd numbers: ' || v_sum);
END;
/

-- CONTINUE WHEN statement
DECLARE
    v_product NUMBER := 1;
BEGIN
    FOR i IN 1..10 LOOP
        CONTINUE WHEN i > 5; -- Skip numbers greater than 5
        v_product := v_product * i;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Product of 1-5: ' || v_product);
END;
/

-- CONTINUE in WHILE loop
DECLARE
    v_counter NUMBER := 0;
    v_sum NUMBER := 0;
BEGIN
    WHILE v_counter < 20 LOOP
        v_counter := v_counter + 1;
        CONTINUE WHEN MOD(v_counter, 3) = 0; -- Skip multiples of 3
        v_sum := v_sum + v_counter;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Sum (excluding multiples of 3): ' || v_sum);
END;
/

-- GOTO statement with labels
DECLARE
    v_value NUMBER := 5;
BEGIN
    IF v_value < 0 THEN
        GOTO negative_value;
    ELSIF v_value = 0 THEN
        GOTO zero_value;
    ELSE
        GOTO positive_value;
    END IF;

    <<negative_value>>
    DBMS_OUTPUT.PUT_LINE('Value is negative');
    GOTO end_processing;

    <<zero_value>>
    DBMS_OUTPUT.PUT_LINE('Value is zero');
    GOTO end_processing;

    <<positive_value>>
    DBMS_OUTPUT.PUT_LINE('Value is positive');

    <<end_processing>>
    DBMS_OUTPUT.PUT_LINE('Processing complete');
END;
/

-- CASE expression (simple)
DECLARE
    v_grade CHAR(1) := 'B';
    v_description VARCHAR2(20);
BEGIN
    v_description := CASE v_grade
        WHEN 'A' THEN 'Excellent'
        WHEN 'B' THEN 'Good'
        WHEN 'C' THEN 'Average'
        WHEN 'D' THEN 'Below Average'
        WHEN 'F' THEN 'Fail'
        ELSE 'Unknown'
    END;
    DBMS_OUTPUT.PUT_LINE('Grade: ' || v_grade || ' - ' || v_description);
END;
/

-- CASE expression (searched)
DECLARE
    v_score NUMBER := 85;
    v_grade CHAR(1);
BEGIN
    v_grade := CASE
        WHEN v_score >= 90 THEN 'A'
        WHEN v_score >= 80 THEN 'B'
        WHEN v_score >= 70 THEN 'C'
        WHEN v_score >= 60 THEN 'D'
        ELSE 'F'
    END;
    DBMS_OUTPUT.PUT_LINE('Score: ' || v_score || ', Grade: ' || v_grade);
END;
/

-- CASE statement (PL/SQL)
DECLARE
    v_day_of_week NUMBER := TO_NUMBER(TO_CHAR(SYSDATE, 'D'));
BEGIN
    CASE v_day_of_week
        WHEN 1 THEN DBMS_OUTPUT.PUT_LINE('Sunday');
        WHEN 2 THEN DBMS_OUTPUT.PUT_LINE('Monday');
        WHEN 3 THEN DBMS_OUTPUT.PUT_LINE('Tuesday');
        WHEN 4 THEN DBMS_OUTPUT.PUT_LINE('Wednesday');
        WHEN 5 THEN DBMS_OUTPUT.PUT_LINE('Thursday');
        WHEN 6 THEN DBMS_OUTPUT.PUT_LINE('Friday');
        WHEN 7 THEN DBMS_OUTPUT.PUT_LINE('Saturday');
        ELSE DBMS_OUTPUT.PUT_LINE('Invalid day');
    END CASE;
END;
/

-- Nested CASE statements
DECLARE
    v_department_id NUMBER := 10;
    v_salary NUMBER := 50000;
    v_bonus NUMBER;
BEGIN
    v_bonus := CASE v_department_id
        WHEN 10 THEN
            CASE
                WHEN v_salary > 60000 THEN v_salary * 0.15
                WHEN v_salary > 40000 THEN v_salary * 0.10
                ELSE v_salary * 0.05
            END
        WHEN 20 THEN v_salary * 0.12
        WHEN 30 THEN v_salary * 0.08
        ELSE v_salary * 0.05
    END;
    DBMS_OUTPUT.PUT_LINE('Bonus: ' || v_bonus);
END;
/

-- EXIT WHEN in nested loops
DECLARE
    v_found BOOLEAN := FALSE;
BEGIN
    <<outer_loop>>
    FOR i IN 1..10 LOOP
        <<inner_loop>>
        FOR j IN 1..10 LOOP
            IF i * j = 24 THEN
                DBMS_OUTPUT.PUT_LINE('Found: ' || i || ' * ' || j || ' = 24');
                v_found := TRUE;
                EXIT outer_loop; -- Exit both loops
            END IF;
        END LOOP inner_loop;
    END LOOP outer_loop;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('Not found');
    END IF;
END;
/

-- LOOP with EXIT and CONTINUE
DECLARE
    v_counter NUMBER := 0;
    v_sum NUMBER := 0;
BEGIN
    LOOP
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 20;
        CONTINUE WHEN MOD(v_counter, 2) = 0;
        v_sum := v_sum + v_counter;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Sum of odd numbers 1-19: ' || v_sum);
END;
/

-- FOR loop with REVERSE
DECLARE
    v_countdown VARCHAR2(100) := '';
BEGIN
    FOR i IN REVERSE 1..10 LOOP
        v_countdown := v_countdown || i || ' ';
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Countdown: ' || v_countdown);
END;
/

-- Cursor FOR loop with EXIT
DECLARE
    v_count NUMBER := 0;
BEGIN
    FOR emp_rec IN (SELECT * FROM employees ORDER BY employee_id) LOOP
        v_count := v_count + 1;
        DBMS_OUTPUT.PUT_LINE(emp_rec.last_name);
        EXIT WHEN v_count >= 5; -- Process only first 5 records
    END LOOP;
END;
/

-- WHILE loop with complex condition
DECLARE
    v_total NUMBER := 0;
    v_counter NUMBER := 1;
    v_max_iterations NUMBER := 100;
BEGIN
    WHILE v_counter <= v_max_iterations AND v_total < 1000 LOOP
        v_total := v_total + v_counter;
        v_counter := v_counter + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total: ' || v_total || ' after ' || (v_counter - 1) || ' iterations');
END;
/

-- NULL statement placeholder
BEGIN
    IF 1 = 2 THEN
        DBMS_OUTPUT.PUT_LINE('This will not execute');
    ELSE
        NULL; -- Explicit no-op
    END IF;
END;
/

-- Complex nested control structures
DECLARE
    TYPE num_array IS TABLE OF NUMBER;
    v_numbers num_array := num_array(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
    v_result VARCHAR2(1000) := '';
BEGIN
    FOR i IN 1..v_numbers.COUNT LOOP
        CASE
            WHEN MOD(v_numbers(i), 15) = 0 THEN
                v_result := v_result || 'FizzBuzz ';
            WHEN MOD(v_numbers(i), 3) = 0 THEN
                v_result := v_result || 'Fizz ';
            WHEN MOD(v_numbers(i), 5) = 0 THEN
                v_result := v_result || 'Buzz ';
            ELSE
                v_result := v_result || v_numbers(i) || ' ';
        END CASE;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('FizzBuzz: ' || v_result);
END;
/

-- Conditional compilation with control structures
DECLARE
    v_debug_level NUMBER := 2;
BEGIN
    $IF $$DEBUG_MODE $THEN
        DBMS_OUTPUT.PUT_LINE('Debug mode enabled');
        CASE v_debug_level
            WHEN 1 THEN DBMS_OUTPUT.PUT_LINE('Level: Basic');
            WHEN 2 THEN DBMS_OUTPUT.PUT_LINE('Level: Detailed');
            WHEN 3 THEN DBMS_OUTPUT.PUT_LINE('Level: Verbose');
        END CASE;
    $ELSE
        NULL; -- No debug output
    $END
END;
/

-- FOR loop over sparse collection
DECLARE
    TYPE sparse_array IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
    v_data sparse_array;
    v_idx PLS_INTEGER;
BEGIN
    v_data(1) := 'First';
    v_data(10) := 'Tenth';
    v_data(100) := 'Hundredth';

    v_idx := v_data.FIRST;
    WHILE v_idx IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE('Index ' || v_idx || ': ' || v_data(v_idx));
        v_idx := v_data.NEXT(v_idx);
    END LOOP;
END;
/

-- GOTO for exception recovery
DECLARE
    v_attempts NUMBER := 0;
    v_max_attempts NUMBER := 3;
    v_success BOOLEAN := FALSE;
BEGIN
    <<retry>>
    BEGIN
        v_attempts := v_attempts + 1;
        DBMS_OUTPUT.PUT_LINE('Attempt ' || v_attempts);

        IF v_attempts < 3 THEN
            RAISE NO_DATA_FOUND; -- Simulate error
        END IF;

        v_success := TRUE;
        DBMS_OUTPUT.PUT_LINE('Operation succeeded');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF v_attempts < v_max_attempts THEN
                DBMS_LOCK.SLEEP(1);
                GOTO retry;
            ELSE
                DBMS_OUTPUT.PUT_LINE('Max attempts reached');
                RAISE;
            END IF;
    END;
END;
/

-- CONTINUE in cursor loop
DECLARE
    v_total_salary NUMBER := 0;
    v_count NUMBER := 0;
BEGIN
    FOR emp IN (SELECT * FROM employees) LOOP
        CONTINUE WHEN emp.salary IS NULL;
        CONTINUE WHEN emp.salary < 3000;

        v_total_salary := v_total_salary + emp.salary;
        v_count := v_count + 1;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Average salary (>3000): ' || (v_total_salary / v_count));
END;
/
