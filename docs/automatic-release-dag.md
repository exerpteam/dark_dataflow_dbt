# Automatic MWAA releases

After publishing `dbt_project/deployment.json`, GitHub Actions triggers
`dataflow_auto_release` through the MWAA REST API. The DAG has no polling
schedule and requires no Lambda or S3 event notification.

## Airflow configuration

No Airflow Variable is required. GitHub passes the deployment, bucket, and
pointer key when it triggers the DAG. AWS supplies the current region.

The secret-backed `dataflow_redshift` connection must provide the host, port,
writable database in its **Schema** field, username, and password. The destination
schema defaults to `exerp`. Override it when needed through Extra JSON:

```json
{"output_schema": "<destination-schema>"}
```

Do not use the read-only Zero-ETL database as the destination. Releases always
run `dbt build` for the complete project with four threads.

The MWAA execution role needs:

- `s3:GetObject` for `dbt_project/deployment.json` and release archives.
- `s3:GetObject` and `s3:PutObject` for `dbt_project/applied.json`.
- KMS decrypt/encrypt permissions when applicable.

Upload the DAG to the MWAA DAG folder and enable `dataflow_auto_release` in
Airflow. Install a tested, pinned `dbt-redshift` version through the MWAA
requirements file; the DAG never installs packages at runtime.

## GitHub trigger

The GitHub deployment role requires `airflow:InvokeRestApi` and, when required
by the MWAA access mode, `airflow:CreateWebLoginToken`. The workflow derives the
MWAA environment name from the deployment:

```text
internal-workload-<system> -> <system>-dataflow-airflow
```

The trigger runs only after the archive and pointer uploads succeed. Rerunning a
workflow is safe because the DAG compares the pointer with `applied.json` before
running dbt.

## Release behavior

1. GitHub publishes an immutable archive and updates `deployment.json`.
2. GitHub triggers the DAG through MWAA `InvokeRestApi`.
3. The DAG snapshots and validates the current pointer.
4. It downloads the archive, verifies SHA-256, and extracts it safely.
5. It runs `dbt debug`, then `dbt build` for the complete project.
6. Only a successful run updates `applied.json`.

A failed release remains unapplied. Retry the failed DAG run or rerun the GitHub
workflow after correcting the issue. `max_active_runs=1` prevents concurrent
releases in one environment.
