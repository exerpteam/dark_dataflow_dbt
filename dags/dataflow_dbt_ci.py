"""Build changed dbt models from a PR in an isolated Redshift schema."""
import hashlib
import json
import logging
import os
import re
import shutil
import subprocess
import tarfile
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path, PurePosixPath

from airflow.sdk import dag, get_current_context, task


CONNECTION_ID = 'dataflow_redshift'
APPLIED_KEY = 'dbt_project/applied.json'
DBT_THREADS = 4
DEPLOYMENT_PATTERN = re.compile(
    r'internal-workload-(?P<system>[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)'
)
COMMIT_SHA = re.compile(r'[0-9a-f]{40}')
SHA256 = re.compile(r'[0-9a-f]{64}')
SIMPLE_NAME = re.compile(r'[A-Za-z0-9][A-Za-z0-9._-]*')
SCHEMA_NAME = re.compile(r'[a-z][a-z0-9_]*')


def trigger_config(raw):
    if not isinstance(raw, dict):
        raise ValueError('DAG run configuration must be a JSON object')
    required = {
        'deployment', 'bucket', 'pr_number', 'commit_sha',
        'artifact_key', 'artifact_sha256',
    }
    missing = sorted(required - set(raw))
    if missing:
        raise ValueError(f'DAG run configuration is missing fields: {missing}')
    match = DEPLOYMENT_PATTERN.fullmatch(raw['deployment'])
    if not match:
        raise ValueError('Invalid deployment name')
    expected_bucket = f'exerp-{match.group("system")}-dataflow-airflow'
    if raw['bucket'] != expected_bucket:
        raise ValueError('Trigger points to a different bucket')
    pr_number = raw['pr_number']
    commit = raw['commit_sha']
    checksum = raw['artifact_sha256']
    if not isinstance(pr_number, int) or pr_number < 1:
        raise ValueError('Invalid PR number')
    if not isinstance(commit, str) or not COMMIT_SHA.fullmatch(commit):
        raise ValueError('Invalid commit SHA')
    if not isinstance(checksum, str) or not SHA256.fullmatch(checksum):
        raise ValueError('Invalid artifact checksum')
    expected_key = f'dbt_project/ci/pr-{pr_number}/{commit}/project.tar.gz'
    if raw['artifact_key'] != expected_key:
        raise ValueError('Artifact key does not match PR and commit')
    return raw


def file_sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def extract_project(archive_path, destination):
    with tarfile.open(archive_path, 'r:gz') as archive:
        members = archive.getmembers()
        if len(members) > 20_000:
            raise ValueError('CI archive contains too many entries')
        if sum(member.size for member in members) > 1024 ** 3:
            raise ValueError('CI archive exceeds 1 GiB uncompressed')
        seen = set()
        for member in members:
            path = PurePosixPath(member.name)
            if path == PurePosixPath('.') and member.isdir():
                continue
            if path.is_absolute() or '..' in path.parts or not path.parts:
                raise ValueError('Unsafe archive path')
            if path in seen:
                raise ValueError('Duplicate archive path')
            seen.add(path)
            if not (member.isfile() or member.isdir()):
                raise ValueError('Archive links and special files are unsupported')
        for member in members:
            path = PurePosixPath(member.name)
            if path == PurePosixPath('.') and member.isdir():
                continue
            target = destination.joinpath(*path.parts)
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with archive.extractfile(member) as source, target.open('wb') as output:
                    shutil.copyfileobj(source, output)


def get_applied_release(s3, config):
    from botocore.exceptions import ClientError

    try:
        response = s3.get_object(Bucket=config['bucket'], Key=APPLIED_KEY)
    except ClientError as error:
        if error.response.get('Error', {}).get('Code') in {
            '404', 'NoSuchKey', 'NotFound'
        }:
            raise RuntimeError(
                'No applied dbt release exists. Run dataflow_auto_release '
                'successfully before using Slim CI.'
            ) from error
        raise
    with response['Body'] as body:
        applied = json.loads(body.read())
    required = {
        'deployment', 'release', 'commit', 'bucket', 'artifact', 'sha256',
        'database', 'schema',
    }
    if not isinstance(applied, dict) or not required.issubset(applied):
        raise ValueError('Applied release marker is incomplete')
    if (
        applied['deployment'] != config['deployment']
        or applied['bucket'] != config['bucket']
    ):
        raise ValueError('Applied release belongs to another deployment')
    if not isinstance(applied['release'], str) or not SIMPLE_NAME.fullmatch(
        applied['release']
    ):
        raise ValueError('Applied release has an invalid name')
    expected_artifact = (
        f'dbt_project/releases/exerp-dbt-{applied["release"]}.tar.gz'
    )
    if applied['artifact'] != expected_artifact:
        raise ValueError('Applied release has an invalid artifact key')
    if not isinstance(applied['commit'], str) or not COMMIT_SHA.fullmatch(
        applied['commit']
    ):
        raise ValueError('Applied release has an invalid commit')
    if not isinstance(applied['sha256'], str) or not SHA256.fullmatch(
        applied['sha256']
    ):
        raise ValueError('Applied release has an invalid checksum')
    if not isinstance(applied['schema'], str) or not SCHEMA_NAME.fullmatch(
        applied['schema']
    ):
        raise ValueError('Applied release has an invalid schema')
    return applied


def upload_results(s3, bucket, prefix, project):
    for relative in ('target/manifest.json', 'target/run_results.json', 'logs/dbt.log'):
        path = project / relative
        if path.is_file():
            s3.upload_file(str(path), bucket, f'{prefix}/{relative}')


@dag(
    dag_id='dataflow_dbt_ci',
    description='Slim CI for a Dataflow dbt pull request',
    schedule=None,
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    tags=['dataflow', 'dbt', 'ci'],
)
def dataflow_dbt_ci():
    @task(retries=0, execution_timeout=timedelta(hours=2))
    def build_changed_models():
        import boto3

        context = get_current_context()
        config = trigger_config(context['dag_run'].conf)
        s3 = boto3.client('s3')
        connection = context['conn'].get(CONNECTION_ID)
        database = connection.schema
        if not all((connection.host, database, connection.login,
                    connection.password)):
            raise ValueError(
                f'Connection {CONNECTION_ID!r} requires host, database, login, '
                'and password'
            )
        executable = shutil.which('dbt')
        if not executable:
            raise RuntimeError('dbt is not installed in the MWAA environment')

        schema = f'ci_pr_{config["pr_number"]}'
        result_prefix = (
            f'dbt_project/ci/pr-{config["pr_number"]}/'
            f'{config["commit_sha"]}/results'
        )
        logging.info(
            'Running dbt Slim CI for PR %s commit %s in schema %s',
            config['pr_number'], config['commit_sha'], schema,
        )
        with tempfile.TemporaryDirectory(prefix='dataflow-dbt-ci-') as directory:
            work = Path(directory)
            archive = work / 'project.tar.gz'
            s3.download_file(config['bucket'], config['artifact_key'], str(archive))
            if file_sha256(archive) != config['artifact_sha256']:
                raise ValueError('CI archive checksum mismatch')
            project = work / 'project'
            project.mkdir()
            extract_project(archive, project)
            if not (project / 'dbt_project.yml').is_file():
                raise ValueError('dbt_project.yml is missing from archive root')

            baseline = get_applied_release(s3, config)
            if baseline['database'] != database:
                raise ValueError(
                    'Applied release database does not match the Redshift connection'
                )
            baseline_archive = work / 'applied-release.tar.gz'
            s3.download_file(
                config['bucket'], baseline['artifact'], str(baseline_archive)
            )
            if file_sha256(baseline_archive) != baseline['sha256']:
                raise ValueError('Applied release archive checksum mismatch')
            baseline_project = work / 'applied-project'
            baseline_project.mkdir()
            extract_project(baseline_archive, baseline_project)
            if not (baseline_project / 'dbt_project.yml').is_file():
                raise ValueError(
                    'dbt_project.yml is missing from the applied release archive'
                )
            state = work / 'baseline'
            state.mkdir()

            profiles = work / 'profiles'
            profiles.mkdir(mode=0o700)
            profile = {
                'dataflow': {
                    'target': 'ci',
                    'outputs': {
                        'ci': {
                            'type': 'redshift',
                            'host': connection.host,
                            'port': connection.port or 5439,
                            'dbname': database,
                            'schema': schema,
                            'threads': DBT_THREADS,
                            'user': "{{ env_var('DBT_ENV_SECRET_DATAFLOW_USER') }}",
                            'password': "{{ env_var('DBT_ENV_SECRET_DATAFLOW_PASSWORD') }}",
                            'sslmode': 'require',
                            'connect_timeout': 10,
                        },
                        'deployed': {
                            'type': 'redshift',
                            'host': connection.host,
                            'port': connection.port or 5439,
                            'dbname': database,
                            'schema': baseline['schema'],
                            'threads': DBT_THREADS,
                            'user': "{{ env_var('DBT_ENV_SECRET_DATAFLOW_USER') }}",
                            'password': "{{ env_var('DBT_ENV_SECRET_DATAFLOW_PASSWORD') }}",
                            'sslmode': 'require',
                            'connect_timeout': 10,
                        }
                    },
                }
            }
            (profiles / 'profiles.yml').write_text(
                json.dumps(profile), encoding='utf-8'
            )
            env = os.environ.copy()
            env['DBT_ENV_SECRET_DATAFLOW_USER'] = connection.login
            env['DBT_ENV_SECRET_DATAFLOW_PASSWORD'] = connection.password
            env['DBT_SEND_ANONYMOUS_USAGE_STATS'] = 'false'

            def dbt(project_dir, target, *arguments, timeout=6900):
                subprocess.run(
                    [
                        executable, *arguments,
                        '--project-dir', str(project_dir),
                        '--profiles-dir', str(profiles),
                        '--target', target,
                    ],
                    cwd=project_dir, env=env, check=True, timeout=timeout,
                )

            try:
                if any(
                    (baseline_project / name).exists()
                    for name in ('packages.yml', 'dependencies.yml')
                ):
                    dbt(
                        baseline_project, 'deployed', 'deps', timeout=600
                    )
                dbt(
                    baseline_project, 'deployed', 'parse',
                    '--no-partial-parse', '--target-path', str(state),
                    timeout=600,
                )
                if any(
                    (project / name).exists()
                    for name in ('packages.yml', 'dependencies.yml')
                ):
                    dbt(project, 'ci', 'deps', timeout=600)
                dbt(project, 'ci', 'debug', timeout=120)
                dbt(
                    project, 'ci', 'build', '--select', 'state:modified+',
                    '--state', str(state), '--defer',
                )
                dbt(project, 'ci', 'run-operation', 'query_ci_views')
            finally:
                upload_results(
                    s3, config['bucket'], result_prefix, project
                )
        return {
            'pr_number': config['pr_number'],
            'commit': config['commit_sha'],
            'schema': schema,
            'baseline_commit': baseline['commit'],
        }

    build_changed_models()


dataflow_dbt_ci()
