-- CREATE TABLE with COLLATE and collation specifications
-- Tests various collation options

-- Table-level default collation
CREATE TABLE employees_ci (
    emp_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
)
DEFAULT COLLATION BINARY_CI;

-- Column-level collation
CREATE TABLE products_collate (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100) COLLATE BINARY_CI,
    product_code VARCHAR2(50) COLLATE BINARY,
    description VARCHAR2(500) COLLATE BINARY_AI
);

-- Mixed collations
CREATE TABLE customers_mixed (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100) COLLATE BINARY_CI,
    email VARCHAR2(100) COLLATE BINARY,
    country_code CHAR(2) COLLATE BINARY_CI
)
DEFAULT COLLATION USING_NLS_COMP;

-- Linguistic collations
CREATE TABLE intl_names (
    id NUMBER PRIMARY KEY,
    name_en VARCHAR2(100) COLLATE BINARY_CI,
    name_fr VARCHAR2(100) COLLATE XFRENCH_CI,
    name_de VARCHAR2(100) COLLATE XGERMAN_CI,
    name_es VARCHAR2(100) COLLATE XSPANISH_CI
);

-- Case-insensitive and accent-insensitive
CREATE TABLE search_data (
    id NUMBER PRIMARY KEY,
    title VARCHAR2(200) COLLATE BINARY_CI,
    description VARCHAR2(1000) COLLATE BINARY_AI,
    tags VARCHAR2(500) COLLATE USING_NLS_COMP
);

-- Collation with constraints
CREATE TABLE unique_ci (
    id NUMBER PRIMARY KEY,
    code VARCHAR2(50) COLLATE BINARY_CI UNIQUE,
    name VARCHAR2(100) COLLATE BINARY_CI
);

-- Collation with partitioning
CREATE TABLE partitioned_collate (
    id NUMBER PRIMARY KEY,
    region VARCHAR2(50) COLLATE BINARY_CI,
    data VARCHAR2(200)
)
DEFAULT COLLATION BINARY_CI
PARTITION BY LIST (region) (
    PARTITION p_north VALUES ('NORTH', 'north'),
    PARTITION p_south VALUES ('SOUTH', 'south')
);

-- Using NLS collation parameters
CREATE TABLE nls_collate (
    id NUMBER PRIMARY KEY,
    text1 VARCHAR2(100) COLLATE USING_NLS_SORT,
    text2 VARCHAR2(100) COLLATE USING_NLS_COMP
);
