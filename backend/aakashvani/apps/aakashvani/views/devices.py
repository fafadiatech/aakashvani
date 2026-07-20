from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.aakashvani.models import Broadcast, BroadcastAck, Device, DeviceEvent, DeviceLog, OTAJob
from apps.aakashvani.serializers import DeviceEventSerializer, DeviceLogSerializer, DeviceSerializer
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

    @action(detail=True, methods=["get"], permission_classes=[permissions.AllowAny], url_path="events/next")
    def events_next(self, request, pk=None):
        device = get_heartbeat_device(request, pk)
        if device is None:
            return Response({"detail": "Invalid device credentials."}, status=status.HTTP_401_UNAUTHORIZED)

        event = (
            DeviceEvent.objects.filter(
                device=device,
                status__in=[DeviceEvent.Status.PENDING, DeviceEvent.Status.DELIVERED],
            )
            .order_by("created_at")
            .first()
        )
        if event is None:
            return Response(status=status.HTTP_204_NO_CONTENT)

        now = timezone.now()
        if event.status == DeviceEvent.Status.PENDING:
            event.status = DeviceEvent.Status.DELIVERED
            event.delivered_at = now
            event.save(update_fields=["status", "delivered_at", "updated_at"])
        return Response(DeviceEventSerializer(event).data)

    @action(
        detail=True,
        methods=["post"],
        permission_classes=[permissions.AllowAny],
        url_path=r"events/(?P<event_id>[^/.]+)/ack",
    )
    def ack_event(self, request, pk=None, event_id=None):
        device = get_heartbeat_device(request, pk)
        if device is None:
            return Response({"detail": "Invalid device credentials."}, status=status.HTTP_401_UNAUTHORIZED)

        event = DeviceEvent.objects.filter(id=event_id, device=device).first()
        if event is None:
            return Response({"detail": "Event not found."}, status=status.HTTP_404_NOT_FOUND)

        ack_status = request.data.get("status", "").lower()
        if ack_status not in [DeviceEvent.AckStatus.PLAYED, DeviceEvent.AckStatus.FAILED]:
            return Response(
                {"detail": "status must be one of: played, failed"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        now = timezone.now()
        event.acknowledged_at = now
        event.ack_status = ack_status
        event.status = DeviceEvent.Status.ACKED if ack_status == DeviceEvent.AckStatus.PLAYED else DeviceEvent.Status.FAILED
        event.save(update_fields=["status", "ack_status", "acknowledged_at", "updated_at"])

        if event.payload.get("broadcast_id"):
            broadcast_id = event.payload.get("broadcast_id")
            ack = BroadcastAck.objects.filter(
                broadcast_id=broadcast_id,
                device=device,
            ).first()
            if ack is not None:
                ack.status = (
                    BroadcastAck.Status.PLAYED if ack_status == DeviceEvent.AckStatus.PLAYED else BroadcastAck.Status.FAILED
                )
                ack.acknowledged_at = now
                ack.save(update_fields=["status", "acknowledged_at"])
                has_pending = BroadcastAck.objects.filter(
                    broadcast_id=broadcast_id,
                    status=BroadcastAck.Status.PENDING,
                ).exists()
                if not has_pending:
                    Broadcast.objects.filter(id=broadcast_id).update(
                        state=Broadcast.State.DONE,
                        updated_at=now,
                    )

        return Response({"status": event.status, "ack_status": event.ack_status})
