from rest_framework import serializers


class TimestampedSerializer(serializers.ModelSerializer):
    def get_fields(self):
        fields = super().get_fields()
        for key in ("id", "created_at", "updated_at"):
            if key in fields:
                fields[key].read_only = True
        return fields
