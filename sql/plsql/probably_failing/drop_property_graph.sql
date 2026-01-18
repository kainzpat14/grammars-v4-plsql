-- DROP PROPERTY GRAPH statement examples
-- This statement is not currently supported by the PlSql grammar
-- Property Graphs were introduced in Oracle 23ai

-- Simple drop
DROP PROPERTY GRAPH myGraph;

-- Drop if exists
DROP PROPERTY GRAPH IF EXISTS social_network;

-- Drop with schema qualification
DROP PROPERTY GRAPH myschema.company_graph;

-- Drop with cascade
DROP PROPERTY GRAPH network_graph CASCADE;
