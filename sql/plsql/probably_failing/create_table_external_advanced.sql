-- Advanced CREATE EXTERNAL TABLE examples
-- Testing additional ORACLE_LOADER and ORACLE_DATAPUMP features

-- External table with BADFILE, DISCARDFILE, and LOGFILE
CREATE TABLE emp_ext_detailed (
    emp_id NUMBER,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    salary NUMBER
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY ext_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        BADFILE 'emp_bad.txt'
        DISCARDFILE 'emp_dis.txt'
        LOGFILE 'emp_load.log'
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('employees.csv')
)
REJECT LIMIT 100;

-- External table with SKIP and LOAD parameters
CREATE TABLE sales_ext (
    sale_id NUMBER,
    product_id NUMBER,
    sale_date DATE,
    amount NUMBER(10,2)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        LOAD 1000
        FIELDS TERMINATED BY '|'
        (sale_id, product_id, sale_date CHAR(10) DATE_FORMAT DATE "YYYY-MM-DD", amount)
    )
    LOCATION ('sales_data.txt')
)
REJECT LIMIT UNLIMITED;

-- External table with PREPROCESSOR
CREATE TABLE logs_compressed (
    log_id NUMBER,
    log_date DATE,
    log_message VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY log_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        PREPROCESSOR exec_dir:'gunzip'
        FIELDS TERMINATED BY '\t'
    )
    LOCATION ('logs.txt.gz')
)
REJECT LIMIT UNLIMITED;

-- External table with character set specification
CREATE TABLE intl_data (
    id NUMBER,
    description VARCHAR2(200)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY intl_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        CHARACTERSET UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('international.csv')
);

-- External table with DATE FORMAT
CREATE TABLE events_ext (
    event_id NUMBER,
    event_name VARCHAR2(100),
    event_date DATE,
    event_time TIMESTAMP
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY events_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        (
            event_id,
            event_name,
            event_date CHAR(10) DATE_FORMAT DATE "DD/MM/YYYY",
            event_time CHAR(20) DATE_FORMAT TIMESTAMP "DD-MON-YYYY HH24:MI:SS"
        )
    )
    LOCATION ('events.dat')
);

-- External table with ORACLE_DATAPUMP and AS SELECT
CREATE TABLE emp_export
ORGANIZATION EXTERNAL (
    TYPE ORACLE_DATAPUMP
    DEFAULT DIRECTORY export_dir
    LOCATION ('emp_export.dmp')
)
AS SELECT * FROM employees WHERE department_id = 50;

-- External table with multiple location files
CREATE TABLE multi_file_ext (
    id NUMBER,
    data VARCHAR2(200)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
    )
    LOCATION ('file1.csv', 'file2.csv', 'file3.csv')
);

-- External table with TRIM specifications
CREATE TABLE trimmed_data (
    id NUMBER,
    code VARCHAR2(20),
    description VARCHAR2(200)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY '|'
        LTRIM RTRIM
        (id, code CHAR(20), description CHAR(200))
    )
    LOCATION ('data.txt')
);

-- External table with ORACLE_DATAPUMP and VERSION
CREATE TABLE version_export
ORGANIZATION EXTERNAL (
    TYPE ORACLE_DATAPUMP
    DEFAULT DIRECTORY dp_dir
    ACCESS PARAMETERS (
        VERSION '19.0.0'
    )
    LOCATION ('export_v19.dmp')
)
AS SELECT * FROM large_table WHERE rownum <= 10000;

-- External table with NULL IF clause
CREATE TABLE nullable_ext (
    id NUMBER,
    code VARCHAR2(20),
    value NUMBER
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        (
            id,
            code NULLIF code = 'NULL',
            value NULLIF value = '0'
        )
    )
    LOCATION ('data.csv')
);
