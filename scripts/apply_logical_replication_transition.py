#!/usr/bin/env python3
"""Apply a targeted full-table transition without touching unrelated members."""
from __future__ import annotations

import argparse
import json
import logging
import os
import re
import time
from pathlib import Path

import psycopg
from psycopg import sql


LOGGER = logging.getLogger("logical-replication-ci")
SCHEMA = "exerp"
PUBLICATION = "data_666_to_dataflow_pub"
SUBSCRIPTION = "data_666_dataflow_sub"
NAME = re.compile(r"[a-z][a-z0-9_]*")
def load_tables(path: Path) -> set[str]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if (
        not isinstance(value, list)
        or len(value) != len(set(value))
        or any(not isinstance(table, str) or not NAME.fullmatch(table) for table in value)
    ):
        raise ValueError(f"{path} contains invalid tables")
    return set(value)


def transition(base: set[str], target: set[str]) -> tuple[list[str], list[str]]:
    return sorted(target - base), sorted(base - target)


def connection(prefix: str) -> dict[str, object]:
    required = {
        name: os.environ.get(f"{prefix}_{name}")
        for name in ("HOST", "USER", "PASSWORD")
    }
    missing = sorted(name for name, value in required.items() if not value)
    if missing:
        raise ValueError(f"Missing {prefix} fields: {missing}")
    return {
        "host": required["HOST"],
        "port": int(os.environ.get(f"{prefix}_PORT", "5432")),
        "dbname": os.environ.get(f"{prefix}_DATABASE", "exerp"),
        "user": required["USER"],
        "password": required["PASSWORD"],
        "sslmode": "require",
        "connect_timeout": 10,
        "application_name": "dataflow-logical-replication-ci",
    }


def publication_tables(conn) -> set[str]:
    with conn.cursor() as cursor:
        cursor.execute(
            """SELECT tablename
               FROM pg_catalog.pg_publication_tables
               WHERE pubname = %s AND schemaname = %s""",
            (PUBLICATION, SCHEMA),
        )
        return {row[0] for row in cursor.fetchall()}


def source_table_definition(conn, table: str):
    with conn.cursor() as cursor:
        cursor.execute(
            """SELECT a.attname,
                      pg_catalog.format_type(a.atttypid, a.atttypmod),
                      a.attgenerated
               FROM pg_catalog.pg_attribute AS a
               JOIN pg_catalog.pg_class AS c ON c.oid = a.attrelid
               JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
               WHERE n.nspname = %s AND c.relname = %s
                 AND c.relkind IN ('r', 'p')
                 AND a.attnum > 0 AND NOT a.attisdropped
               ORDER BY a.attnum""",
            (SCHEMA, table),
        )
        rows = cursor.fetchall()
        if not rows:
            raise ValueError(f"Source table does not exist: {SCHEMA}.{table}")
        columns = [
            (name, data_type) for name, data_type, generated in rows
            if not generated
        ]
        cursor.execute(
            """SELECT ARRAY(
                     SELECT a.attname
                     FROM pg_catalog.unnest(i.indkey)
                       WITH ORDINALITY AS k(attnum, pos)
                     JOIN pg_catalog.pg_attribute AS a
                       ON a.attrelid = i.indrelid AND a.attnum = k.attnum
                     ORDER BY k.pos)
               FROM pg_catalog.pg_index AS i
               JOIN pg_catalog.pg_class AS c ON c.oid = i.indrelid
               JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
               WHERE n.nspname = %s AND c.relname = %s AND i.indisprimary""",
            (SCHEMA, table),
        )
        row = cursor.fetchone()
        primary_key = tuple(row[0]) if row else ()
        cursor.execute(
            """SELECT c.relreplident
               FROM pg_catalog.pg_class AS c
               JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
               WHERE n.nspname = %s AND c.relname = %s""",
            (SCHEMA, table),
        )
        replica_identity = cursor.fetchone()[0]
    if replica_identity == "d" and not primary_key:
        raise ValueError(f"{SCHEMA}.{table} has no usable replica identity")
    return columns, primary_key


def relation_state(conn, table: str) -> str | None:
    with conn.cursor() as cursor:
        cursor.execute(
            """SELECT r.srsubstate
               FROM pg_catalog.pg_subscription_rel AS r
               JOIN pg_catalog.pg_subscription AS s ON s.oid = r.srsubid
               JOIN pg_catalog.pg_class AS c ON c.oid = r.srrelid
               JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
               WHERE s.subname = %s AND n.nspname = %s AND c.relname = %s""",
            (SUBSCRIPTION, SCHEMA, table),
        )
        row = cursor.fetchone()
        return row[0] if row else None


def ensure_target_table(conn, table: str, columns, primary_key) -> None:
    with conn.cursor() as cursor:
        cursor.execute(
            """SELECT a.attname, pg_catalog.format_type(a.atttypid, a.atttypmod)
               FROM pg_catalog.pg_attribute AS a
               JOIN pg_catalog.pg_class AS c ON c.oid = a.attrelid
               JOIN pg_catalog.pg_namespace AS n ON n.oid = c.relnamespace
               WHERE n.nspname = %s AND c.relname = %s
                 AND c.relkind IN ('r', 'p')
                 AND a.attnum > 0 AND NOT a.attisdropped
               ORDER BY a.attnum""",
            (SCHEMA, table),
        )
        existing = cursor.fetchall()
        if existing:
            expected = dict(columns)
            actual = dict(existing)
            missing = sorted(set(expected) - set(actual))
            unexpected = sorted(set(actual) - set(expected) - {"replicated_at"})
            wrong_types = sorted(
                name for name in set(expected) & set(actual)
                if expected[name] != actual[name]
            )
            if missing or unexpected or wrong_types:
                raise ValueError(
                    f"Subscriber schema mismatch for {SCHEMA}.{table}: "
                    f"missing={missing}, unexpected={unexpected}, "
                    f"wrong_types={wrong_types}"
                )
            if relation_state(conn, table) is None:
                cursor.execute(
                    sql.SQL("SELECT EXISTS (SELECT 1 FROM {}.{} LIMIT 1)").format(
                        sql.Identifier(SCHEMA), sql.Identifier(table)
                    )
                )
                if cursor.fetchone()[0]:
                    raise RuntimeError(
                        f"Unregistered subscriber table {SCHEMA}.{table} is not empty"
                    )
            return

        definitions = [
            sql.SQL("{} {}").format(sql.Identifier(name), sql.SQL(data_type))
            for name, data_type in columns
        ]
        cursor.execute(
            sql.SQL("CREATE TABLE {}.{} ({})").format(
                sql.Identifier(SCHEMA), sql.Identifier(table),
                sql.SQL(", ").join(definitions),
            )
        )
        if primary_key:
            cursor.execute(
                sql.SQL("ALTER TABLE {}.{} ADD PRIMARY KEY ({})").format(
                    sql.Identifier(SCHEMA), sql.Identifier(table),
                    sql.SQL(", ").join(map(sql.Identifier, primary_key)),
                )
            )
        cursor.execute(
            sql.SQL("ALTER TABLE {}.{} ADD COLUMN replicated_at timestamptz").format(
                sql.Identifier(SCHEMA), sql.Identifier(table)
            )
        )
    conn.commit()


def reconcile_publication(conn, added: list[str], removed: list[str]) -> None:
    with conn.cursor() as cursor:
        cursor.execute(
            "SELECT pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtext(%s))",
            (PUBLICATION,),
        )
        live = publication_tables(conn)
        present = [table for table in removed if table in live]
        if present:
            cursor.execute(
                sql.SQL("ALTER PUBLICATION {} DROP TABLE {}").format(
                    sql.Identifier(PUBLICATION),
                    sql.SQL(", ").join(
                        sql.SQL("{}.{}").format(
                            sql.Identifier(SCHEMA), sql.Identifier(table)
                        ) for table in present
                    ),
                )
            )
        missing = [table for table in added if table not in live]
        if missing:
            cursor.execute(
                sql.SQL("ALTER PUBLICATION {} ADD TABLE {}").format(
                    sql.Identifier(PUBLICATION),
                    sql.SQL(", ").join(
                        sql.SQL("{}.{}").format(
                            sql.Identifier(SCHEMA), sql.Identifier(table)
                        ) for table in missing
                    ),
                )
            )
    conn.commit()


def refresh_and_wait(conn, added: list[str], removed: list[str], timeout: int) -> None:
    conn.rollback()
    conn.autocommit = True
    with conn.cursor() as cursor:
        cursor.execute(
            sql.SQL(
                "ALTER SUBSCRIPTION {} REFRESH PUBLICATION WITH (copy_data = {})"
            ).format(
                sql.Identifier(SUBSCRIPTION),
                sql.SQL("true" if added else "false"),
            )
        )
    for table in removed:
        if relation_state(conn, table) is not None:
            raise RuntimeError(f"Removed table remains registered: {table}")
    deadline = time.monotonic() + timeout
    while added and time.monotonic() < deadline:
        states = {table: relation_state(conn, table) for table in added}
        if all(state == "r" for state in states.values()):
            return
        LOGGER.info("Waiting for added tables; states=%s", states)
        time.sleep(10)
    if added:
        raise TimeoutError(f"Timed out waiting for added tables: {added}")


def drop_removed_tables(conn, removed: list[str]) -> None:
    with conn.cursor() as cursor:
        for table in removed:
            cursor.execute(
                sql.SQL("DROP TABLE IF EXISTS {}.{}").format(
                    sql.Identifier(SCHEMA), sql.Identifier(table)
                )
            )


def verify(conn, added: list[str]) -> None:
    with conn.cursor() as cursor:
        cursor.execute(
            """SELECT pid FROM pg_catalog.pg_stat_subscription
               WHERE subname = %s AND relid IS NULL""",
            (SUBSCRIPTION,),
        )
        worker = cursor.fetchone()
        if not worker or worker[0] is None:
            raise RuntimeError("Logical replication apply worker is not running")
        for table in added:
            cursor.execute(
                sql.SQL("SELECT 1 FROM {}.{} LIMIT 1").format(
                    sql.Identifier(SCHEMA), sql.Identifier(table)
                )
            )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True, type=Path)
    parser.add_argument("--target", required=True, type=Path)
    parser.add_argument("--wait-timeout", type=int, default=3600)
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

    base = load_tables(args.base)
    target = load_tables(args.target)
    added, removed = transition(base, target)
    LOGGER.info(
        "Applying logical-replication transition; added=%s removed=%s",
        added, removed,
    )

    with psycopg.connect(**connection("PUBLICATION_SOURCE")) as source, psycopg.connect(
        **connection("PUBLICATION_TARGET")
    ) as subscriber:
        live = publication_tables(source)
        missing_stable = (base & target) - live
        unexpected_managed = (live & (base | target)) - target - set(removed)
        if missing_stable or unexpected_managed:
            raise RuntimeError(
                "Live managed tables do not match a safe transition: "
                f"missing_stable={sorted(missing_stable)}, "
                f"unexpected={sorted(unexpected_managed)}"
            )
        for table in added:
            columns, primary_key = source_table_definition(source, table)
            ensure_target_table(subscriber, table, columns, primary_key)
        reconcile_publication(source, added, removed)
        live_after = publication_tables(source)
        if not target.issubset(live_after) or live_after & base - target:
            raise RuntimeError("Managed publication members do not match target version")
        refresh_and_wait(subscriber, added, removed, args.wait_timeout)
        drop_removed_tables(subscriber, removed)
        verify(subscriber, added)

    LOGGER.info("Logical-replication transition applied successfully")


if __name__ == "__main__":
    main()
