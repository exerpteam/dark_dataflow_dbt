# Exerp dbt project

> **Release-flow fixture:** this branch intentionally limits `model-paths` to
> `models/release_test`. The fixture contains one late-binding `person` view
> over the confirmed `zeroetl.exerp.persons` source and no data tests. The full
> staging inventory remains under `models/staging`, but dbt does not parse or
> build it. This keeps `dbt build` deterministic while the S3/MWAA release flow
> is being tested.

The active fixture contains one model materialized as a Redshift view. The
`person` model reads the `persons` table through the `zeroetl` external schema.

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
   dbt build
   ```

The example profile uses environment variables so database credentials stay outside the repository. Keep your local `~/.dbt/profiles.yml` private.

## Project contents

- `models/release_test/person.sql`: the only active model.
- `models/release_test/sources.yml`: the minimal upstream source declaration.
- `models/staging/`: retained inventory, excluded from this fixture.
- `dbt_project.yml`: limits discovery to `models/release_test`.

## Publish this fixture

The data-666 deployment selects the `pre-alpha-v2` tag. After committing these
fixture changes, create that tag on the same commit and push both refs. The
release publisher always packages the tag rather than uncommitted or untagged
branch contents.
