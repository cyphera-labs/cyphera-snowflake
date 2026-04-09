-- Cyphera Snowflake UDF Demo
-- Prerequisites: upload JAR to a stage
--   PUT file://target/cyphera-snowflake-0.1.0.jar @cyphera_stage AUTO_COMPRESS=FALSE;

-- Register functions
CREATE OR REPLACE FUNCTION cyphera_protect(policy_name VARCHAR, value VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVA
HANDLER = 'io.cyphera.snowflake.CypheraUDF.cyphera_protect'
IMPORTS = ('@cyphera_stage/cyphera-snowflake-0.1.0.jar');

CREATE OR REPLACE FUNCTION cyphera_access(protected_value VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVA
HANDLER = 'io.cyphera.snowflake.CypheraUDF.cyphera_access'
IMPORTS = ('@cyphera_stage/cyphera-snowflake-0.1.0.jar');

CREATE OR REPLACE FUNCTION cyphera_access(policy_name VARCHAR, protected_value VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVA
HANDLER = 'io.cyphera.snowflake.CypheraUDF.cyphera_access'
IMPORTS = ('@cyphera_stage/cyphera-snowflake-0.1.0.jar');

-- Protect with a named policy (output is tagged)
SELECT cyphera_protect('ssn', '123-45-6789') AS protected_ssn;

-- Access — tag tells Cyphera which policy to use, no policy name needed
SELECT cyphera_access(cyphera_protect('ssn', '123-45-6789')) AS accessed_ssn;

-- Bulk example
SELECT
    name,
    ssn AS original_ssn,
    cyphera_protect('ssn', ssn) AS protected_ssn
FROM (
    SELECT 'Alice' AS name, '123-45-6789' AS ssn
    UNION ALL SELECT 'Bob', '987-65-4321'
    UNION ALL SELECT 'Carol', '555-12-3456'
);
