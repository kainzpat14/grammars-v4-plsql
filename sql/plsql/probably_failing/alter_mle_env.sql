-- ALTER MLE ENV statement examples
-- This statement is not currently supported by the PlSql grammar
-- MLE (Multilingual Engine) environments were introduced in Oracle 23ai

-- Set language options to enable strict mode
ALTER MLE ENV myenv SET LANGUAGE OPTIONS 'js.strict=true';

-- Add additional imports
ALTER MLE ENV math_env ADD IMPORTS (
    'MATH_MOD3' MODULE MATH_MOD3
);

-- Modify existing imports
ALTER MLE ENV utility_env MODIFY IMPORTS (
    'utils' MODULE new_utility_module
);

-- Drop imports
ALTER MLE ENV complex_env DROP IMPORTS ('data');

-- Set multiple language options
ALTER MLE ENV strict_env SET LANGUAGE OPTIONS 'js.strict=true,js.ecmascript-version=2022';

-- Schema-qualified environment
ALTER MLE ENV scott.myenv SET LANGUAGE OPTIONS 'js.strict=true';
