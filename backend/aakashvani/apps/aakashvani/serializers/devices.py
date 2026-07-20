from rest_framework import serializers

from apps.aakashvani.models import Device, DeviceLog
from apps.core.serializers import TimestampedSerializer


class DeviceSerializer(TimestampedSerializer):
    class Meta:
        model = Device
        fields = "__all__"
        extra_kwargs = {"api_key": {"read_only": True}}


class DeviceLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceLog
        fields = "__all__"
