-- SELECT with hierarchical queries (CONNECT BY)
-- Tests tree-walking queries with CONNECT BY, START WITH, PRIOR, LEVEL

-- Basic hierarchical query - employee hierarchy
SELECT employee_id, first_name, last_name, manager_id, LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query with order
SELECT employee_id, first_name, manager_id, LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name;

-- Hierarchical query starting from specific employee
SELECT employee_id, first_name, manager_id, LEVEL
FROM employees
START WITH employee_id = 100
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query - bottom up
SELECT employee_id, first_name, manager_id, LEVEL
FROM employees
START WITH employee_id = 206
CONNECT BY PRIOR manager_id = employee_id;

-- Hierarchical query with PRIOR in WHERE
SELECT employee_id, first_name, manager_id, salary, LEVEL
FROM employees
WHERE salary > 5000
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id AND salary > 3000;

-- Hierarchical query with NOCYCLE (11g+)
-- Prevents infinite loops in cyclic data
SELECT employee_id, first_name, manager_id, LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;

-- Hierarchical query with CONNECT_BY_ISCYCLE (11g+)
SELECT employee_id, first_name, manager_id, LEVEL,
       CONNECT_BY_ISCYCLE as is_cycle
FROM employees
START WITH manager_id IS NULL
CONNECT BY NOCYCLE PRIOR employee_id = manager_id;

-- Hierarchical query with CONNECT_BY_ISLEAF
SELECT employee_id, first_name, manager_id, LEVEL,
       CONNECT_BY_ISLEAF as is_leaf
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query with SYS_CONNECT_BY_PATH
SELECT employee_id, first_name, manager_id, LEVEL,
       SYS_CONNECT_BY_PATH(first_name, ' -> ') as path
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query with CONNECT_BY_ROOT
SELECT employee_id, first_name, manager_id,
       CONNECT_BY_ROOT employee_id as root_emp_id,
       CONNECT_BY_ROOT first_name as root_emp_name,
       LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query - indented display
SELECT LPAD(' ', 2 * (LEVEL - 1)) || first_name || ' ' || last_name as org_chart,
       employee_id, manager_id, LEVEL
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name;

-- Hierarchical query with multiple START WITH conditions
SELECT employee_id, first_name, manager_id, department_id, LEVEL
FROM employees
START WITH manager_id IS NULL OR department_id = 90
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query with PRIOR on multiple columns
SELECT category_id, parent_category_id, category_name, LEVEL
FROM categories
START WITH parent_category_id IS NULL
CONNECT BY PRIOR category_id = parent_category_id
    AND PRIOR category_type = category_type;

-- Hierarchical query - leaf nodes only
SELECT employee_id, first_name, LEVEL
FROM employees
WHERE CONNECT_BY_ISLEAF = 1
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query - specific level
SELECT employee_id, first_name, LEVEL
FROM employees
WHERE LEVEL = 3
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query - level range
SELECT employee_id, first_name, LEVEL
FROM employees
WHERE LEVEL BETWEEN 2 AND 4
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query with aggregate functions
SELECT MAX(LEVEL) as max_depth,
       COUNT(*) as total_nodes,
       COUNT(DISTINCT LEVEL) as distinct_levels
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query with GROUP BY
SELECT LEVEL as org_level, COUNT(*) as emp_count
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
GROUP BY LEVEL
ORDER BY LEVEL;

-- Hierarchical query joining with other tables
SELECT e.employee_id, e.first_name, e.manager_id, d.department_name, LEVEL
FROM employees e
JOIN departments d ON e.department_id = d.department_id
START WITH e.manager_id IS NULL
CONNECT BY PRIOR e.employee_id = e.manager_id;

-- Hierarchical query - find all subordinates of a manager
SELECT employee_id, first_name, manager_id, LEVEL - 1 as levels_below
FROM employees
START WITH employee_id = 100
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query - find path to top
SELECT employee_id, first_name,
       SYS_CONNECT_BY_PATH(employee_id, '/') as id_path,
       SYS_CONNECT_BY_PATH(first_name, ' <- ') as name_path
FROM employees
WHERE employee_id = 206
START WITH employee_id = 206
CONNECT BY PRIOR manager_id = employee_id;

-- Hierarchical query with CONNECT_BY_ROOT in WHERE
SELECT employee_id, first_name, manager_id
FROM employees
WHERE CONNECT_BY_ROOT employee_id = 100
START WITH manager_id = 100
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query - pruning branches
SELECT employee_id, first_name, manager_id, department_id, LEVEL
FROM employees
WHERE department_id != 90
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id AND department_id != 50;

-- Complex hierarchical query with inline view
SELECT * FROM (
    SELECT employee_id, first_name, manager_id, salary, LEVEL,
           CONNECT_BY_ROOT first_name as ceo_name,
           SYS_CONNECT_BY_PATH(first_name, '/') as path
    FROM employees
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
)
WHERE LEVEL >= 2 AND salary > 5000;

-- Hierarchical query - bills of materials example
SELECT component_id, parent_component_id, quantity, LEVEL,
       LPAD(' ', 2 * (LEVEL - 1)) || component_name as bom_structure
FROM bom
START WITH parent_component_id IS NULL
CONNECT BY PRIOR component_id = parent_component_id;

-- Hierarchical query with analytic functions
SELECT employee_id, first_name, manager_id, salary, LEVEL,
       ROW_NUMBER() OVER (PARTITION BY LEVEL ORDER BY salary DESC) as rank_in_level
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- Hierarchical query - organizational depth analysis
SELECT CONNECT_BY_ROOT employee_id as root_mgr,
       employee_id,
       first_name,
       LEVEL as depth,
       CONNECT_BY_ISLEAF as is_bottom
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER BY CONNECT_BY_ROOT employee_id, LEVEL, employee_id;
