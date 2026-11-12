import importlib.util
import io
import json
import sys
import tarfile
import tempfile
import types
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def load_dag_module(filename='dataflow_dbt_ci.py', name='dataflow_dbt_ci_dag'):
    airflow = types.ModuleType('airflow')
    sdk = types.ModuleType('airflow.sdk')

    def dag(**_kwargs):
        def decorate(_function):
            return lambda: None
        return decorate

    sdk.dag = dag
    sdk.task = lambda **_kwargs: (lambda function: function)
    sdk.get_current_context = lambda: None
    airflow.sdk = sdk
    sys.modules['airflow'] = airflow
    sys.modules['airflow.sdk'] = sdk
    spec = importlib.util.spec_from_file_location(
        name, ROOT / 'dags' / filename
    )
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class DbtCiContractTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = load_dag_module()

    def valid_config(self):
        commit = 'a' * 40
        return {
            'deployment': 'internal-workload-data-666',
            'bucket': 'exerp-data-666-dataflow-airflow',
            'pr_number': 12,
            'commit_sha': commit,
            'artifact_key': f'dbt_project/ci/pr-12/{commit}/project.tar.gz',
            'artifact_sha256': 'b' * 64,
        }

    def test_valid_trigger_is_accepted(self):
        self.assertEqual(
            self.module.trigger_config(self.valid_config())['pr_number'], 12
        )

    def test_artifact_must_match_pr_and_commit(self):
        config = self.valid_config()
        config['artifact_key'] = config['artifact_key'].replace('pr-12', 'pr-13')
        with self.assertRaisesRegex(ValueError, 'does not match'):
            self.module.trigger_config(config)

    def test_bucket_is_derived_from_deployment(self):
        config = self.valid_config()
        config['bucket'] = 'another-bucket'
        with self.assertRaisesRegex(ValueError, 'different bucket'):
            self.module.trigger_config(config)

    def test_archive_traversal_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            archive_path = Path(directory) / 'bad.tar.gz'
            with tarfile.open(archive_path, 'w:gz') as archive:
                item = tarfile.TarInfo('../outside')
                item.size = 1
                archive.addfile(item, io.BytesIO(b'x'))
            with self.assertRaisesRegex(ValueError, 'Unsafe'):
                self.module.extract_project(
                    archive_path, Path(directory) / 'project'
                )

    def test_archive_root_entry_is_supported(self):
        with tempfile.TemporaryDirectory() as directory:
            archive_path = Path(directory) / 'project.tar.gz'
            with tarfile.open(archive_path, 'w:gz') as archive:
                root = tarfile.TarInfo('.')
                root.type = tarfile.DIRTYPE
                archive.addfile(root)
                item = tarfile.TarInfo('./dbt_project.yml')
                item.size = 4
                archive.addfile(item, io.BytesIO(b'name'))
            project = Path(directory) / 'project'
            project.mkdir()
            self.module.extract_project(archive_path, project)
            self.assertEqual((project / 'dbt_project.yml').read_bytes(), b'name')

    def test_only_successful_model_relations_are_query_checked(self):
        with tempfile.TemporaryDirectory() as directory:
            project = Path(directory)
            target = project / 'target'
            target.mkdir()
            (target / 'run_results.json').write_text(json.dumps({
                'results': [
                    {'unique_id': 'model.exerp.person', 'status': 'success'},
                    {'unique_id': 'test.exerp.not_null_person', 'status': 'pass'},
                    {'unique_id': 'model.exerp.failed', 'status': 'error'},
                ]
            }), encoding='utf-8')
            (target / 'manifest.json').write_text(json.dumps({
                'nodes': {
                    'model.exerp.person': {
                        'resource_type': 'model',
                        'relation_name': '"exerp"."ci_pr_7"."person"',
                    },
                    'test.exerp.not_null_person': {
                        'resource_type': 'test',
                    },
                    'model.exerp.failed': {
                        'resource_type': 'model',
                        'relation_name': '"exerp"."ci_pr_7"."failed"',
                    },
                }
            }), encoding='utf-8')
            self.assertEqual(
                self.module.successful_model_relations(project),
                ['"exerp"."ci_pr_7"."person"'],
            )

    def test_ci_schema_is_reset_before_build(self):
        dag_source = (ROOT / 'dags' / 'dataflow_dbt_ci.py').read_text(
            encoding='utf-8'
        )
        reset = "project, 'ci', 'run-operation', 'reset_ci_schema'"
        build = "project, 'ci', 'build', '--select', 'state:modified+'"
        self.assertIn(reset, dag_source)
        self.assertIn(build, dag_source)
        self.assertLess(dag_source.index(reset), dag_source.index(build))

        macro = (ROOT / 'exerp-dbt' / 'macros' / 'reset_ci_schema.sql').read_text(
            encoding='utf-8'
        )
        self.assertIn("fullmatch('ci_pr_[0-9]+'", macro)
        self.assertIn('drop schema if exists ', macro)
        self.assertIn("create schema ", macro)


class AppliedReleaseTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.module = load_dag_module()

    def test_applied_release_is_the_baseline_source(self):
        commit = 'a' * 40
        applied = {
            'deployment': 'internal-workload-data-666',
            'release': 'pre-alpha-v1',
            'commit': commit,
            'bucket': 'exerp-data-666-dataflow-airflow',
            'artifact': 'dbt_project/releases/exerp-dbt-pre-alpha-v1.tar.gz',
            'sha256': 'b' * 64,
            'database': 'exerp',
            'schema': 'exerp',
        }
        config = {
            'deployment': applied['deployment'],
            'bucket': applied['bucket'],
        }

        class S3:
            def get_object(self, **_kwargs):
                return {'Body': io.BytesIO(json.dumps(applied).encode())}

        self.assertEqual(
            self.module.get_applied_release(S3(), config)['commit'], commit
        )


if __name__ == '__main__':
    unittest.main()
