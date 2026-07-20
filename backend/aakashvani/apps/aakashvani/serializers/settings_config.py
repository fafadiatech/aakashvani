from rest_framework import serializers

from apps.aakashvani.models import AppSettings


class AppSettingsSerializer(serializers.ModelSerializer):
    class Meta:
        model = AppSettings
        fields = "__all__"
