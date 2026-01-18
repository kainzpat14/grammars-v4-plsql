-- ALTER PROPERTY GRAPH statement examples
-- This statement is not currently supported by the PlSql grammar
-- Property Graphs were introduced in Oracle 23ai

-- Compile a property graph to revalidate
ALTER PROPERTY GRAPH myGraph COMPILE;

-- Compile with schema qualification
ALTER PROPERTY GRAPH myschema.social_network COMPILE;

-- Note: To change the definition of a property graph, use CREATE OR REPLACE
-- ALTER is primarily used for revalidation
