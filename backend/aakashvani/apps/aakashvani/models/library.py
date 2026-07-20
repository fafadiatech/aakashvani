from django.db import models

from apps.core.models import UUIDModel


class AudioClip(UUIDModel):
    class Source(models.TextChoices):
        UPLOADED = "uploaded", "Uploaded"
        RECORDED = "recorded", "Recorded"
        TTS = "tts", "TTS"

    title = models.CharField(max_length=200)
    category = models.CharField(max_length=100, blank=True)
    duration_ms = models.IntegerField(default=0)
    source = models.CharField(max_length=20, choices=Source.choices, default=Source.UPLOADED)
    file = models.FileField(upload_to="clips/")
    uploaded_by = models.ForeignKey(
        "aakashvani.User", on_delete=models.SET_NULL, null=True, blank=True, related_name="clips"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return self.title


class Voice(models.Model):
    id = models.CharField(primary_key=True, max_length=50)
    label = models.CharField(max_length=100)
    language_code = models.CharField(max_length=10)

    def __str__(self):
        return self.label
