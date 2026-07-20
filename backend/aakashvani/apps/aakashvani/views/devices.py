from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.aakashvani.models import Device, DeviceLog, OTAJob
from apps.aakashvani.serializers import DeviceLogSerializer, DeviceSerializer
from apps.aakashvani.views.common import get_heartbeat_device
from apps.core.permissions import IsAdmin


class DeviceViewSet(viewsets.ModelViewSet):
    queryset = Device.objects.all().order_by("-created_at")
    serializer_class = DeviceSerializer
    permission_classes = [IsAdmin]

    @action(detail=True, methods=["post"], permission_classes=[IsAdmin])
    def ota(self, request, pk=None):
        job = OTAJob.objects.create(device=self.get_object(), initiated_by=request.user)
        return Response({"ota_job_id": str(job.id), "status": job.status})

    @action(detail=True, methods=["get"], permission_classes=[IsAdmin])
    def logs(self, request, pk=None):
        logs = DeviceLog.objects.filter(device=self.get_object())
        return Response(DeviceLogSerializer(logs, many=True).data)

    @action(detail=True, methods=["post"], permission_classes=[permissions.AllowAny])
    def heartbeat(self, request, pk=None):
        device = get_heartbeat_device(request, pk)
        if device is None:
            return Response({"detail": "Invalid device credentials."}, status=status.HTTP_401_UNAUTHORIZED)
        device.is_online = True
        device.last_seen = timezone.now()
        if "firmware_version" in request.data:
            device.firmware_version = request.data["firmware_version"]
        device.save(update_fields=["is_online", "last_seen", "firmware_version", "updated_at"])
        return Response({"status": "ok"})
