-- CREATE DOMAIN statement examples
-- This statement is not currently supported by the PlSql grammar
-- SQL Domains were introduced in Oracle 23ai

-- Simple single column domain with constraint
CREATE DOMAIN email_domain AS VARCHAR2(100)
  CONSTRAINT CHECK (REGEXP_LIKE(email_domain, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$'));

-- Domain with default value
CREATE DOMAIN status_code AS VARCHAR2(10)
  DEFAULT ON NULL 'ACTIVE'
  CONSTRAINT CHECK (status_code IN ('ACTIVE', 'INACTIVE', 'PENDING'));

-- Domain with display expression
CREATE DOMAIN year_of_birth AS NUMBER(4)
  CONSTRAINT CHECK ((TRUNC(year_of_birth) = year_of_birth) AND (year_of_birth >= 1900))
  DISPLAY CASE WHEN year_of_birth < 2000 THEN '19-' ELSE '20-' END || MOD(year_of_birth, 100)
  ORDER year_of_birth - 1900;

-- Domain with annotations
CREATE DOMAIN hourly_wages AS NUMBER(10)
  DEFAULT ON NULL 15
  CONSTRAINT minimal_wage_c CHECK (hourly_wages >= 7 AND hourly_wages <= 1000)
  DISPLAY TO_CHAR(hourly_wages, '$999.99')
  ORDER (-1 * hourly_wages)
  ANNOTATIONS (Title 'Domain Annotation', Description 'Hourly wage rates');

-- Multi-column domain
CREATE DOMAIN US_city AS (
    name  AS VARCHAR2(30) ANNOTATIONS (Address),
    state AS VARCHAR2(2) ANNOTATIONS (Address),
    zip   AS NUMBER ANNOTATIONS (Address)
  )
  CONSTRAINT City_CK CHECK (state IN ('CA','AZ','TX') AND zip < 100000)
  DISPLAY name || ', ' || state || ', ' || TO_CHAR(zip)
  ORDER state || ', ' || TO_CHAR(zip) || ', ' || name
  ANNOTATIONS (Title 'Domain Annotation');

-- ENUM domain
CREATE DOMAIN order_status AS ENUM (
    New,
    Open,
    Shipped,
    Closed,
    Cancelled
  );

CREATE DOMAIN priority_level AS ENUM (
    Low,
    Medium,
    High,
    Critical
  ) ANNOTATIONS (Category 'Priority');

-- Flexible domain
CREATE FLEXIBLE DOMAIN expense_details (val1, val2, val3, val4)
  CHOOSE DOMAIN USING (typ VARCHAR2(10))
  FROM DECODE(typ,
    'Flight', flight_details(val1, val2, val3),
    'Meals', meals_details(val1, val2, val4),
    'Lodging', lodging_details(val1, val4));

-- Domain with JSON validation
CREATE DOMAIN w2_form AS JSON
  CONSTRAINT CHECK (VALUE IS JSON VALIDATE USING '{
    "title": "W2_form",
    "type": "object",
    "properties": {
      "social_security_number": {"type": "string"},
      "wages": {"type": "number", "minimum": 0}
    },
    "required": ["social_security_number", "wages"]
  }');

-- Domain with STRICT keyword
CREATE DOMAIN phone_number AS VARCHAR2(20) STRICT
  CONSTRAINT CHECK (REGEXP_LIKE(phone_number, '^\d{3}-\d{3}-\d{4}$'));

-- Domain with collation
CREATE DOMAIN case_insensitive_name AS VARCHAR2(100)
  COLLATE BINARY_CI;

-- IF NOT EXISTS clause
CREATE DOMAIN IF NOT EXISTS employee_id AS NUMBER(10);

-- Domain in different schema
CREATE DOMAIN hr.department_code AS VARCHAR2(10)
  CONSTRAINT CHECK (LENGTH(department_code) >= 3);
