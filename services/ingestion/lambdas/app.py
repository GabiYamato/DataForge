import base64
import json
import os
import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List

import boto3
from jsonschema import Draft202012Validator, FormatChecker, ValidationError

s3 = boto3.client("s3")

LANDING_BUCKET = os.environ.get("LANDING_BUCKET", "")
BRONZE_BUCKET = os.environ.get("BRONZE_BUCKET", "")
GLUE_DATABASE = os.environ.get("GLUE_DATABASE", "")
KAFKA_BROKERS = os.environ.get("KAFKA_BROKERS", "")

REQUIRED_FIELDS = {"event_id", "event_type", "occurred_at"}

EVENT_SCHEMA = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "required": ["event_id", "event_type", "occurred_at"],
    "properties": {
        "event_id": {"type": "string"},
        "event_type": {"type": "string"},
        "occurred_at": {"type": "string", "format": "date-time"},
        "payload": {"type": "object"},
        "source": {"type": "string"},
    },
    "additionalProperties": True,
}

VALIDATOR = Draft202012Validator(EVENT_SCHEMA, format_checker=FormatChecker())

def handler(event: Dict[str, Any], _context: Any) -> Dict[str, Any]:
    """AWS Lambda entry point for MSK ingestion."""
    if not LANDING_BUCKET or not BRONZE_BUCKET:
        raise RuntimeError("Bucket environment variables must be configured")

    processed: List[Dict[str, Any]] = []
    failures: List[str] = []

    for topic_partition, records in event.get("records", {}).items():
        for record in records:
            decoded, err = _decode_record(record)
            if err:
                failures.append(err)
                continue

            quality_ok, quality_error = _validate_schema(decoded)
            metadata = {
                "topic_partition": topic_partition,
                "offset": record.get("offset"),
                "partition": record.get("partition"),
            }

            landing_key = _persist_landing(decoded, metadata)

            if quality_ok:
                bronze_key = _persist_bronze(decoded)
            else:
                bronze_key = None
                failures.append(quality_error or "schema validation failed")

            processed.append(
                {
                    "landing_key": landing_key,
                    "bronze_key": bronze_key,
                    "metadata": metadata,
                }
            )

    return {
        "processed_count": len(processed),
        "failure_count": len(failures),
        "failures": failures,
        "glue_database": GLUE_DATABASE,
        "kafka_brokers": KAFKA_BROKERS,
    }

def _decode_record(record: Dict[str, Any]) -> tuple[Dict[str, Any], str | None]:
    try:
        payload = record.get("value")
        if payload is None:
            return {}, "missing payload"
        data = base64.b64decode(payload)
        return json.loads(data), None
    except Exception as exc:  # noqa: BLE001
        return {}, f"decode_error:{exc}"


def _validate_schema(payload: Dict[str, Any]) -> tuple[bool, str | None]:
    missing = REQUIRED_FIELDS - payload.keys()
    if missing:
        return False, f"missing_fields:{','.join(sorted(missing))}"

    try:
        VALIDATOR.validate(payload)
    except ValidationError as exc:
        return False, f"schema_error:{exc.message}"

    return True, None


def _persist_landing(payload: Dict[str, Any], metadata: Dict[str, Any]) -> str:
    timestamp = datetime.now(timezone.utc).strftime("%Y/%m/%d/%H")
    key = f"landing/topic={metadata.get('topic_partition').split('/')[-1]}/{timestamp}/{uuid.uuid4()}.json"
    body = json.dumps({"payload": payload, "metadata": metadata}).encode("utf-8")
    s3.put_object(Bucket=LANDING_BUCKET, Key=key, Body=body)
    return key


def _persist_bronze(payload: Dict[str, Any]) -> str:
    timestamp = datetime.now(timezone.utc).strftime("%Y/%m/%d/%H")
    key = f"bronze/event_type={payload['event_type']}/{timestamp}/{payload['event_id']}.json"
    s3.put_object(Bucket=BRONZE_BUCKET, Key=key, Body=json.dumps(payload).encode("utf-8"))
    return key
