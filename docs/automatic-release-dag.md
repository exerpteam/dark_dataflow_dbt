# Automatic MWAA releases

GitHub triggers `dataflow_auto_release` through MWAA `InvokeRestApi` after the
S3 release and pointer are published. No polling, Lambda, S3 event, or Airflow
Variable is required.

## Airflow setup

- Upload and enable `dataflow_auto_release`.
- Install a tested, pinned `dbt-redshift` version in MWAA requirements.
- Configure the secret-backed `dataflow_redshift` connection with host, port,
  username, password, and the writable database in **Schema**.
- The destination schema defaults to `exerp`. Override it with:

```json
{"output_schema": "<destination-schema>"}
```

Do not use the read-only Zero-ETL database as the destination.

## Release flow

1. Validate `deployment.json`.
2. Skip if the same release is already recorded in `applied.json`.
3. Download the immutable archive and verify its SHA-256 checksum.
4. Run `dbt debug`, then `dbt build` with four threads.
5. Write `applied.json` only after success.

The DAG allows one active run and retries once. A failed build remains
unapplied; retry the DAG or rerun the GitHub workflow after fixing the cause.

## MWAA execution role

- `s3:GetObject` for the pointer, archive, and `applied.json`.
- `s3:PutObject` for `dbt_project/applied.json`.
- KMS decrypt/encrypt permissions when applicable.

See [GitHub to AWS access](cloud-access-overview.md) for the GitHub deployment
role.
