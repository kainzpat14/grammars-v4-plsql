-- ALTER MLE MODULE statement examples
-- This statement is not currently supported by the PlSql grammar
-- MLE (Multilingual Engine) for JavaScript was introduced in Oracle 23ai

-- Compile MLE module
ALTER MLE MODULE math_module COMPILE;

-- Compile with schema qualification
ALTER MLE MODULE scott.utility_module COMPILE;

-- IF EXISTS variant
ALTER MLE MODULE IF EXISTS helper_module_inline COMPILE;
