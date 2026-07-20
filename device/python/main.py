from __future__ import annotations

import argparse
import logging
import sys
import time

from client import DeviceClient
from config import DeviceConfig
from player import BellPlayer


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Aakashvani Raspberry Pi bell listener")
    parser.add_argument("--no-play", action="store_true", help="Poll and ack without playing audio")
    parser.add_argument("--once", action="store_true", help="Poll once and exit")
    return parser.parse_args()


def main() -> int:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )
    args = parse_args()

    try:
        config = DeviceConfig.from_env()
    except ValueError as exc:
        logging.error("%s", exc)
        return 1

    client = DeviceClient(config)
    player = BellPlayer(config.bell_file, no_play=args.no_play)
    backoff = config.poll_interval_seconds

    logging.info(
        "Starting bell listener for device=%s poll_interval=%ss",
        config.device_id,
        config.poll_interval_seconds,
    )

    while True:
        try:
            event = client.poll_next_event()
            backoff = config.poll_interval_seconds
        except Exception:
            logging.exception("Polling failed")
            time.sleep(backoff)
            backoff = min(backoff * 2, config.max_backoff_seconds)
            if args.once:
                return 2
            continue

        if event is None:
            if args.once:
                return 0
            time.sleep(config.poll_interval_seconds)
            continue

        logging.info("Received event id=%s type=%s", event.event_id, event.event_type)
        ack_status = "played"
        try:
            if event.event_type == "bell":
                player.play()
            else:
                logging.warning("Unsupported event type: %s", event.event_type)
                ack_status = "failed"
        except Exception:
            logging.exception("Failed to handle event id=%s", event.event_id)
            ack_status = "failed"

        try:
            client.ack_event(event.event_id, ack_status)
            logging.info("Acked event id=%s status=%s", event.event_id, ack_status)
        except Exception:
            logging.exception("Failed to ack event id=%s", event.event_id)
            if args.once:
                return 3

        if args.once:
            return 0


if __name__ == "__main__":
    sys.exit(main())
