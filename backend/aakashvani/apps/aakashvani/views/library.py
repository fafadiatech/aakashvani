from rest_framework import generics, permissions, viewsets

from apps.aakashvani.models import AudioClip, User, Voice
from apps.aakashvani.serializers import AudioClipSerializer, VoiceSerializer


class IsAdminOrBroadcasterPermission(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.role in [User.Role.ADMIN, User.Role.BROADCASTER]


class AudioClipViewSet(viewsets.ModelViewSet):
    queryset = AudioClip.objects.all().order_by("-created_at")
    serializer_class = AudioClipSerializer
    permission_classes = [IsAdminOrBroadcasterPermission]
    filterset_fields = ["category", "source"]
    search_fields = ["title", "category"]

    def perform_create(self, serializer):
        serializer.save(uploaded_by=self.request.user)


class VoiceListView(generics.ListAPIView):
    queryset = Voice.objects.all().order_by("label")
    serializer_class = VoiceSerializer
    permission_classes = [IsAdminOrBroadcasterPermission]
