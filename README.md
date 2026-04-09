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
-- Protect with a named policy
SELECT cyphera_protect('ssn', '123-45-6789');
-- → 'T01948-37-2150' (tagged, format preserved)

-- Access — tag tells Cyphera which policy to use, no policy name needed
SELECT cyphera_access(cyphera_protect('ssn', '123-45-6789'));
-- → '123-45-6789'
```
