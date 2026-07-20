from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path


def _env(name: str, default: str | None = None, required: bool = False) -> str:
    value = os.getenv(name, default)
    if required and not value:
        raise ValueError(f"Missing required environment variable: {name}")
    return value or ""


@dataclass(frozen=True)
class DeviceConfig:
    api_base_url: str
    device_id: str
    api_key: str
    poll_interval_seconds: float
    bell_file: Path
    request_timeout_seconds: float
    max_backoff_seconds: float

    @classmethod
    def from_env(cls) -> "DeviceConfig":
        base_dir = Path(__file__).resolve().parent
        default_bell = base_dir / "assets" / "bell.wav"
        return cls(
            api_base_url=_env("AAKASHVANI_API_BASE_URL", "http://127.0.0.1:8000/api/v1", required=True).rstrip("/"),
            device_id=_env("AAKASHVANI_DEVICE_ID", required=True),
            api_key=_env("AAKASHVANI_DEVICE_API_KEY", required=True),
            poll_interval_seconds=float(_env("AAKASHVANI_POLL_INTERVAL_SECONDS", "2")),
            bell_file=Path(_env("AAKASHVANI_BELL_FILE", str(default_bell))),
            request_timeout_seconds=float(_env("AAKASHVANI_REQUEST_TIMEOUT_SECONDS", "10")),
            max_backoff_seconds=float(_env("AAKASHVANI_MAX_BACKOFF_SECONDS", "30")),
        )
