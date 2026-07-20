from django.utils import timezone

from apps.aakashvani.models import Broadcast, BroadcastDeviceTarget, Device, DeviceEvent


def dispatch_broadcast(broadcast_id):
    broadcast = Broadcast.objects.get(id=broadcast_id)
    if broadcast.chime_id == "bell":
        _queue_bell_events_for_broadcast(broadcast)
    broadcast.state = Broadcast.State.PLAYING
    broadcast.save(update_fields=["state", "updated_at"])
    return str(broadcast.id)


def send_tts(*args, **kwargs):
    return None


def send_clip(*args, **kwargs):
    return None


def mark_broadcast_done(broadcast_id):
    broadcast = Broadcast.objects.get(id=broadcast_id)
    broadcast.state = Broadcast.State.DONE
    broadcast.updated_at = timezone.now()
    broadcast.save(update_fields=["state", "updated_at"])


def _queue_bell_events_for_broadcast(broadcast):
    target_devices = Device.objects.none()
    if broadcast.target_all:
        target_devices = Device.objects.all()
    else:
        zone_ids = broadcast.zone_targets.values_list("zone_id", flat=True)
        explicit_ids = BroadcastDeviceTarget.objects.filter(broadcast=broadcast).values_list("device_id", flat=True)
        target_devices = Device.objects.filter(id__in=explicit_ids) | Device.objects.filter(zone_id__in=zone_ids)
        target_devices = target_devices.distinct()

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
        for device in target_devices
    ]
    if events:
        DeviceEvent.objects.bulk_create(events)
