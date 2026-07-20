from rest_framework import permissions, viewsets

from apps.aakashvani.models import Zone
from apps.aakashvani.serializers import ZoneSerializer
from apps.aakashvani.views.common import scoped_zone_ids
from apps.core.permissions import IsAdmin


class ZoneViewSet(viewsets.ModelViewSet):
    serializer_class = ZoneSerializer
    queryset = Zone.objects.all().order_by("name")

    def get_permissions(self):
        if self.action in ["list", "retrieve"]:
            return [permissions.IsAuthenticated()]
        return [IsAdmin()]

    def get_queryset(self):
        qs = super().get_queryset()
        zone_ids = scoped_zone_ids(self.request.user)
        if zone_ids is not None:
            qs = qs.filter(id__in=zone_ids)
        return qs
