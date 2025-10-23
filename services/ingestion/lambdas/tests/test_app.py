import base64
import json
from unittest import mock

import app


def sample_event() -> dict:
    payload = {
        "event_id": "123",
        "event_type": "transaction",
        "occurred_at": "2024-01-01T00:00:00Z",
        "payload": {"amount": 10},
    }
    encoded = base64.b64encode(json.dumps(payload).encode("utf-8")).decode("utf-8")
    return {
        "records": {
            "topic/partition": [
                {
                    "topic": "topic",
                    "partition": 0,
                    "offset": 1,
                    "value": encoded,
                }
            ]
        }
    }


def test_handler_persists_payload(monkeypatch):
    monkeypatch.setenv("LANDING_BUCKET", "landing")
    monkeypatch.setenv("BRONZE_BUCKET", "bronze")

    put_calls = []

    def fake_put_object(**kwargs):
        put_calls.append(kwargs)

    with mock.patch.object(app, "s3") as fake_s3:
        fake_s3.put_object.side_effect = fake_put_object
        response = app.handler(sample_event(), None)

    assert response["processed_count"] == 1
    assert response["failure_count"] == 0
    assert len(put_calls) == 2
    assert put_calls[0]["Bucket"] == "landing"
    assert put_calls[1]["Bucket"] == "bronze"
