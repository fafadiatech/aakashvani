# Aakashvani Raspberry Pi Device Listener

Python polling daemon for Raspberry Pi that listens for broadcast events from the Aakashvani backend and plays audio.

## How it works

1. App creates a broadcast (`POST /api/v1/broadcasts/` or `ring-bell/`).
2. Backend queues per-device `DeviceEvent` records (`bell`, `tts`, or `clip`).
3. This daemon polls `GET /api/v1/devices/{device_id}/events/next/` every 2 seconds.
4. On receive:
   - `bell` — plays local `assets/bell.wav`
   - `tts` — speaks `payload.text` via `espeak-ng` / `espeak` / `say`
   - `clip` — downloads `payload.audio_url` and plays it
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
sudo apt install -y alsa-utils espeak-ng
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

Or send a TTS announcement:

```bash
curl -X POST http://127.0.0.1:8000/api/v1/broadcasts/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "source_type": "tts",
    "tts_text": "Assembly in five minutes",
    "tts_voice_id": "en-IN-F",
    "priority": "normal",
    "target_all": false,
    "zone_targets": ["<zone-uuid>"]
  }'
```

5. Confirm the daemon logs the event and acks `played`.
6. Confirm broadcast acks move to `played` in the API / Flutter delivery screen.

For clip playback, ensure `PUBLIC_BASE_URL` on the backend is reachable from the device (default `http://127.0.0.1:8000`).
