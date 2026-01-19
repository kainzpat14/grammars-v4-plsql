-- ALTER DOMAIN statement examples
-- This statement is not currently supported by the PlSql grammar
-- SQL Domains were introduced in Oracle 23ai

-- Add display expression
ALTER DOMAIN day_of_week ADD DISPLAY INITCAP(day_of_week);
ALTER DOMAIN salary ADD DISPLAY TO_CHAR(salary, '$999,999.99');

-- Modify display expression
ALTER DOMAIN day_of_week MODIFY DISPLAY LOWER(day_of_week);
ALTER DOMAIN salary MODIFY DISPLAY TO_CHAR(salary, 'L999G999D99');

-- Drop display expression
ALTER DOMAIN day_of_week DROP DISPLAY;

-- Add order expression
ALTER DOMAIN year_of_birth ADD ORDER FLOOR(year_of_birth/100);
ALTER DOMAIN priority ADD ORDER DECODE(priority, 'High', 1, 'Medium', 2, 'Low', 3);

-- Modify order expression
ALTER DOMAIN year_of_birth MODIFY ORDER MOD(year_of_birth,100);
ALTER DOMAIN priority MODIFY ORDER DECODE(priority, 'Critical', 0, 'High', 1, 'Medium', 2, 'Low', 3);

-- Drop order expression
ALTER DOMAIN year_of_birth DROP ORDER;

-- Add annotations
ALTER DOMAIN day_of_week ANNOTATIONS(Display 'Day of week');
ALTER DOMAIN salary ANNOTATIONS(Category 'Financial', Sensitive 'True');
ALTER DOMAIN employee_id ANNOTATIONS(Description 'Unique employee identifier', Required 'True');

-- Drop annotations
ALTER DOMAIN day_of_week DROP ANNOTATIONS(Display);
ALTER DOMAIN salary DROP ANNOTATIONS(Category, Sensitive);
