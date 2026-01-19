-- CREATE MLE ENV statement examples
-- This statement is not currently supported by the PlSql grammar
-- MLE (Multilingual Engine) environments were introduced in Oracle 23ai

-- Simple MLE environment with one module
CREATE MLE ENV math_env
IMPORTS (
    'MATH_MOD' MODULE MATH_MOD
);

-- MLE environment with multiple modules
CREATE MLE ENV math_env
IMPORTS (
    'MATH_MOD' MODULE MATH_MOD,
    'MATH_MOD2' MODULE MATH_MOD2
);

-- MLE environment with external module (faker.js)
CREATE MLE ENV fakerjs_env
IMPORTS (
    'fakerjs' MODULE fakerjs_module
);

-- OR REPLACE variant
CREATE OR REPLACE MLE ENV utility_env
IMPORTS (
    'utils' MODULE utility_module,
    'helpers' MODULE helper_module_inline
);

-- MLE environment with language options
CREATE MLE ENV strict_env
IMPORTS (
    'MATH_MOD' MODULE MATH_MOD
)
LANGUAGE OPTIONS 'js.strict=true';

-- IF NOT EXISTS variant
CREATE MLE ENV IF NOT EXISTS default_env
IMPORTS (
    'default' MODULE default_module
);

-- Complex environment with multiple imports and options
CREATE OR REPLACE MLE ENV complex_env
IMPORTS (
    'math' MODULE math_module,
    'utils' MODULE utility_module,
    'data' MODULE data_module
)
LANGUAGE OPTIONS 'js.strict=true,js.ecmascript-version=2022';
