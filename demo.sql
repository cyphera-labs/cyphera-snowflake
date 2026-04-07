-- Cyphera Snowflake UDF Demo
-- Prerequisites: upload JAR to a stage
--   PUT file://target/cyphera-snowflake-0.1.0.jar @cyphera_stage AUTO_COMPRESS=FALSE;

CREATE OR REPLACE FUNCTION cyphera_protect(policy_name VARCHAR, value VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVA
HANDLER = 'io.cyphera.snowflake.CypheraUDF.cyphera_protect'
IMPORTS = ('@cyphera_stage/cyphera-snowflake-0.1.0.jar');

CREATE OR REPLACE FUNCTION cyphera_unprotect(policy_name VARCHAR, value VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVA
HANDLER = 'io.cyphera.snowflake.CypheraUDF.cyphera_unprotect'
IMPORTS = ('@cyphera_stage/cyphera-snowflake-0.1.0.jar');

CREATE OR REPLACE FUNCTION cyphera_ff1_encrypt(value VARCHAR, key_hex VARCHAR, alphabet VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVA
HANDLER = 'io.cyphera.snowflake.CypheraUDF.cyphera_ff1_encrypt'
IMPORTS = ('@cyphera_stage/cyphera-snowflake-0.1.0.jar');

CREATE OR REPLACE FUNCTION cyphera_ff1_decrypt(value VARCHAR, key_hex VARCHAR, alphabet VARCHAR)
RETURNS VARCHAR
LANGUAGE JAVA
HANDLER = 'io.cyphera.snowflake.CypheraUDF.cyphera_ff1_decrypt'
IMPORTS = ('@cyphera_stage/cyphera-snowflake-0.1.0.jar');

-- Test queries
SELECT cyphera_protect('ssn', '123-45-6789') AS encrypted_ssn;
SELECT cyphera_unprotect('ssn', cyphera_protect('ssn', '123-45-6789')) AS decrypted_ssn;

SELECT
    name,
    ssn AS original_ssn,
    cyphera_protect('ssn', ssn) AS protected_ssn
FROM (
    SELECT 'Alice' AS name, '123-45-6789' AS ssn
    UNION ALL SELECT 'Bob', '987-65-4321'
    UNION ALL SELECT 'Carol', '555-12-3456'
);
