from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.aakashvani.models import Trigger
from apps.aakashvani.serializers import TriggerSerializer
from apps.aakashvani.tasks import execute_trigger
from apps.core.permissions import IsAdmin


class TriggerViewSet(viewsets.ModelViewSet):
    queryset = Trigger.objects.all().order_by("-created_at")
    serializer_class = TriggerSerializer
    permission_classes = [IsAdmin]

    @action(detail=True, methods=["post"])
    def fire(self, request, pk=None):
        trigger = self.get_object()
        execute_trigger(trigger.id)
        return Response({"status": "trigger_fired", "trigger_id": str(trigger.id)})
