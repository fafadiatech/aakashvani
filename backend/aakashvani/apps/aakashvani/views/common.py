from apps.aakashvani.models import Device, User, UserZoneScope


def scoped_zone_ids(user):
    if not user.is_authenticated or user.role == User.Role.ADMIN:
        return None
    return list(UserZoneScope.objects.filter(user=user).values_list("zone_id", flat=True))


def get_heartbeat_device(request, pk):
    auth = request.headers.get("Authorization", "")
    token = auth.replace("Device ", "", 1) if auth.startswith("Device ") else request.query_params.get("api_key")
    if not token:
        return None
    return Device.objects.filter(id=pk, api_key=token).first()
