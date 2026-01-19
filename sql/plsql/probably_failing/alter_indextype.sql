-- ALTER INDEXTYPE statement examples
-- This statement is not currently supported by the PlSql grammar
-- INDEXTYPE is used for domain indexes (Oracle extensibility feature)

-- Compile an indextype
ALTER INDEXTYPE position_indextype COMPILE;

-- Add an operator to an indextype
ALTER INDEXTYPE text_indextype ADD contains(VARCHAR2, VARCHAR2);
ALTER INDEXTYPE spatial_indextype ADD sdo_within_distance(SDO_GEOMETRY, SDO_GEOMETRY, NUMBER);

-- Drop an operator from an indextype
ALTER INDEXTYPE text_indextype DROP contains(VARCHAR2, VARCHAR2);
ALTER INDEXTYPE spatial_indextype DROP sdo_filter(SDO_GEOMETRY, SDO_GEOMETRY);

-- Change the implementation type
ALTER INDEXTYPE text_indextype USING new_implementation_type;

-- Using schema-qualified names
ALTER INDEXTYPE myschema.custom_indextype COMPILE;

-- IF EXISTS clause (19.28+)
ALTER INDEXTYPE IF EXISTS text_indextype COMPILE;
