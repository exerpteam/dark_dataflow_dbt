"""Run the S3-selected dbt release using the existing Airflow Redshift connection."""
import logging
from datetime import datetime, timedelta, timezone

from airflow.sdk import Param, dag, task


BUCKET = 'exerp-data-666-dataflow-airflow'
POINTER = 'dbt_project/deployment.json'
REGION = 'eu-north-1'


def extract_project(archive_path, destination):
    """Extract regular files/directories only, rejecting unsafe archive paths."""
    import shutil
    import tarfile
    from pathlib import PurePosixPath

    with tarfile.open(archive_path, 'r:gz') as archive:
        members = archive.getmembers()
        if sum(member.size for member in members) > 1024 ** 3:
            raise ValueError('Archive exceeds 1 GiB uncompressed')
        for member in members:
            path = PurePosixPath(member.name)
            if path.is_absolute() or '..' in path.parts:
                raise ValueError('Unsafe archive path')
            if not (member.isfile() or member.isdir()):
                raise ValueError('Archive links and special files are unsupported')
        for member in members:
            target = destination.joinpath(*PurePosixPath(member.name).parts)
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with archive.extractfile(member) as source, target.open('wb') as out:
                    shutil.copyfileobj(source, out)


@dag(
    dag_id='data_666_dbt_release',
    description='Check or deploy the Dataflow release selected in S3',
    schedule=None,
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    tags=['data-666', 'dbt', 'dataflow'],
    params={
        'command': Param('debug', enum=['debug', 'run', 'build']),
        'output_schema': Param('dataflow_sandbox', type='string',
                               pattern=r'^[a-z][a-z0-9_]*$'),
        'select': Param('person', type='string', minLength=1),
        'dbt_executable': Param(
            'dbt',
            type='string', minLength=1,
        ),
    },
)
def data_666_dbt_release():
    @task(retries=0, execution_timeout=timedelta(minutes=2))
    def select_release():
        import json
        import re
        import boto3

        s3 = boto3.client('s3', region_name=REGION)
        response = s3.get_object(Bucket=BUCKET, Key=POINTER)
        with response['Body'] as body:
            selection = json.loads(body.read())
        if selection.get('bucket') != BUCKET:
            raise ValueError('Release points to an unexpected bucket')
        key = selection.get('artifact', '')
        if not key.startswith('dbt_project/releases/') or not key.endswith('.tar.gz'):
            raise ValueError('Invalid release archive key')
        if not re.fullmatch(r'[0-9a-f]{64}', selection.get('sha256', '')):
            raise ValueError('Missing or invalid release checksum')
        if not re.fullmatch(r'[0-9a-f]{40}', selection.get('commit', '')):
            raise ValueError('Missing or invalid commit SHA')
        logging.info('Selected release=%s commit=%s',
                     selection['release'], selection['commit'])
        # Downstream retries use this XCom snapshot rather than rereading S3.
        return selection

    @task(retries=1, retry_delay=timedelta(minutes=1),
          execution_timeout=timedelta(minutes=30))
    def execute_release(selection):
        import hashlib
        import json
        import os
        import shutil
        import subprocess
        import tempfile
        from pathlib import Path
        import boto3
        from airflow.sdk import get_current_context
        from airflow.sdk.bases.hook import BaseHook

        params = get_current_context()['params']
        executable = shutil.which(params['dbt_executable'])
        if not executable:
            raise RuntimeError(
                'dbt executable not found. Install dbt-core/dbt-redshift in the '
                'MWAA worker virtualenv or set the dbt_executable trigger parameter.'
            )
        connection = BaseHook.get_connection('dataflow_redshift')
        if not all((connection.host, connection.schema,
                    connection.login, connection.password)):
            raise ValueError('dataflow_redshift requires host, database, login and password')

        with tempfile.TemporaryDirectory(prefix='dataflow-') as directory:
            work = Path(directory)
            archive = work / 'release.tar.gz'
            boto3.client('s3', region_name=REGION).download_file(
                BUCKET, selection['artifact'], str(archive)
            )
            if hashlib.sha256(archive.read_bytes()).hexdigest() != selection['sha256']:
                raise ValueError('Release archive checksum mismatch')
            project = work / 'project'
            project.mkdir()
            extract_project(archive, project)
            if not (project / 'dbt_project.yml').is_file():
                raise ValueError('dbt_project.yml missing from archive root')
            profiles = work / 'profiles'
            profiles.mkdir(mode=0o700)
            profile = {'dataflow': {'target': 'mwaa', 'outputs': {'mwaa': {
                'type': 'redshift', 'host': connection.host,
                'port': connection.port or 5439, 'dbname': connection.schema,
                'schema': params['output_schema'], 'threads': 2,
                'user': "{{ env_var('DBT_ENV_SECRET_DATAFLOW_USER') }}",
                'password': "{{ env_var('DBT_ENV_SECRET_DATAFLOW_PASSWORD') }}",
                'sslmode': 'require', 'connect_timeout': 10,
            }}}}
            # JSON is valid YAML; credentials stay in the subprocess environment.
            (profiles / 'profiles.yml').write_text(json.dumps(profile))
            env = os.environ.copy()
            env['DBT_ENV_SECRET_DATAFLOW_USER'] = connection.login
            env['DBT_ENV_SECRET_DATAFLOW_PASSWORD'] = connection.password
            env['DBT_SEND_ANONYMOUS_USAGE_STATS'] = 'false'

            def dbt(command, *arguments):
                subprocess.run([
                    executable, command, '--project-dir', str(project),
                    '--profiles-dir', str(profiles), '--target', 'mwaa', *arguments,
                ], cwd=project, env=env, check=True, timeout=1500)

            subprocess.run([executable, '--version'], env=env, check=True, timeout=30)
            # This tagged project currently has no dbt package dependencies.
            if any((project / name).exists() for name in
                   ('packages.yml', 'dependencies.yml')):
                dbt('deps')
            dbt('debug')
            if params['command'] != 'debug':
                dbt(params['command'], '--select', params['select'])
            logging.info('Completed command=%s release=%s commit=%s schema=%s',
                         params['command'], selection['release'],
                         selection['commit'], params['output_schema'])
            return {
                'release': selection['release'], 'commit': selection['commit'],
                'command': params['command'], 'schema': params['output_schema'],
                'select': params['select'],
            }

    execute_release(select_release())


data_666_dbt_release()
