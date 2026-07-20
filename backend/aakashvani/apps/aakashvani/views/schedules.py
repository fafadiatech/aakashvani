from rest_framework import permissions, viewsets

from apps.aakashvani.models import Schedule, User
from apps.aakashvani.serializers import ScheduleSerializer
from apps.aakashvani.views.common import scoped_zone_ids


class ScheduleViewSet(viewsets.ModelViewSet):
    serializer_class = ScheduleSerializer
    queryset = Schedule.objects.all().order_by("-created_at")

    def get_permissions(self):
        user = self.request.user
        if self.action in ["list", "retrieve"]:
            return [permissions.IsAuthenticated()]
        if user.is_authenticated and user.role in [User.Role.ADMIN, User.Role.BROADCASTER]:
            return [permissions.IsAuthenticated()]
        return [permissions.IsAdminUser()]

    def get_queryset(self):
        qs = super().get_queryset()
        zone_ids = scoped_zone_ids(self.request.user)
        if zone_ids is not None:
            qs = qs.filter(zone_targets__zone_id__in=zone_ids).distinct()
        return qs

    def perform_create(self, serializer):
        serializer.save(created_by=self.request.user)
