# Logical-replication CI POC

Logical replication uses the same release selection already established for
dbt. There is no separate logical-replication version field or version file.

Each environment selects one shared Git tag in its deployment file:

```json
{
  "release": "pre-alpha-v3",
  "project_path": "exerp-dbt",
  "aws_region": "eu-north-1",
  "aws_role_arn": "..."
}
```

The selected tag identifies both:

```text
exerp-dbt/
logical-replication/tables.json
```

The tag must contain both paths. `tables.json` is only the list of full tables
managed by this logical-replication POC. It does not replace the complete
combined publication, so unrelated existing members are never removed.

## CI flow

A pull request changes `release` in the environment's existing deployment JSON
to another existing Git tag. The logical-replication workflow:

1. validates the deployment file and resolves that tag to its immutable commit;
2. verifies the same tag contains the dbt project and logical table definition;
3. packages `tables.json` from the tag plus the transition runner;
4. uploads the checksum-bound artifact to S3;
5. triggers `dataflow_logical_replication_ci`; and
6. waits for the MWAA result.

The DAG reads `logical_replication/applied.json`, which follows the same marker
shape as dbt's `dbt_project/applied.json`: deployment, release, Git commit,
bucket, immutable artifact and checksum. It downloads the applied and requested
tagged definitions and calculates the transition. The marker advances only
after the database change and checks succeed.

Because logical replication cannot use an isolated schema like dbt, CI applies
the selected release directly to the DATA-666 environment. The environment's
deployment version must therefore change to run a different logical version.

## Forward and reverse transitions

For a table added between the applied and requested tags, the DAG creates the
subscriber table first, adds only that table to the publication, refreshes with
`copy_data = true`, waits for state `r`, and checks the apply worker and table.

Selecting an older tag is an explicit reverse transition. Tables present only
in the applied tag are removed from the publication, deregistered with
`copy_data = false`, and dropped from the subscriber. There is no automatic
rollback after CI; the requested release remains applied.

## First POC release

The currently selected `pre-alpha-v3` tag predates
`logical-replication/tables.json`, so it cannot be used as a logical release.
Use this sequence:

1. Commit the empty `tables.json`, create a baseline tag such as
   `pre-alpha-v4`, and select `pre-alpha-v4` in the deployment JSON. This
   creates the first logical applied marker without changing publication
   membership.
2. In the next commit, add the local fixture's table name to `tables.json`,
   create `pre-alpha-v5`, and select `pre-alpha-v5`. CI applies the added table.
3. To test rollback, change only the deployment release back to
   `pre-alpha-v4`. CI reads the empty definition from that older tag and
   applies the reverse transition.

The baseline run has no logical applied marker and therefore uses an empty
managed-table list. It then writes
`logical_replication/applied.json`. Later runs always use that successful tagged
release as their baseline.

Test-only source-table SQL remains in the local `Testing in CI` folder and is
not committed here.

## Access

The sandbox currently uses the existing admin-level Airflow connections:

- `data_666_rds` for Core;
- `dataflow_rds` for the subscriber.

Stage 3 will narrow these permissions. The MWAA role needs read/write access
under `logical_replication/` in the dataflow Airflow bucket.
