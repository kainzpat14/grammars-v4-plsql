-- CREATE PROPERTY GRAPH statement examples
-- This statement is not currently supported by the PlSql grammar
-- Property Graphs were introduced in Oracle 23ai

-- Simple property graph with vertex tables
CREATE PROPERTY GRAPH myGraph
VERTEX TABLES (
  mytable,
  mytable2 AS T2
);

-- Property graph with specific properties
CREATE PROPERTY GRAPH g
VERTEX TABLES (
  tbl1 PROPERTIES (c2, c3, c5)
);

-- Property graph with vertex and edge tables
CREATE PROPERTY GRAPH social_network
VERTEX TABLES (
  persons
    KEY (person_id)
    LABEL person
    PROPERTIES (person_id, name, age, email)
)
EDGE TABLES (
  friendships
    KEY (friendship_id)
    SOURCE KEY (person1_id) REFERENCES persons(person_id)
    DESTINATION KEY (person2_id) REFERENCES persons(person_id)
    LABEL knows
    PROPERTIES (friendship_id, since_date, relationship_type)
);

-- With OR REPLACE
CREATE OR REPLACE PROPERTY GRAPH network_graph
VERTEX TABLES (
  nodes PROPERTIES (node_id, node_name, node_type),
  devices PROPERTIES (device_id, device_name, location)
)
EDGE TABLES (
  connections
    SOURCE KEY (from_node) REFERENCES nodes(node_id)
    DESTINATION KEY (to_node) REFERENCES nodes(node_id)
    PROPERTIES (connection_type, bandwidth, status)
);

-- Complex property graph with multiple labels
CREATE PROPERTY GRAPH company_graph
VERTEX TABLES (
  employees
    KEY (emp_id)
    LABEL employee
    PROPERTIES (emp_id, name, department, salary),
  departments
    KEY (dept_id)
    LABEL department
    PROPERTIES (dept_id, dept_name, location)
)
EDGE TABLES (
  works_in
    KEY (assignment_id)
    SOURCE KEY (emp_id) REFERENCES employees(emp_id)
    DESTINATION KEY (dept_id) REFERENCES departments(dept_id)
    LABEL works_in
    PROPERTIES (assignment_id, start_date, role),
  manages
    KEY (mgmt_id)
    SOURCE KEY (manager_id) REFERENCES employees(emp_id)
    DESTINATION KEY (subordinate_id) REFERENCES employees(emp_id)
    LABEL manages
    PROPERTIES (mgmt_id, since_date)
);

-- Property graph with IF NOT EXISTS
CREATE PROPERTY GRAPH IF NOT EXISTS product_graph
VERTEX TABLES (
  products KEY (product_id) PROPERTIES (product_id, name, price)
);
