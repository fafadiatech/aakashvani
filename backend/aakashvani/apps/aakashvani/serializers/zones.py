from apps.aakashvani.models import Zone
from apps.core.serializers import TimestampedSerializer


class ZoneSerializer(TimestampedSerializer):
    class Meta:
        model = Zone
        fields = "__all__"
