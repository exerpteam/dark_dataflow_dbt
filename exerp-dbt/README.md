# Exerp dbt project

This directory contains dbt staging models for Exerp using Amazon Redshift. Models are materialized as views in the target database and schema configured by the profile. For example, the `person` model reads the `persons` table through the `zeroetl` external schema.

## Set up

1. Create and activate a Python virtual environment, then install dbt:

   ```sh
   python -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. Create your local dbt profile directory and copy the example profile:

   ```sh
   mkdir -p ~/.dbt
   cp profiles.example.yml ~/.dbt/profiles.yml
   ```

3. Set the connection environment variables for your PostgreSQL database:

   ```sh
   export EXERP_DBT_HOST=localhost
   export EXERP_DBT_PORT=5439
   export EXERP_DBT_USER=your_user
   export EXERP_DBT_PASSWORD=your_password
   export EXERP_DBT_DATABASE=exerp
   export EXERP_DBT_SCHEMA=exerp
   ```

   The profile connects to the `exerp` database and writes models to its `exerp` schema by default. Override `EXERP_DBT_DATABASE` or `EXERP_DBT_SCHEMA` only when you intend to use a different target. The dbt source is declared as source `zeroetl`, database `zeroetl`, schema `exerp`, table `persons`. Models reading external tables use late-binding views.

4. Check the connection and build the model:

   ```sh
   dbt debug
   dbt run
   ```

The example profile uses environment variables so database credentials stay outside the repository. Keep your local `~/.dbt/profiles.yml` private.

## Epoch date and time fields

Some source columns are stored as bigint epoch milliseconds even though they represent dates or instants. The source column metadata marks these with `semantic_type: epoch_milliseconds_timestamp` or `semantic_type: epoch_milliseconds_date`. Staging models use the macros in `macros/exerp_time_conversions.sql` to convert those values while retaining the existing output column names.

Instants use the related center's `time_zone` when the source row provides a center key. Scoped rows use a center only when `scope_type = 'C'`. Global records without a center relationship are converted in UTC. Calendar-date fields are converted to `DATE` in UTC and are not shifted to a local time zone. Other bigint values, including IDs, counters, versions, and durations, remain numeric.

## Project contents

- `models/staging/exerp.sql`: the initial staging model.
- `models/staging/sources.yml`: declaration of the upstream source table.
- `analyses/sample_query.sql`: a sample query using the staging model; compile it with `dbt compile`.
- `dbt_project.yml`: project settings and default staging materialization.
