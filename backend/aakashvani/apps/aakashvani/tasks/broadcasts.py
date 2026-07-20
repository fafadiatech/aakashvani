from django.utils import timezone

from apps.aakashvani.models import Broadcast


def dispatch_broadcast(broadcast_id):
    broadcast = Broadcast.objects.get(id=broadcast_id)
    broadcast.state = Broadcast.State.PLAYING
    broadcast.save(update_fields=["state", "updated_at"])
    return str(broadcast.id)


def send_tts(*args, **kwargs):
    return None


def send_clip(*args, **kwargs):
    return None


def mark_broadcast_done(broadcast_id):
    broadcast = Broadcast.objects.get(id=broadcast_id)
    broadcast.state = Broadcast.State.DONE
    broadcast.updated_at = timezone.now()
    broadcast.save(update_fields=["state", "updated_at"])
