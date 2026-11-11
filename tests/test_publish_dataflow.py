import os
import unittest
from pathlib import Path

from scripts.publish_dataflow import (
    EXPECTED_CONFIG_FIELDS,
    load_deployment_config,
    resolve_tag,
    validate_environment,
)


class DeploymentConfigurationTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config_path = Path(os.environ['DEPLOYMENT_CONFIG'])
        cls.environment = os.environ['DEPLOYMENT_ENVIRONMENT']
        cls.config = load_deployment_config(cls.config_path)

    def test_deployment_matches_github_environment(self):
        deployment, _ = validate_environment(
            self.config_path, self.environment
        )

        self.assertEqual(deployment, self.environment)

    def test_all_configuration_fields_are_given(self):
        self.assertEqual(set(self.config), EXPECTED_CONFIG_FIELDS)
        for field in EXPECTED_CONFIG_FIELDS:
            self.assertTrue(self.config[field])

    def test_release_tag_exists(self):
        commit = resolve_tag(self.config['release'])

        self.assertRegex(commit, r'^[0-9a-f]{40}$')


if __name__ == '__main__':
    unittest.main()
