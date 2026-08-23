"""Optional FUSE schema validation for standalone Tile Editor tests."""

import json
import os
import unittest
from pathlib import Path


def assert_fuse_schema_valid(test_case, document):
    try:
        from jsonschema import Draft202012Validator
    except ImportError as exc:
        raise unittest.SkipTest(
            "jsonschema is not installed; install requirements.txt"
        ) from exc

    configured = os.environ.get("FUSE_SCHEMA_PATH")
    release_root = Path(__file__).resolve().parents[2]
    candidates = [
        Path(configured) if configured else None,
        release_root / "FuseDevelopmentGroup" / "schemas" / "fuse-mod.schema.json",
        release_root / "FUSE" / "schemas" / "fuse-mod.schema.json",
    ]
    schema_path = next(
        (path for path in candidates if path is not None and path.is_file()),
        None,
    )
    if schema_path is None:
        raise unittest.SkipTest(
            "FUSE schema is not available beside this standalone checkout"
        )

    schema = json.loads(schema_path.read_text(encoding="utf-8"))
    errors = list(Draft202012Validator(schema).iter_errors(document))
    test_case.assertEqual(
        errors,
        [],
        "\n".join(error.message for error in errors),
    )
