"""Automatically apply the dbt release selected in the environment's S3 bucket."""
import hashlib
import json
import logging
import re
import shutil
import subprocess
import tarfile
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path, PurePosixPath

from airflow.sdk import dag, get_current_context, task


POINTER_KEY = 'dbt_project/deployment.json'
APPLIED_KEY = 'dbt_project/applied.json'
CONNECTION_ID = 'dataflow_redshift'
DBT_COMMAND = 'build'
DBT_THREADS = 4
DEFAULT_OUTPUT_SCHEMA = 'exerp'
DEPLOYMENT_PATTERN = re.compile(
    r'internal-workload-(?P<system>[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)'
)
SIMPLE_NAME = re.compile(r'[A-Za-z0-9][A-Za-z0-9._-]*')
SCHEMA_NAME = re.compile(r'[a-z][a-z0-9_]*')
SHA256 = re.compile(r'[0-9a-f]{64}')
COMMIT_SHA = re.compile(r'[0-9a-f]{40}')


def trigger_config(raw):
    """Validate the deployment target supplied by the publishing workflow."""
    if not isinstance(raw, dict):
        raise ValueError('DAG run configuration must be a JSON object')
    required = {'deployment', 'bucket', 'key'}
    missing = sorted(required - set(raw))
    if missing:
        raise ValueError(f'DAG run configuration is missing fields: {missing}')

    deployment = raw['deployment']
    match = DEPLOYMENT_PATTERN.fullmatch(deployment)
    if not match:
        raise ValueError('Invalid deployment name')
    bucket = f'exerp-{match.group("system")}-dataflow-airflow'
    if raw['bucket'] != bucket:
        raise ValueError('Trigger points to a different bucket')
    if raw['key'] != POINTER_KEY:
        raise ValueError('Trigger points to a different S3 key')

    return {
        'deployment': deployment,
        'bucket': bucket,
    }


def validate_selection(selection, config):
    """Validate the untrusted S3 pointer before using it."""
    if not isinstance(selection, dict):
        raise ValueError('Release pointer must be a JSON object')
    required = {'deployment', 'release', 'commit', 'bucket', 'artifact', 'sha256'}
    missing = sorted(required - set(selection))
    if missing:
        raise ValueError(f'Release pointer is missing fields: {missing}')
    if selection['deployment'] != config['deployment']:
        raise ValueError('Release points to a different deployment')
    if selection['bucket'] != config['bucket']:
        raise ValueError('Release points to a different bucket')
    if not isinstance(selection['release'], str) or not SIMPLE_NAME.fullmatch(
        selection['release']
    ):
        raise ValueError('Invalid release name')
    expected_key = f'dbt_project/releases/exerp-dbt-{selection["release"]}.tar.gz'
    if selection['artifact'] != expected_key:
        raise ValueError('Invalid release archive key')
    if not isinstance(selection['commit'], str) or not COMMIT_SHA.fullmatch(
        selection['commit']
    ):
        raise ValueError('Invalid commit SHA')
    if not isinstance(selection['sha256'], str) or not SHA256.fullmatch(
        selection['sha256']
    ):
        raise ValueError('Invalid release checksum')
    return selection


def is_applied(selection, applied):
    """Return whether the success marker represents this exact release."""
    return isinstance(applied, dict) and all(
        applied.get(field) == selection[field]
        for field in ('deployment', 'release', 'commit', 'artifact', 'sha256')
    )


def file_sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def extract_project(archive_path, destination):
    """Extract regular files/directories after validating the complete archive."""
    with tarfile.open(archive_path, 'r:gz') as archive:
        members = archive.getmembers()
        if len(members) > 20_000:
            raise ValueError('Release archive contains too many entries')
        if sum(member.size for member in members) > 1024 ** 3:
            raise ValueError('Release archive exceeds 1 GiB uncompressed')
        paths = set()
        for member in members:
            path = PurePosixPath(member.name)
            if path.is_absolute() or '..' in path.parts or not path.parts:
                raise ValueError('Unsafe archive path')
            if path in paths:
                raise ValueError('Duplicate archive path')
            paths.add(path)
            if not (member.isfile() or member.isdir()):
                raise ValueError('Archive links and special files are unsupported')
        for member in members:
            target = destination.joinpath(*PurePosixPath(member.name).parts)
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
                continue
            target.parent.mkdir(parents=True, exist_ok=True)
            with archive.extractfile(member) as source, target.open('wb') as output:
                shutil.copyfileobj(source, output)


def get_optional_json(s3, bucket, key):
    from botocore.exceptions import ClientError

    try:
        response = s3.get_object(Bucket=bucket, Key=key)
    except ClientError as error:
        if error.response.get('Error', {}).get('Code') in {
            '404', 'NoSuchKey', 'NotFound'
        }:
            return None
        raise
    with response['Body'] as body:
        return json.loads(body.read())


@dag(
    dag_id='dataflow_auto_release',
    description='Apply a newly selected Dataflow dbt release',
    schedule=None,
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    tags=['dataflow', 'dbt', 'release'],
)
def dataflow_auto_release():
    @task(
        retries=1,
        retry_delay=timedelta(minutes=2),
        execution_timeout=timedelta(hours=2),
    )
    def reconcile_release():
        import boto3
        from airflow.exceptions import AirflowSkipException

        context = get_current_context()
        config = trigger_config(context['dag_run'].conf)
        s3 = boto3.client('s3')
        selection = get_optional_json(s3, config['bucket'], POINTER_KEY)
        if selection is None:
            raise AirflowSkipException('No Dataflow release has been selected')
        selection = validate_selection(selection, config)
        applied = get_optional_json(s3, config['bucket'], APPLIED_KEY)
        if is_applied(selection, applied):
            raise AirflowSkipException(
                f'Release {selection["release"]} is already applied'
            )

        connection = context['conn'].get(CONNECTION_ID)
        database = connection.schema
        output_schema = connection.extra_dejson.get(
            'output_schema', DEFAULT_OUTPUT_SCHEMA
        )
        if not all((connection.host, database, connection.login,
                    connection.password)):
            raise ValueError(
                f'Connection {CONNECTION_ID!r} requires host, database, login, '
                'and password'
            )
        if not isinstance(output_schema, str) or not SCHEMA_NAME.fullmatch(
            output_schema
        ):
            raise ValueError('Invalid output_schema in Redshift connection')
        executable = shutil.which('dbt')
        if not executable:
            raise RuntimeError('dbt is not installed in the MWAA environment')

        logging.info(
            'Applying deployment=%s release=%s commit=%s',
            selection['deployment'], selection['release'], selection['commit'],
        )
        with tempfile.TemporaryDirectory(prefix='dataflow-release-') as directory:
            work = Path(directory)
            archive = work / 'release.tar.gz'
            s3.download_file(
                config['bucket'], selection['artifact'], str(archive)
            )
            if file_sha256(archive) != selection['sha256']:
                raise ValueError('Release archive checksum mismatch')

            project = work / 'project'
            project.mkdir()
            extract_project(archive, project)
            if not (project / 'dbt_project.yml').is_file():
                raise ValueError('dbt_project.yml is missing from archive root')

            profiles = work / 'profiles'
            profiles.mkdir(mode=0o700)
            profile = {
                'dataflow': {
                    'target': 'mwaa',
                    'outputs': {
                        'mwaa': {
                            'type': 'redshift',
                            'host': connection.host,
                            'port': connection.port or 5439,
                            'dbname': database,
                            'schema': output_schema,
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

            import os
            env = os.environ.copy()
            env['DBT_ENV_SECRET_DATAFLOW_USER'] = connection.login
            env['DBT_ENV_SECRET_DATAFLOW_PASSWORD'] = connection.password
            env['DBT_SEND_ANONYMOUS_USAGE_STATS'] = 'false'

            def dbt(*arguments, timeout=6900):
                subprocess.run(
                    [
                        executable,
                        *arguments,
                        '--project-dir', str(project),
                        '--profiles-dir', str(profiles),
                        '--target', 'mwaa',
                    ],
                    cwd=project,
                    env=env,
                    check=True,
                    timeout=timeout,
                )

            subprocess.run(
                [executable, '--version'], env=env, check=True, timeout=30
            )
            if any(
                (project / name).exists()
                for name in ('packages.yml', 'dependencies.yml')
            ):
                dbt('deps', timeout=600)
            dbt('debug', timeout=120)
            dbt(DBT_COMMAND)

        marker = {
            **selection,
            'applied_at': datetime.now(timezone.utc).isoformat(),
            'dag_run_id': context['run_id'],
            'command': DBT_COMMAND,
            'database': database,
            'schema': output_schema,
        }
        s3.put_object(
            Bucket=config['bucket'],
            Key=APPLIED_KEY,
            Body=(json.dumps(marker, indent=2) + '\n').encode(),
            ContentType='application/json',
        )
        logging.info(
            'Applied release=%s commit=%s',
            selection['release'], selection['commit'],
        )
        return marker

    reconcile_release()


dataflow_auto_release()
