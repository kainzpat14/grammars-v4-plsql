-- DROP MLE MODULE statement examples
-- This statement is not currently supported by the PlSql grammar
-- MLE (Multilingual Engine) for JavaScript was introduced in Oracle 23ai

-- Simple drop
DROP MLE MODULE math_module;

-- Drop if exists
DROP MLE MODULE IF EXISTS helper_module_inline;

-- Drop with schema qualification
DROP MLE MODULE scott.utility_module;
