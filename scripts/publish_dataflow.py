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


def command(*args):
    return subprocess.check_output(args)


def main():
    config = json.loads(Path(sys.argv[1]).read_text())
    release = config['release']
    project = config['project_path']
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]*', release):
        raise ValueError('Release must be a simple tag name')
    if not re.fullmatch(r'[A-Za-z0-9_-]+(?:/[A-Za-z0-9_-]+)*', project):
        raise ValueError('Invalid project path')
    ref = f'refs/tags/{release}'
    commit = command('git', 'rev-parse', '--verify', f'{ref}^{{commit}}').decode().strip()
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
    bucket = config['bucket']
    prefix = config['prefix'].strip('/')
    key = f'{prefix}/releases/{artifact.name}'
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
        'release': release, 'commit': commit, 'bucket': bucket,
        'artifact': key, 'sha256': checksum,
    }
    pointer_file = output / 'deployment.json'
    pointer_file.write_text(json.dumps(pointer, indent=2) + '\n')
    # Only change the selection after the complete archive is available.
    command('aws', 's3api', 'put-object', '--bucket', bucket,
            '--key', f'{prefix}/deployment.json', '--body', str(pointer_file),
            '--content-type', 'application/json')
    print(f'Published {release} ({commit}) to s3://{bucket}/{key}')
    print('Selection updated; Redshift deployment requires a successful MWAA run.')


if __name__ == '__main__':
    main()
