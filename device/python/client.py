from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import requests

from config import DeviceConfig


@dataclass(frozen=True)
class DeviceEvent:
    event_id: str
    event_type: str
    payload: dict[str, Any]
    created_at: str


class DeviceClient:
    def __init__(self, config: DeviceConfig) -> None:
        self._config = config
        self._session = requests.Session()
        self._session.headers.update({"Authorization": f"Device {config.api_key}"})

    def poll_next_event(self) -> DeviceEvent | None:
        url = f"{self._config.api_base_url}/devices/{self._config.device_id}/events/next/"
        response = self._session.get(url, timeout=self._config.request_timeout_seconds)
        if response.status_code == 204:
            return None
        response.raise_for_status()
        data = response.json()
        return DeviceEvent(
            event_id=str(data["id"]),
            event_type=data["event_type"],
            payload=data.get("payload", {}),
            created_at=data.get("created_at", ""),
        )

    def ack_event(self, event_id: str, status: str) -> None:
        url = f"{self._config.api_base_url}/devices/{self._config.device_id}/events/{event_id}/ack/"
        response = self._session.post(url, json={"status": status}, timeout=self._config.request_timeout_seconds)
        response.raise_for_status()
