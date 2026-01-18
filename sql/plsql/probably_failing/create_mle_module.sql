-- CREATE MLE MODULE statement examples
-- This statement is not currently supported by the PlSql grammar
-- MLE (Multilingual Engine) for JavaScript was introduced in Oracle 23ai

-- Simple inline JavaScript module
CREATE MLE MODULE helper_module_inline
LANGUAGE JAVASCRIPT AS
/**
 * Convert a delimited string into key-value pairs and return JSON
 * @param {string} inputString - the input string to be converted
 * @returns {JSON}
 */
function string2obj(inputString) {
    if ( inputString === undefined ) {
        throw 'must provide a string in the form of key1=value1;...;keyN=valueN';
    }
    let myObject = {};
    const kvPairs = inputString.split(';');
    for (const pair of kvPairs) {
        const [key, value] = pair.split('=');
        myObject[key.trim()] = value.trim();
    }
    return myObject;
}
export { string2obj };
/

-- OR REPLACE variant
CREATE OR REPLACE MLE MODULE math_module
LANGUAGE JAVASCRIPT AS
export function add(a, b) {
    return a + b;
}
export function multiply(a, b) {
    return a * b;
}
/

-- Module with multiple functions
CREATE OR REPLACE MLE MODULE utility_module
LANGUAGE JAVASCRIPT AS
export function formatDate(dateStr) {
    const date = new Date(dateStr);
    return date.toISOString();
}

export function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

export function capitalizeWords(str) {
    return str.replace(/\b\w/g, char => char.toUpperCase());
}
/

-- Module from BFILE
CREATE MLE MODULE fakerjs_module USING BFILE(data_dir, 'faker.js');

-- IF NOT EXISTS variant
CREATE MLE MODULE IF NOT EXISTS default_module
LANGUAGE JAVASCRIPT AS
export function greet(name) {
    return 'Hello, ' + name;
}
/
