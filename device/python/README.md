# Aakashvani Raspberry Pi Bell Listener

Python polling daemon for Raspberry Pi that listens for bell events from the Aakashvani backend and plays a local bell sound.

## How it works

1. Flutter app calls `POST /api/v1/broadcasts/ring-bell/`.
2. Backend creates per-device `DeviceEvent` records with `event_type=bell`.
3. This daemon polls `GET /api/v1/devices/{device_id}/events/next/` every 2 seconds.
4. When an event is received, the daemon plays `assets/bell.wav`.
5. The daemon acks with `POST /api/v1/devices/{device_id}/events/{event_id}/ack/`.

## Setup

```bash
cd device
python3 -m venv .venv
source .venv/bin/activate  # Linux/macOS
pip install -r requirements.txt
cp .env.example .env
```

Edit `.env` with your backend URL, device ID, and device API key from Django admin.

Install audio tools on Raspberry Pi:

```bash
sudo apt update
sudo apt install -y alsa-utils
```

## Run manually

```bash
cd device
source .venv/bin/activate
set -a && source .env && set +a
python main.py
```

Dry-run without audio:

```bash
python main.py --no-play
```

Poll once and exit:

```bash
python main.py --once --no-play
```

## systemd service

```bash
sudo cp aakashvani-device.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable aakashvani-device
sudo systemctl start aakashvani-device
sudo systemctl status aakashvani-device
```

Logs:

```bash
journalctl -u aakashvani-device -f
```

## End-to-end validation checklist

1. Create a `Device` in Django admin and copy its `id` and `api_key`.
2. Put those values in `device/.env`.
3. Start backend and run `python main.py --no-play` on the Pi (or locally).
4. Login as broadcaster and call:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/broadcasts/ring-bell/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"zone_targets":["<zone-uuid>"]}'
```

5. Confirm daemon logs show event received and acked with `played`.
6. Remove `--no-play` and confirm bell audio plays on the Pi.

## API contract

- Auth header: `Authorization: Device <api_key>`
- Query fallback: `?api_key=<api_key>`
- Poll: `GET /devices/{id}/events/next/` returns `204` when queue is empty
- Ack body: `{"status":"played"}` or `{"status":"failed"}`
