from rest_framework import serializers

from apps.aakashvani.models import Trigger
from apps.core.serializers import TimestampedSerializer


class TriggerSerializer(TimestampedSerializer):
    class Meta:
        model = Trigger
        fields = "__all__"
