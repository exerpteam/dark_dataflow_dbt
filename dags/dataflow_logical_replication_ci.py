"""Apply the tagged logical-replication release selected for DATA-666 CI."""
import hashlib
import json
import os
import re
import shutil
import subprocess
import tarfile
import tempfile
from datetime import datetime, timedelta, timezone
from pathlib import Path, PurePosixPath

from airflow.sdk import dag, get_current_context, task


SOURCE_CONNECTION = "data_666_rds"
TARGET_CONNECTION = "dataflow_rds"
APPLIED_KEY = "logical_replication/applied.json"
DEPLOYMENT = re.compile(
    r"internal-workload-(?P<system>[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)"
)
SIMPLE_NAME = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*")
COMMIT = re.compile(r"[0-9a-f]{40}")
CHECKSUM = re.compile(r"[0-9a-f]{64}")
ARTIFACT = re.compile(
    r"logical_replication/ci/pr-(?P<pr>[1-9][0-9]*)/"
    r"(?P<pr_commit>[0-9a-f]{40})/logical-replication-"
    r"(?P<release>[A-Za-z0-9][A-Za-z0-9._-]*)\.tar\.gz"
)


def trigger_config(raw):
    if not isinstance(raw, dict):
        raise ValueError("DAG run configuration must be a JSON object")
    required = {
        "deployment", "bucket", "pr_number", "pr_commit_sha", "release",
        "release_commit_sha", "artifact_key", "artifact_sha256",
    }
    missing = sorted(required - set(raw))
    if missing:
        raise ValueError(f"DAG run configuration is missing fields: {missing}")
    match = DEPLOYMENT.fullmatch(str(raw["deployment"]))
    if not match or raw["bucket"] != f'exerp-{match.group("system")}-dataflow-airflow':
        raise ValueError("Invalid deployment or bucket")
    if not isinstance(raw["pr_number"], int) or raw["pr_number"] < 1:
        raise ValueError("Invalid PR number")
    if not isinstance(raw["release"], str) or not SIMPLE_NAME.fullmatch(raw["release"]):
        raise ValueError("Invalid release")
    if any(
        not isinstance(raw[field], str) or not COMMIT.fullmatch(raw[field])
        for field in ("pr_commit_sha", "release_commit_sha")
    ):
        raise ValueError("Invalid commit SHA")
    if not isinstance(raw["artifact_sha256"], str) or not CHECKSUM.fullmatch(
        raw["artifact_sha256"]
    ):
        raise ValueError("Invalid artifact checksum")
    artifact = ARTIFACT.fullmatch(str(raw["artifact_key"]))
    if (
        not artifact
        or int(artifact.group("pr")) != raw["pr_number"]
        or artifact.group("pr_commit") != raw["pr_commit_sha"]
        or artifact.group("release") != raw["release"]
    ):
        raise ValueError("Artifact key does not match PR, commit and release")
    return raw


def file_sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def extract_archive(archive_path, destination):
    with tarfile.open(archive_path, "r:gz") as archive:
        members = archive.getmembers()
        if len(members) > 20 or sum(member.size for member in members) > 10 * 1024 ** 2:
            raise ValueError("Logical-replication artifact is too large")
        seen = set()
        for member in members:
            path = PurePosixPath(member.name)
            if path.is_absolute() or ".." in path.parts or path in seen:
                raise ValueError("Unsafe or duplicate archive path")
            if not (member.isfile() or member.isdir()):
                raise ValueError("Archive links and special files are unsupported")
            seen.add(path)
        for member in members:
            target = destination.joinpath(*PurePosixPath(member.name).parts)
            if member.isdir():
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with archive.extractfile(member) as source, target.open("wb") as output:
                    shutil.copyfileobj(source, output)


def get_optional_json(s3, bucket, key):
    from botocore.exceptions import ClientError

    try:
        response = s3.get_object(Bucket=bucket, Key=key)
    except ClientError as error:
        if error.response.get("Error", {}).get("Code") in {
            "404", "NoSuchKey", "NotFound"
        }:
            return None
        raise
    with response["Body"] as body:
        return json.loads(body.read())


def validate_applied(applied, config):
    if applied is None:
        return None
    required = {"deployment", "release", "commit", "bucket", "artifact", "sha256"}
    if not isinstance(applied, dict) or not required.issubset(applied):
        raise ValueError("Applied logical-replication marker is incomplete")
    if applied["deployment"] != config["deployment"] or applied["bucket"] != config["bucket"]:
        raise ValueError("Applied logical-replication release belongs to another deployment")
    if not isinstance(applied["release"], str) or not SIMPLE_NAME.fullmatch(applied["release"]):
        raise ValueError("Applied logical-replication release is invalid")
    if not isinstance(applied["commit"], str) or not COMMIT.fullmatch(applied["commit"]):
        raise ValueError("Applied logical-replication commit is invalid")
    if not isinstance(applied["sha256"], str) or not CHECKSUM.fullmatch(applied["sha256"]):
        raise ValueError("Applied logical-replication checksum is invalid")
    artifact = ARTIFACT.fullmatch(str(applied["artifact"]))
    if not artifact or artifact.group("release") != applied["release"]:
        raise ValueError("Applied logical-replication artifact is invalid")
    return applied


def connection_env(connection, prefix, connection_id):
    if connection is None:
        raise ValueError(f"Airflow connection {connection_id!r} was not found")
    if not all((connection.host, connection.login, connection.password)):
        raise ValueError(f"Airflow connection {connection_id!r} is incomplete")
    return {
        f"{prefix}_HOST": connection.host,
        f"{prefix}_PORT": str(connection.port or 5432),
        f"{prefix}_DATABASE": connection.schema or "exerp",
        f"{prefix}_USER": connection.login,
        f"{prefix}_PASSWORD": connection.password,
    }


@dag(
    dag_id="dataflow_logical_replication_ci",
    description="Apply a tagged logical-replication release in DATA-666",
    schedule=None,
    start_date=datetime(2026, 1, 1, tzinfo=timezone.utc),
    catchup=False,
    max_active_runs=1,
    tags=["dataflow", "logical-replication", "ci"],
)
def dataflow_logical_replication_ci():
    @task(retries=0, execution_timeout=timedelta(hours=2))
    def apply_release():
        import boto3
        from airflow.sdk.bases.hook import BaseHook

        context = get_current_context()
        config = trigger_config(context["dag_run"].conf)
        s3 = boto3.client("s3")
        applied = validate_applied(
            get_optional_json(s3, config["bucket"], APPLIED_KEY), config
        )
        requested = {
            "deployment": config["deployment"],
            "release": config["release"],
            "commit": config["release_commit_sha"],
            "bucket": config["bucket"],
            "artifact": config["artifact_key"],
            "sha256": config["artifact_sha256"],
        }
        with tempfile.TemporaryDirectory(prefix="logical-replication-ci-") as directory:
            work = Path(directory)
            requested_archive = work / "requested.tar.gz"
            s3.download_file(config["bucket"], requested["artifact"], str(requested_archive))
            if file_sha256(requested_archive) != requested["sha256"]:
                raise ValueError("Requested release checksum mismatch")
            requested_project = work / "requested"
            requested_project.mkdir()
            extract_archive(requested_archive, requested_project)
            target = requested_project / "tables.json"
            script = requested_project / "apply_logical_replication_transition.py"
            if not target.is_file() or not script.is_file():
                raise ValueError("Requested logical-replication release is incomplete")

            if applied is None:
                base = work / "base.json"
                base.write_text("[]\n", encoding="utf-8")
            else:
                applied_archive = work / "applied.tar.gz"
                s3.download_file(config["bucket"], applied["artifact"], str(applied_archive))
                if file_sha256(applied_archive) != applied["sha256"]:
                    raise ValueError("Applied release checksum mismatch")
                applied_project = work / "applied"
                applied_project.mkdir()
                extract_archive(applied_archive, applied_project)
                base = applied_project / "tables.json"
                if not base.is_file():
                    raise ValueError("Applied logical-replication release has no tables.json")

            env = os.environ.copy()
            env.update(connection_env(
                BaseHook.get_connection(SOURCE_CONNECTION),
                "PUBLICATION_SOURCE", SOURCE_CONNECTION,
            ))
            env.update(connection_env(
                BaseHook.get_connection(TARGET_CONNECTION),
                "PUBLICATION_TARGET", TARGET_CONNECTION,
            ))
            subprocess.run(
                [
                    shutil.which("python3") or "python", str(script),
                    "--base", str(base), "--target", str(target),
                ],
                env=env, check=True, timeout=6900,
            )

        marker = {
            **requested,
            "applied_at": datetime.now(timezone.utc).isoformat(),
            "dag_run_id": context["run_id"],
            "publication": "data_666_to_dataflow_pub",
            "subscription": "data_666_dataflow_sub",
        }
        s3.put_object(
            Bucket=config["bucket"], Key=APPLIED_KEY,
            Body=(json.dumps(marker, indent=2) + "\n").encode(),
            ContentType="application/json",
        )
        return marker

    apply_release()


dataflow_logical_replication_ci()
