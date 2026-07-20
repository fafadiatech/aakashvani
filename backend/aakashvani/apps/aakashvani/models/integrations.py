from django.db import models

from apps.core.models import TimestampedModel


class Trigger(TimestampedModel):
    class Condition(models.TextChoices):
        DEVICE_OFFLINE = "device_offline", "Device Offline"
        SCHEDULE_OVERRIDE = "schedule_override", "Schedule Override"
        MANUAL_WEBHOOK = "manual_webhook", "Manual Webhook"

    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    enabled = models.BooleanField(default=True)
    condition = models.CharField(max_length=50, choices=Condition.choices)
    spec = models.JSONField(default=dict)
