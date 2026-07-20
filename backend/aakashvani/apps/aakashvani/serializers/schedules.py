from rest_framework import serializers

from apps.aakashvani.models import Device, Schedule, ScheduleDeviceTarget, ScheduleZoneTarget, Zone
from apps.core.serializers import TimestampedSerializer


class ScheduleSerializer(TimestampedSerializer):
    zone_targets = serializers.ListField(child=serializers.UUIDField(), write_only=True, required=False)
    device_targets = serializers.ListField(child=serializers.UUIDField(), write_only=True, required=False)

    class Meta:
        model = Schedule
        fields = "__all__"

    def create(self, validated_data):
        zone_ids = validated_data.pop("zone_targets", [])
        device_ids = validated_data.pop("device_targets", [])
        schedule = Schedule.objects.create(**validated_data)
        for zone in Zone.objects.filter(id__in=zone_ids):
            ScheduleZoneTarget.objects.get_or_create(schedule=schedule, zone=zone)
        for device in Device.objects.filter(id__in=device_ids):
            ScheduleDeviceTarget.objects.get_or_create(schedule=schedule, device=device)
        return schedule
