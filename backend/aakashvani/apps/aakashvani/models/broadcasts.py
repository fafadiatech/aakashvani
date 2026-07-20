from django.db import models

from apps.core.models import TimestampedModel, UUIDModel


class Broadcast(TimestampedModel):
    class State(models.TextChoices):
        PENDING = "pending", "Pending"
        PLAYING = "playing", "Playing"
        DONE = "done", "Done"
        STOPPED = "stopped", "Stopped"

    class Priority(models.TextChoices):
        NORMAL = "normal", "Normal"
        URGENT = "urgent", "Urgent"
        EMERGENCY = "emergency", "Emergency"

    class SourceType(models.TextChoices):
        TTS = "tts", "TTS"
        CLIP = "clip", "Clip"

    created_by = models.ForeignKey(
        "aakashvani.User", on_delete=models.SET_NULL, null=True, blank=True, related_name="broadcasts"
    )
    state = models.CharField(max_length=20, choices=State.choices, default=State.PENDING)
    priority = models.CharField(max_length=20, choices=Priority.choices, default=Priority.NORMAL)
    source_type = models.CharField(max_length=20, choices=SourceType.choices)
    tts_text = models.TextField(blank=True)
    tts_voice_id = models.CharField(max_length=50, blank=True)
    clip = models.ForeignKey(
        "aakashvani.AudioClip", on_delete=models.SET_NULL, null=True, blank=True, related_name="broadcasts"
    )
    chime_id = models.CharField(max_length=50, blank=True)
    target_all = models.BooleanField(default=False)


class BroadcastZoneTarget(models.Model):
    broadcast = models.ForeignKey(Broadcast, on_delete=models.CASCADE, related_name="zone_targets")
    zone = models.ForeignKey("aakashvani.Zone", on_delete=models.CASCADE)

    class Meta:
        unique_together = ("broadcast", "zone")


class BroadcastDeviceTarget(models.Model):
    broadcast = models.ForeignKey(Broadcast, on_delete=models.CASCADE, related_name="device_targets")
    device = models.ForeignKey("aakashvani.Device", on_delete=models.CASCADE)

    class Meta:
        unique_together = ("broadcast", "device")


class BroadcastAck(UUIDModel):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        PLAYED = "played", "Played"
        FAILED = "failed", "Failed"
        OFFLINE = "offline", "Offline"

    broadcast = models.ForeignKey(Broadcast, on_delete=models.CASCADE, related_name="acks")
    device = models.ForeignKey("aakashvani.Device", on_delete=models.CASCADE, related_name="broadcast_acks")
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    acknowledged_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        unique_together = ("broadcast", "device")
