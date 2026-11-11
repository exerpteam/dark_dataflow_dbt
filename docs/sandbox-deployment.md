# Dataflow release publishing

This workflow publishes the selected tagged dbt project to S3. It does not yet
execute dbt or change Redshift views. Existing release tags are not modified.

## One-time setup

1. Use the existing GitHub Environment `internal-workload-data-666`.
2. Set environment variables `AWS_ROLE_ARN` and `AWS_REGION` on that
   environment.
3. Cloud provisions the AWS role and GitHub OIDC trust for this repository's
   `internal-workload-data-666` environment, using the subject format issued
   for this repository.
   The role needs `s3:PutObject` and `s3:GetObject` on
   `arn:aws:s3:::exerp-data-666-dataflow-airflow/dbt_project/*`.
   Add KMS permissions if required by the bucket encryption policy.
4. Merge this change to `main` and open Actions > Publish Dataflow release > Run
   workflow, selecting `main` and entering `internal-workload-data-666` as the
   deployment. Alternatively, changing any `deployments/*.json` file on `main`
   triggers publishing for each changed deployment file.

The bucket is derived rather than configured: the portion after
`internal-workload-` in the deployment filename is the system name. Therefore,
`internal-workload-data-666.json` publishes to
`exerp-data-666-dataflow-airflow`. This avoids a deployment file pointing at a
bucket belonging to another system. S3 objects always use the fixed
`dbt_project` prefix.

Each deployment filename selects its matching GitHub Environment, and its
`release` field selects the version published there. If several deployment files
change in one push, the workflow publishes them independently using matrix jobs.
The discovery job verifies that every selected environment already exists before
the publishing jobs reference it.

## Files in S3

- `dbt_project/releases/exerp-dbt-pre-alpha-v1.tar.gz`: tagged `exerp-dbt/`
  contents, with `dbt_project.yml` at the archive root.
- `dbt_project/deployment.json`: selected release, commit SHA, artifact key and
  SHA-256 checksum. This records the requested release, not deployment success.

The archive is created conditionally and never replaced. Rerunning the same
release is allowed only if its checksum and commit match. The pointer is updated
after archive upload succeeds. A failed publish leaves the previous pointer in
place. Previously published archives remain available for rollback.

## MWAA integration still required

Use a DAG compatible with the environment's Airflow version. At run start, read
`dbt_project/deployment.json` once and retain the complete selection in XCom so
execution task retries use the same release. In one execution task, download,
verify the checksum, extract into an isolated writable directory, and run dbt.
Do not share `/tmp` files between separate worker tasks. Validate archive paths
and reject symlinks before extraction.

The project uses profile `dataflow`; `profiles.example.yml` defines target `dev`
and uses EXERP_DBT_* environment variables. Supply a runtime `profiles.yml` and
credentials from the sandbox's configured secret/connection. Do not commit them.
Choose a dedicated test schema explicitly: the example defaults to `exerp`.
Pin the dbt Core and Redshift adapter versions installed in MWAA; the project's
requirements currently permit a broad adapter range. Set logs and target paths
under the writable execution directory.

The MWAA execution role needs read access to the pointer and archives (plus KMS
decrypt if applicable). Record successful release/commit separately only after
dbt completes. Keep failures and logs; a failed build can leave partially updated
views. No application-version compatibility gate is implemented in this first
publishing step. Do not interpret S3 upload or pointer update as deployment success.

## Upgrade or rollback

Change `release` in `deployments/internal-workload-data-666.json` through a PR.
Publishing reads the configuration and scripts from the workflow checkout on
`main`, and the dbt code from the selected Git tag. Retain referenced archives
while an MWAA run may use them. Rolling back views requires an explicit MWAA run
with the previous release; views absent from that previous release require
separately reviewed cleanup.
