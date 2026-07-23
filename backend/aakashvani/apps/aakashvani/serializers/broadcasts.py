from rest_framework import serializers

from apps.aakashvani.models import (
    Broadcast,
    BroadcastAck,
    BroadcastDeviceTarget,
    BroadcastZoneTarget,
    Device,
    Zone,
)
from apps.core.serializers import TimestampedSerializer


class BroadcastAckSerializer(serializers.ModelSerializer):
    device_name = serializers.CharField(source="device.name", read_only=True)
    zone_name = serializers.SerializerMethodField()

    class Meta:
        model = BroadcastAck
        fields = "__all__"

    def get_zone_name(self, obj):
        zone = obj.device.zone
        return zone.name if zone else None


class BroadcastSerializer(TimestampedSerializer):
    zone_targets = serializers.ListField(child=serializers.UUIDField(), write_only=True, required=False)
    device_targets = serializers.ListField(child=serializers.UUIDField(), write_only=True, required=False)
    acks = BroadcastAckSerializer(many=True, read_only=True)

    class Meta:
        model = Broadcast
        fields = "__all__"

    def create(self, validated_data):
        zone_ids = validated_data.pop("zone_targets", [])
        device_ids = validated_data.pop("device_targets", [])
        broadcast = Broadcast.objects.create(**validated_data)

        zones = Zone.objects.filter(id__in=zone_ids)
        devices = Device.objects.filter(id__in=device_ids)
        for zone in zones:
            BroadcastZoneTarget.objects.get_or_create(broadcast=broadcast, zone=zone)
        for device in devices:
            BroadcastDeviceTarget.objects.get_or_create(broadcast=broadcast, device=device)
        return broadcast
