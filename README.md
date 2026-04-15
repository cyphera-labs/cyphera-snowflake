# cyphera-snowflake

[![CI](https://github.com/cyphera-labs/cyphera-snowflake/actions/workflows/ci.yml/badge.svg)](https://github.com/cyphera-labs/cyphera-snowflake/actions/workflows/ci.yml)
[![Security](https://github.com/cyphera-labs/cyphera-snowflake/actions/workflows/codeql.yml/badge.svg)](https://github.com/cyphera-labs/cyphera-snowflake/actions/workflows/codeql.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)

Format-preserving encryption for [Snowflake](https://www.snowflake.com/) — Java UDF powered by Cyphera.

Built on [`io.cyphera:cyphera`](https://central.sonatype.com/artifact/io.cyphera/cyphera) from Maven Central.

> This integration requires a Snowflake account. See below for deployment instructions.

## Build

### From source

```bash
mvn package -DskipTests
```

Produces `target/cyphera-snowflake-0.1.0.jar` (fat JAR with all dependencies).

### Via Docker

```bash
docker build -t cyphera-snowflake .
```

## Install / Deploy

### 1. Create a stage and upload the JAR

```sql
CREATE STAGE IF NOT EXISTS cyphera_stage;
PUT file://target/cyphera-snowflake-0.1.0.jar @cyphera_stage AUTO_COMPRESS=FALSE;
```

### 2. Register the functions

```sql
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
```

See `demo.sql` for the full registration script.

### 3. Policy configuration

Snowflake Java UDFs don't have filesystem access. Set the policy via the `CYPHERA_POLICY_FILE` environment variable or bundle `cyphera.json` inside the JAR at build time.

## Usage

```sql
-- Protect with a named policy
SELECT cyphera_protect('ssn', '123-45-6789');
-- → 'T01i6J-xF-07pX' (tagged, dashes preserved)

-- Access — tag tells Cyphera which policy to use
SELECT cyphera_access(cyphera_protect('ssn', '123-45-6789'));
-- → '123-45-6789'

-- Bulk protect
SELECT name, cyphera_protect('ssn', ssn) AS protected_ssn
FROM customers;
```

## Operations

### Policy Configuration

- Policy file bundled in JAR or accessible via `CYPHERA_POLICY_FILE`
- Policy changes require re-uploading the JAR and re-registering functions

### Monitoring

- Errors return `[error: message]` as the function output
- Check Snowflake query history for UDF errors

### Upgrading

1. Build a new JAR with the updated SDK version
2. Re-upload to the stage: `PUT file://target/cyphera-snowflake-0.1.0.jar @cyphera_stage AUTO_COMPRESS=FALSE OVERWRITE=TRUE;`
3. Re-register functions (or use `CREATE OR REPLACE`)

### Troubleshooting

- **Function not found** — JAR not uploaded or function not registered. Run `demo.sql`.
- **"Unknown policy"** — cyphera.json not accessible from the UDF runtime
- **Upload fails** — check that the stage exists and you have write permissions

## Policy File

```json
{
  "policies": {
    "ssn": { "engine": "ff1", "key_ref": "demo-key", "tag": "T01" },
    "credit_card": { "engine": "ff1", "key_ref": "demo-key", "tag": "T02" }
  },
  "keys": {
    "demo-key": { "material": "2B7E151628AED2A6ABF7158809CF4F3C" }
  }
}
```

## Future

- Snowpark native function registration
- External function via API gateway (alternative to JAR upload)
- Snowflake Native App packaging

## License

Apache 2.0 — Copyright 2026 Horizon Digital Engineering LLC
