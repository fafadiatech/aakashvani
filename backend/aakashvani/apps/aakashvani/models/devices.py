import uuid

from django.db import models

from apps.core.models import TimestampedModel, UUIDModel


class Device(TimestampedModel):
    class LogLevel(models.TextChoices):
        INFO = "info", "Info"
        WARN = "warn", "Warn"
        ERROR = "error", "Error"

    name = models.CharField(max_length=100)
    zone = models.ForeignKey("aakashvani.Zone", on_delete=models.SET_NULL, null=True, blank=True)
    model = models.CharField(max_length=50)
    firmware_version = models.CharField(max_length=30, blank=True)
    volume = models.IntegerField(default=80)
    is_online = models.BooleanField(default=False)
    is_playing = models.BooleanField(default=False)
    last_seen = models.DateTimeField(null=True, blank=True)
    api_key = models.UUIDField(default=uuid.uuid4, unique=True, editable=False)

    def __str__(self):
        return self.name


class DeviceLog(UUIDModel):
    device = models.ForeignKey(Device, on_delete=models.CASCADE, related_name="logs")
    message = models.TextField()
    level = models.CharField(max_length=20, choices=Device.LogLevel.choices, default=Device.LogLevel.INFO)
    logged_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-logged_at"]


class DeviceEvent(TimestampedModel):
    class EventType(models.TextChoices):
        BELL = "bell", "Bell"
        TTS = "tts", "TTS"
        CLIP = "clip", "Clip"

    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        DELIVERED = "delivered", "Delivered"
        ACKED = "acked", "Acked"
        FAILED = "failed", "Failed"

    class AckStatus(models.TextChoices):
        PLAYED = "played", "Played"
        FAILED = "failed", "Failed"

    device = models.ForeignKey(Device, on_delete=models.CASCADE, related_name="events")
    event_type = models.CharField(max_length=30, choices=EventType.choices)
    payload = models.JSONField(default=dict, blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    delivered_at = models.DateTimeField(null=True, blank=True)
    acknowledged_at = models.DateTimeField(null=True, blank=True)
    ack_status = models.CharField(max_length=20, choices=AckStatus.choices, blank=True)

    class Meta:
        ordering = ["created_at"]


class OTAJob(UUIDModel):
    class Status(models.TextChoices):
        PENDING = "pending", "Pending"
        IN_PROGRESS = "in_progress", "In Progress"
        SUCCESS = "success", "Success"
        FAILED = "failed", "Failed"

    device = models.ForeignKey(Device, on_delete=models.CASCADE, related_name="ota_jobs")
    initiated_by = models.ForeignKey(
        "aakashvani.User", on_delete=models.SET_NULL, null=True, blank=True, related_name="ota_jobs"
    )
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PENDING)
    initiated_at = models.DateTimeField(auto_now_add=True)
    completed_at = models.DateTimeField(null=True, blank=True)
