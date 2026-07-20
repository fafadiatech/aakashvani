from django.db import models

from apps.core.models import TimestampedModel


class Zone(TimestampedModel):
    name = models.CharField(max_length=100, unique=True)
    default_volume = models.IntegerField(default=80)

    def __str__(self):
        return self.name
