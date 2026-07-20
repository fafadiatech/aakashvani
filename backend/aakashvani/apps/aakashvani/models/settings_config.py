from django.db import models

from apps.aakashvani.models.broadcasts import Broadcast


class AppSettings(models.Model):
    quiet_hours_enabled = models.BooleanField(default=False)
    quiet_start_time = models.TimeField(null=True, blank=True)
    quiet_end_time = models.TimeField(null=True, blank=True)
    default_priority = models.CharField(
        max_length=20, choices=Broadcast.Priority.choices, default=Broadcast.Priority.NORMAL
    )
    default_voice_id = models.CharField(max_length=50, blank=True)
    updated_at = models.DateTimeField(auto_now=True)
