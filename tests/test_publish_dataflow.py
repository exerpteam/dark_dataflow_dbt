import os
import io
import json
import hashlib
import subprocess
import tarfile
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts.publish_dataflow import (
    EXPECTED_CONFIG_FIELDS,
    deployment_target,
    existing_release_checksum,
    load_deployment_config,
    normalized_tar,
    resolve_tag,
)


class DeploymentConfigurationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config_path = Path(os.environ['DEPLOYMENT_CONFIG'])
        cls.config = load_deployment_config(cls.config_path)

    def test_deployment_target_is_derived_from_filename(self):
        deployment, bucket = deployment_target(self.config_path)

        self.assertEqual(deployment, self.config_path.stem)
        self.assertEqual(
            bucket,
            f'exerp-{deployment.removeprefix("internal-workload-")}'
            '-dataflow-airflow',
        )

    def test_all_configuration_fields_are_given(self):
        self.assertEqual(set(self.config), EXPECTED_CONFIG_FIELDS)
        for field in EXPECTED_CONFIG_FIELDS:
            self.assertTrue(self.config[field])

    def test_release_tag_exists(self):
        commit = resolve_tag(self.config['release'])

        self.assertRegex(commit, r'^[0-9a-f]{40}$')


class ExistingReleaseTest(unittest.TestCase):
    def test_tar_normalization_is_reproducible(self):
        def archive_with_mtime(mtime):
            buffer = io.BytesIO()
            content = b'project'
            with tarfile.open(fileobj=buffer, mode='w:') as archive:
                member = tarfile.TarInfo('dbt_project.yml')
                member.size = len(content)
                member.mtime = mtime
                archive.addfile(member, io.BytesIO(content))
            return buffer.getvalue()

        self.assertEqual(
            normalized_tar(archive_with_mtime(1)),
            normalized_tar(archive_with_mtime(2)),
        )

    def test_reuses_release_with_matching_metadata(self):
        result = subprocess.CompletedProcess(
            [], 0,
            stdout=json.dumps({'Metadata': {
                'commit': 'a' * 40,
                'sha256': 'b' * 64,
            }}),
            stderr='',
        )

        with patch('scripts.publish_dataflow.subprocess.run', return_value=result):
            existing_checksum = existing_release_checksum(
                'bucket', 'key', Path('artifact.tar.gz'),
                'a' * 40, 'b' * 64,
            )

        self.assertEqual(existing_checksum, 'b' * 64)

    def test_uploads_when_release_does_not_exist(self):
        result = subprocess.CompletedProcess(
            [], 255, stdout='', stderr='404 Not Found'
        )

        with patch('scripts.publish_dataflow.subprocess.run', return_value=result):
            existing_checksum = existing_release_checksum(
                'bucket', 'key', Path('artifact.tar.gz'),
                'a' * 40, 'b' * 64,
            )

        self.assertIsNone(existing_checksum)

    def test_rejects_release_for_different_commit(self):
        result = subprocess.CompletedProcess(
            [], 0,
            stdout=json.dumps({'Metadata': {
                'commit': 'c' * 40,
                'sha256': 'c' * 64,
            }}),
            stderr='',
        )

        with patch('scripts.publish_dataflow.subprocess.run', return_value=result):
            with self.assertRaisesRegex(RuntimeError, 'different commit'):
                existing_release_checksum(
                    'bucket', 'key', Path('artifact.tar.gz'),
                    'a' * 40, 'b' * 64,
                )

    def test_verifies_legacy_release_contents(self):
        archive_buffer = io.BytesIO()
        content = b'existing release'
        with tarfile.open(fileobj=archive_buffer, mode='w:gz') as archive:
            member = tarfile.TarInfo('dbt_project.yml')
            member.size = len(content)
            archive.addfile(member, io.BytesIO(content))
        payload = archive_buffer.getvalue()
        checksum = hashlib.sha256(payload).hexdigest()

        with tempfile.TemporaryDirectory() as directory:
            artifact = Path(directory) / 'artifact.tar.gz'
            artifact.write_bytes(payload)

            def aws(command, **_kwargs):
                if 'head-object' in command:
                    return subprocess.CompletedProcess(
                        command, 0, stdout='{"Metadata": {}}', stderr=''
                    )
                Path(command[-1]).write_bytes(payload)
                return subprocess.CompletedProcess(
                    command, 0, stdout='{}', stderr=''
                )

            with patch('scripts.publish_dataflow.subprocess.run', side_effect=aws):
                existing_checksum = existing_release_checksum(
                    'bucket', 'key', artifact, 'a' * 40, checksum
                )

        self.assertEqual(existing_checksum, checksum)


if __name__ == '__main__':
    unittest.main()
