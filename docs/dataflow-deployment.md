# Dataflow deployment

The workflow publishes a tagged dbt project to the S3 bucket associated with a
GitHub Environment. Publishing does not run dbt or update Redshift.

## Deployment contract

Create one file per environment:

```text
deployments/internal-workload-<system>.json
```

```json
{
  "release": "<existing-git-tag>",
  "project_path": "exerp-dbt"
}
```

The filename controls the deployment target:

| Derived value | Format |
| --- | --- |
| GitHub Environment | `internal-workload-<system>` |
| S3 bucket | `exerp-<system>-dataflow-airflow` |
| S3 prefix | `dbt_project` |

The GitHub Environment must already exist. Configure these environment
variables:

- `AWS_ROLE_ARN`
- `AWS_REGION`

The AWS role needs GitHub OIDC trust plus `s3:GetObject` and `s3:PutObject` for
`arn:aws:s3:::exerp-<system>-dataflow-airflow/dbt_project/*`. Add KMS permissions
when the bucket uses a customer-managed key. It also needs
`airflow:InvokeRestApi` for the matching MWAA environment's Airflow role so the
workflow can start the release DAG after publishing.

## Publish

- Merge a deployment JSON change to `main` to publish automatically.
- For a manual run, open **Actions > Publish Dataflow release**, select `main`,
  and enter the deployment name without `deployments/` or `.json`.
- A push changing multiple deployment files creates one independent job per
  environment.

Before publishing, the workflow verifies that the environment exists, all JSON
fields are present, and the release tag resolves to a commit. After publishing,
it triggers the matching MWAA release DAG directly.

## S3 output

```text
dbt_project/releases/exerp-dbt-<release>.tar.gz
dbt_project/deployment.json
```

Release archives are immutable. `deployment.json` is updated only after the
archive upload succeeds and contains the selected environment, release, commit,
artifact key, bucket, and checksum.

The Airflow consumer must read the pointer once per run, verify the checksum,
extract into an isolated writable directory, and supply runtime dbt credentials.
An S3 publish is not proof that dbt completed successfully.

See [Automatic MWAA releases](automatic-release-dag.md) for the scheduled release
DAG and its environment configuration.

## Rollback

Set `release` to a previously published tag and publish the deployment again.
The workflow reuses the matching immutable archive, updates `deployment.json`,
and triggers MWAA without uploading the archive again. An existing archive with
different contents is rejected. Objects absent from the older release may
require separately reviewed cleanup.
