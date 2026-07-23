from django.conf import settings
from django.utils import timezone

from apps.aakashvani.models import Broadcast, BroadcastDeviceTarget, Device, DeviceEvent


def dispatch_broadcast(broadcast_id):
    broadcast = Broadcast.objects.select_related("clip").get(id=broadcast_id)
    if broadcast.chime_id == "bell":
        _queue_bell_events_for_broadcast(broadcast)
    elif broadcast.source_type == Broadcast.SourceType.TTS:
        send_tts(broadcast)
    elif broadcast.source_type == Broadcast.SourceType.CLIP:
        send_clip(broadcast)

    broadcast.state = Broadcast.State.PLAYING
    broadcast.save(update_fields=["state", "updated_at"])
    return str(broadcast.id)


def send_tts(broadcast):
    broadcast = _as_broadcast(broadcast)
    now_iso = timezone.now().isoformat()
    events = [
        DeviceEvent(
            device=device,
            event_type=DeviceEvent.EventType.TTS,
            payload={
                "broadcast_id": str(broadcast.id),
                "text": broadcast.tts_text,
                "voice_id": broadcast.tts_voice_id or "",
                "priority": broadcast.priority,
                "created_at": now_iso,
            },
        )
        for device in _target_devices(broadcast)
    ]
    if events:
        DeviceEvent.objects.bulk_create(events)
    return len(events)


def send_clip(broadcast):
    broadcast = _as_broadcast(broadcast)
    audio_url = _clip_audio_url(broadcast)
    if not audio_url:
        return 0

    now_iso = timezone.now().isoformat()
    events = [
        DeviceEvent(
            device=device,
            event_type=DeviceEvent.EventType.CLIP,
            payload={
                "broadcast_id": str(broadcast.id),
                "clip_id": str(broadcast.clip_id) if broadcast.clip_id else "",
                "audio_url": audio_url,
                "priority": broadcast.priority,
                "created_at": now_iso,
            },
        )
        for device in _target_devices(broadcast)
    ]
    if events:
        DeviceEvent.objects.bulk_create(events)
    return len(events)


def mark_broadcast_done(broadcast_id):
    broadcast = Broadcast.objects.get(id=broadcast_id)
    broadcast.state = Broadcast.State.DONE
    broadcast.updated_at = timezone.now()
    broadcast.save(update_fields=["state", "updated_at"])


def _as_broadcast(broadcast):
    if isinstance(broadcast, Broadcast):
        return broadcast
    return Broadcast.objects.select_related("clip").get(id=broadcast)


def _target_devices(broadcast):
    if broadcast.target_all:
        return Device.objects.all()

    zone_ids = broadcast.zone_targets.values_list("zone_id", flat=True)
    explicit_ids = BroadcastDeviceTarget.objects.filter(broadcast=broadcast).values_list(
        "device_id", flat=True
    )
    return (
        Device.objects.filter(id__in=explicit_ids) | Device.objects.filter(zone_id__in=zone_ids)
    ).distinct()


def _clip_audio_url(broadcast):
    clip = broadcast.clip
    if clip is None or not clip.file:
        return None
    base = getattr(settings, "PUBLIC_BASE_URL", "http://127.0.0.1:8000").rstrip("/")
    return f"{base}{clip.file.url}"


def _queue_bell_events_for_broadcast(broadcast):
    now_iso = timezone.now().isoformat()
    events = [
        DeviceEvent(
            device=device,
            event_type=DeviceEvent.EventType.BELL,
            payload={
                "broadcast_id": str(broadcast.id),
                "chime_id": broadcast.chime_id or "bell",
                "priority": broadcast.priority,
                "created_at": now_iso,
            },
        )
        for device in _target_devices(broadcast)
    ]
    if events:
        DeviceEvent.objects.bulk_create(events)
