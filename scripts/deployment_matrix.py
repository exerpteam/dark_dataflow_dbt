"""Build a GitHub Actions matrix from deployment configuration paths."""
import json
from pathlib import Path
import sys

from publish_dataflow import deployment_target


def main():
    if len(sys.argv) < 2:
        raise SystemExit('At least one deployment config is required')

    deployments = []
    seen = set()
    for value in sys.argv[1:]:
        config_path = Path(value)
        if (
            config_path.parent != Path('deployments')
            or config_path.suffix != '.json'
            or not config_path.is_file()
        ):
            raise ValueError(f'Invalid deployment config path: {value}')

        environment, _ = deployment_target(config_path)
        if environment in seen:
            continue
        seen.add(environment)
        deployments.append({
            'environment': environment,
            'config': config_path.as_posix(),
        })

    print(f'matrix={json.dumps({"include": deployments}, separators=(",", ":"))}')


if __name__ == '__main__':
    main()
