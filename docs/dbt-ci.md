# dbt Slim CI pre-POC

Pull requests that change `exerp-dbt` are packaged from the exact head commit
and uploaded to the data-666 Airflow bucket. GitHub triggers
`dataflow_dbt_ci`, waits for MWAA and reports the result as the PR check. GitHub
has no database credentials.

The MWAA DAG uses the existing secret-backed `dataflow_redshift` connection and
the existing `dbt_project/applied.json` success marker. It downloads the exact
release archive recorded there and runs `dbt parse` against the deployed target
to create a temporary state manifest. It does not change `dataflow_auto_release`
or write a persistent baseline. Each PR writes to `ci_pr_<number>` and runs:

```text
dbt build --select state:modified+ --state <baseline> --defer
dbt run-operation query_ci_views
```

The query operation reads `svv_all_views`, so late-binding views are included.
Run artifacts are saved below `dbt_project/ci/pr-<number>/<commit>/results/`.

## How the comparison works

1. **Read the deployed release.** CI reads `dbt_project/applied.json`, which is
   written by the existing release process after a successful deployment. This
   identifies the exact commit, release archive, database and schema currently
   recorded as deployed on the test environment.
2. **Download the deployed project.** CI downloads that immutable release
   archive and verifies its SHA-256 checksum. At this point MWAA has two dbt
   projects: the deployed project and the project from the PR.
3. **Describe the deployed project.** CI runs `dbt parse` on the deployed
   project using its normal deployed schema. Parsing does not build or change
   database objects. It produces a temporary `manifest.json` describing the
   deployed models, their SQL checksums, dependencies and relation locations.
4. **Compare the PR.** `state:modified+` compares the PR project with that
   manifest. It selects new or changed models and the `+` also selects models
   downstream of them.
5. **Build the selection.** CI builds the selected models in
   `ci_pr_<number>`. With `--defer`, references to unchanged dbt models resolve
   to the deployed test objects instead of requiring the entire project to be
   rebuilt. Zero-ETL sources continue to use the normal dev source tables.

## Test-environment assumption

The release recorded in `applied.json` and deployed on the test environment
must be the latest approved version when CI starts. Otherwise Slim CI compares
the PR with an older project and `--defer` can resolve unchanged references to
outdated test objects.

For this pre-POC, keeping test on the latest approved deployment and verifying
that guarantee are operational prerequisites. Automating or enforcing them is
out of scope. CI trusts the existing `applied.json` marker.

## Fixture test scenario

The `pre-alpha-v3` release fixture contains:

```text
zeroetl.exerp.persons
├── person ──► person_by_center
└── person_untouched
```

After `pre-alpha-v3` is successfully applied, the CI test PR changes only
`person`. `state:modified+` should build and test `person` and
`person_by_center`. It should not select `person_untouched`. The CI query macro
should consequently report two queried views in `ci_pr_<number>`.

## Setup

Deploy `dags/dataflow_dbt_ci.py` to MWAA. A successful normal release must
already be recorded in `dbt_project/applied.json`; this is the existing
auto-release behavior. Slim CI fails with a setup message if no applied release
exists. All baseline files are temporary and remain inside the MWAA task.

The workflow defaults to `deployments/internal-workload-data-666.json`. Set the
repository variable `DATAFLOW_CI_DEPLOYMENT_CONFIG` to select another existing
deployment configuration. Its GitHub OIDC role must trust pull-request subjects
for this repository and allow S3 artifact access plus `airflow:InvokeRestApi`.
