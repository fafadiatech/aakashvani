from rest_framework import serializers

from apps.aakashvani.models import AudioClip, Voice


class AudioClipSerializer(serializers.ModelSerializer):
    url = serializers.SerializerMethodField()

    class Meta:
        model = AudioClip
        fields = ["id", "title", "category", "duration_ms", "source", "file", "url", "uploaded_by", "created_at"]
        read_only_fields = ["id", "created_at", "url"]

    def get_url(self, obj):
        request = self.context.get("request")
        if not obj.file:
            return None
        if request:
            return request.build_absolute_uri(obj.file.url)
        return obj.file.url


class VoiceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Voice
        fields = "__all__"
