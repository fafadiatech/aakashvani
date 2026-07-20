from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.aakashvani.models import AppSettings, Device, User
from apps.aakashvani.serializers import AppSettingsSerializer


class AdminOnlyMixin:
    permission_classes = [IsAuthenticated]

    def check_permissions(self, request):
        super().check_permissions(request)
        if request.user.role != User.Role.ADMIN:
            self.permission_denied(request, message="Admin access required.")


class AppSettingsView(AdminOnlyMixin, APIView):
    def get(self, request):
        settings_obj, _ = AppSettings.objects.get_or_create(id=1)
        return Response(AppSettingsSerializer(settings_obj).data)

    def put(self, request):
        settings_obj, _ = AppSettings.objects.get_or_create(id=1)
        serializer = AppSettingsSerializer(settings_obj, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)


class SystemHealthView(AdminOnlyMixin, APIView):
    def get(self, request):
        total = Device.objects.count()
        online = Device.objects.filter(is_online=True).count()
        playing = Device.objects.filter(is_playing=True).count()
        return Response({"total_devices": total, "online_devices": online, "playing_devices": playing})
