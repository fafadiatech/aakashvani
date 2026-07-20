from django.db import models

from apps.aakashvani.models.broadcasts import Broadcast
from apps.core.models import TimestampedModel


class Schedule(TimestampedModel):
    class Recurrence(models.TextChoices):
        NONE = "none", "None"
        DAILY = "daily", "Daily"
        WEEKDAYS = "weekdays", "Weekdays"
        WEEKLY = "weekly", "Weekly"
        MONTHLY = "monthly", "Monthly"

    created_by = models.ForeignKey(
        "aakashvani.User", on_delete=models.SET_NULL, null=True, blank=True, related_name="schedules"
    )
    enabled = models.BooleanField(default=True)
    source_type = models.CharField(max_length=20, choices=Broadcast.SourceType.choices)
    tts_text = models.TextField(blank=True)
    tts_voice_id = models.CharField(max_length=50, blank=True)
    clip = models.ForeignKey(
        "aakashvani.AudioClip", on_delete=models.SET_NULL, null=True, blank=True, related_name="schedules"
    )
    priority = models.CharField(max_length=20, choices=Broadcast.Priority.choices, default=Broadcast.Priority.NORMAL)
    target_all = models.BooleanField(default=False)
    chime_id = models.CharField(max_length=50, blank=True)
    run_at = models.DateTimeField()
    recurrence = models.CharField(max_length=20, choices=Recurrence.choices, default=Recurrence.NONE)


class ScheduleZoneTarget(models.Model):
    schedule = models.ForeignKey(Schedule, on_delete=models.CASCADE, related_name="zone_targets")
    zone = models.ForeignKey("aakashvani.Zone", on_delete=models.CASCADE)

    class Meta:
        unique_together = ("schedule", "zone")


class ScheduleDeviceTarget(models.Model):
    schedule = models.ForeignKey(Schedule, on_delete=models.CASCADE, related_name="device_targets")
    device = models.ForeignKey("aakashvani.Device", on_delete=models.CASCADE)

    class Meta:
        unique_together = ("schedule", "device")
