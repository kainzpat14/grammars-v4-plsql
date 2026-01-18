-- DROP MLE ENV statement examples
-- This statement is not currently supported by the PlSql grammar
-- MLE (Multilingual Engine) environments were introduced in Oracle 23ai

-- Simple drop
DROP MLE ENV math_env;

-- Drop if exists
DROP MLE ENV IF EXISTS fakerjs_env;

-- Drop with schema qualification
DROP MLE ENV scott.myenv;
