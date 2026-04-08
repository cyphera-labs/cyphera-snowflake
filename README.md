# cyphera-snowflake

Cyphera format-preserving encryption UDFs for Snowflake.

## Build

```bash
mvn package -DskipTests
```

## Deploy

```sql
-- Create a stage
CREATE STAGE IF NOT EXISTS cyphera_stage;

-- Upload the JAR
PUT file://target/cyphera-snowflake-0.1.0.jar @cyphera_stage AUTO_COMPRESS=FALSE;

-- Register functions (see demo.sql)
```

## Usage

```sql
SELECT cyphera_protect('ssn', '123-45-6789');
-- Returns format-preserved encrypted SSN like '890-12-3456'

SELECT cyphera_access('ssn', cyphera_protect('ssn', '123-45-6789'));
-- Returns '123-45-6789'
```
