# Dataflow deployment

GitHub publishes a tagged dbt project to S3, then triggers its MWAA release DAG.

## Configuration

Create one file per target:

```text
deployments/internal-workload-<system>.json
```

```json
{
  "release": "<existing-git-tag>",
  "project_path": "exerp-dbt",
  "aws_region": "<aws-region>",
  "aws_role_arn": "<github-deployment-role-arn>"
}
```

The filename derives:

| Resource | Value |
| --- | --- |
| Deployment | `internal-workload-<system>` |
| S3 bucket | `exerp-<system>-dataflow-airflow` |
| MWAA environment | `<system>-dataflow-airflow` |

The region and role ARN are non-secret. No matching GitHub Environment or AWS
keys in GitHub are required.

## Publish

- Automatic: merge a deployment JSON change to `main`.
- Manual: run **Publish Dataflow release** on `main` and enter the deployment
  name without its path or `.json` suffix.

The workflow validates every field and the Git tag before publishing:

```text
dbt_project/releases/exerp-dbt-<release>.tar.gz
dbt_project/deployment.json
```

Release archives are immutable. The pointer is updated only after the archive
is available, then GitHub triggers MWAA.

## Rollback

Change `release` to an older published tag. The workflow reuses the archive,
updates the pointer, and triggers MWAA. It rejects an archive whose contents do
not match the tag.

See [Automatic MWAA releases](automatic-release-dag.md) and
[GitHub to AWS access](cloud-access-overview.md).
