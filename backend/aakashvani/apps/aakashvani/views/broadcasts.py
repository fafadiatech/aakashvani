from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.aakashvani.models import (
    AppSettings,
    Broadcast,
    BroadcastAck,
    BroadcastDeviceTarget,
    Device,
)
from apps.aakashvani.serializers import BroadcastSerializer
from apps.aakashvani.tasks import dispatch_broadcast
from apps.aakashvani.views.common import scoped_zone_ids
from apps.core.exceptions import QuietHoursActiveError
from apps.core.permissions import IsAdminOrBroadcaster


class BroadcastViewSet(viewsets.ModelViewSet):
    serializer_class = BroadcastSerializer
    permission_classes = [IsAdminOrBroadcaster]
    queryset = Broadcast.objects.all().order_by("-created_at")

    def get_queryset(self):
        qs = super().get_queryset()
        zone_ids = scoped_zone_ids(self.request.user)
        if zone_ids is not None:
            qs = qs.filter(zone_targets__zone_id__in=zone_ids).distinct()
        return qs

    def _validate_quiet_hours(self, priority):
        settings_obj = AppSettings.objects.first()
        if not settings_obj or not settings_obj.quiet_hours_enabled:
            return
        if priority == Broadcast.Priority.EMERGENCY:
            return
        if not settings_obj.quiet_start_time or not settings_obj.quiet_end_time:
            return
        now_t = timezone.localtime().time()
        if settings_obj.quiet_start_time <= now_t <= settings_obj.quiet_end_time:
            raise QuietHoursActiveError("Broadcast blocked by quiet hours.")

    def perform_create(self, serializer):
        self._validate_quiet_hours(self.request.data.get("priority"))
        broadcast = serializer.save(created_by=self.request.user, state=Broadcast.State.PENDING)

        target_devices = Device.objects.none()
        if broadcast.target_all:
            target_devices = Device.objects.all()
        else:
            zone_ids = broadcast.zone_targets.values_list("zone_id", flat=True)
            explicit_ids = BroadcastDeviceTarget.objects.filter(broadcast=broadcast).values_list(
                "device_id", flat=True
            )
            target_devices = Device.objects.filter(id__in=explicit_ids) | Device.objects.filter(zone_id__in=zone_ids)
            target_devices = target_devices.distinct()

        for device in target_devices:
            BroadcastAck.objects.get_or_create(broadcast=broadcast, device=device)

        dispatch_broadcast(broadcast.id)

    @action(detail=True, methods=["post"])
    def stop(self, request, pk=None):
        broadcast = self.get_object()
        if broadcast.state in [Broadcast.State.DONE, Broadcast.State.STOPPED]:
            return Response({"state": broadcast.state})
        broadcast.state = Broadcast.State.STOPPED
        broadcast.save(update_fields=["state", "updated_at"])
        return Response({"state": broadcast.state})

    @action(detail=False, methods=["post"], url_path="ring-bell")
    def ring_bell(self, request):
        payload = {
            "source_type": "tts",
            "tts_text": "Bell",
            "priority": request.data.get("priority", Broadcast.Priority.NORMAL),
            "target_all": request.data.get("target_all", False),
            "chime_id": request.data.get("chime_id", "bell"),
            "zone_targets": request.data.get("zone_targets", []),
            "device_targets": request.data.get("device_targets", []),
        }
        serializer = self.get_serializer(data=payload)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
