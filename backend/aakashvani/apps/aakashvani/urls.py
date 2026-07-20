from django.urls import path
from rest_framework.routers import DefaultRouter

from apps.aakashvani.views import (
    AppSettingsView,
    AudioClipViewSet,
    BroadcastViewSet,
    DeviceViewSet,
    LoginView,
    LogoutView,
    MeView,
    ScheduleViewSet,
    SystemHealthView,
    TriggerViewSet,
    UserViewSet,
    VoiceListView,
    ZoneViewSet,
)

router = DefaultRouter()
router.register("zones", ZoneViewSet, basename="zones")
router.register("devices", DeviceViewSet, basename="devices")
router.register("broadcasts", BroadcastViewSet, basename="broadcasts")
router.register("schedules", ScheduleViewSet, basename="schedules")
router.register("library/clips", AudioClipViewSet, basename="library-clips")
router.register("admin/users", UserViewSet, basename="admin-users")
router.register("integrations/triggers", TriggerViewSet, basename="triggers")

urlpatterns = router.urls + [
    path("auth/login/", LoginView.as_view()),
    path("auth/logout/", LogoutView.as_view()),
    path("auth/me/", MeView.as_view()),
    path("library/voices/", VoiceListView.as_view()),
    path("admin/settings/", AppSettingsView.as_view()),
    path("admin/health/", SystemHealthView.as_view()),
]
