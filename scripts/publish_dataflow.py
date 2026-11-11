"""Publish a tagged dbt subtree and then update its S3 selection pointer."""
import gzip
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tarfile


DEPLOYMENT_NAME_PATTERN = re.compile(
    r'internal-workload-(?P<system_name>[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)'
)
S3_PREFIX = 'dbt_project'
EXPECTED_CONFIG_FIELDS = {'release', 'project_path'}


def deployment_target(config_path):
    """Derive the deployment name and S3 bucket from the config filename."""
    if config_path.suffix != '.json':
        raise ValueError('Deployment config must be a .json file')
    deployment_name = config_path.stem
    match = DEPLOYMENT_NAME_PATTERN.fullmatch(deployment_name)
    if not match:
        raise ValueError(
            'Deployment config must be named '
            'internal-workload-<system-name>.json'
        )
    system_name = match.group('system_name')
    bucket = f'exerp-{system_name}-dataflow-airflow'
    if len(bucket) > 63:
        raise ValueError(f'Derived S3 bucket name is too long: {bucket}')
    return deployment_name, bucket


def command(*args):
    return subprocess.check_output(args)


def load_deployment_config(config_path):
    """Load and validate the complete deployment configuration."""
    config = json.loads(config_path.read_text(encoding='utf-8'))
    if not isinstance(config, dict) or set(config) != EXPECTED_CONFIG_FIELDS:
        raise ValueError(
            'Deployment config must contain exactly: '
            f'{sorted(EXPECTED_CONFIG_FIELDS)}'
        )
    release = config['release']
    project = config['project_path']
    if not isinstance(release, str) or not re.fullmatch(
        r'[A-Za-z0-9][A-Za-z0-9._-]*', release
    ):
        raise ValueError('Release must be a simple tag name')
    if not isinstance(project, str) or not re.fullmatch(
        r'[A-Za-z0-9_-]+(?:/[A-Za-z0-9_-]+)*', project
    ):
        raise ValueError('Invalid project path')
    return config


def validate_environment(config_path, environment):
    """Ensure the selected GitHub Environment owns this deployment file."""
    if not environment:
        raise ValueError('DEPLOYMENT_ENVIRONMENT is not set')
    deployment_name, bucket = deployment_target(config_path)
    if deployment_name != environment:
        raise ValueError(
            f'Deployment {deployment_name!r} does not match GitHub '
            f'Environment {environment!r}'
        )
    return deployment_name, bucket


def resolve_tag(release):
    """Resolve a release tag to a commit, failing clearly if it is absent."""
    ref = f'refs/tags/{release}'
    try:
        return command(
            'git', 'rev-parse', '--verify', f'{ref}^{{commit}}'
        ).decode().strip()
    except subprocess.CalledProcessError as error:
        raise ValueError(f'Release tag does not exist: {release}') from error


def main():
    if len(sys.argv) != 2:
        raise SystemExit(f'Usage: {Path(sys.argv[0]).name} DEPLOYMENT_CONFIG.json')
    config_path = Path(sys.argv[1])
    config = load_deployment_config(config_path)
    deployment_name, bucket = validate_environment(
        config_path, os.environ.get('DEPLOYMENT_ENVIRONMENT')
    )
    release = config['release']
    project = config['project_path']
    commit = resolve_tag(release)
    tree = f'{commit}:{project}'
    # Fail rather than package local credentials or generated build output.
    names = command('git', 'ls-tree', '-r', '--name-only', tree).decode().splitlines()
    for name in names:
        parts = PurePosixPath(name).parts
        if 'profiles.yml' in parts or '.env' in parts or any(
            part in {'target', 'logs', 'dbt_packages', '.venv'} for part in parts
        ):
            raise ValueError(f'Remove generated or credential file from release: {name}')
    tar_bytes = command('git', 'archive', '--format=tar', tree)
    with tarfile.open(fileobj=io.BytesIO(tar_bytes)) as archive:
        archive.getmember('dbt_project.yml')
    # Fixed gzip timestamp makes retries produce the same checksum.
    payload = gzip.compress(tar_bytes, mtime=0)
    checksum = hashlib.sha256(payload).hexdigest()
    output = Path(os.environ.get('RUNNER_TEMP', '/tmp')) / 'dataflow-publish'
    output.mkdir(parents=True, exist_ok=True)
    artifact = output / f'exerp-dbt-{release}.tar.gz'
    artifact.write_bytes(payload)
    key = f'{S3_PREFIX}/releases/{artifact.name}'
    put = subprocess.run([
        'aws', 's3api', 'put-object', '--bucket', bucket, '--key', key,
        '--body', str(artifact), '--if-none-match', '*',
        '--metadata', f'commit={commit},sha256={checksum}',
    ], capture_output=True, text=True)
    if put.returncode:
        if 'PreconditionFailed' not in put.stderr:
            raise RuntimeError(put.stderr)
        existing = json.loads(command(
            'aws', 's3api', 'head-object', '--bucket', bucket, '--key', key
        ))
        metadata = existing.get('Metadata', {})
        if metadata.get('commit') != commit or metadata.get('sha256') != checksum:
            raise RuntimeError('Release already exists with different contents; create a new tag')
    pointer = {
        'deployment': deployment_name,
        'release': release,
        'commit': commit,
        'bucket': bucket,
        'artifact': key,
        'sha256': checksum,
    }
    pointer_file = output / 'deployment.json'
    pointer_file.write_text(json.dumps(pointer, indent=2) + '\n', encoding='utf-8')
    # Only change the selection after the complete archive is available.
    command('aws', 's3api', 'put-object', '--bucket', bucket,
            '--key', f'{S3_PREFIX}/deployment.json', '--body', str(pointer_file),
            '--content-type', 'application/json')
    print(f'Published {release} ({commit}) to s3://{bucket}/{key}')
    print('Selection updated; Redshift deployment requires a successful MWAA run.')


if __name__ == '__main__':
    main()
