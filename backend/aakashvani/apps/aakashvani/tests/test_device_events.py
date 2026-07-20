from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from apps.aakashvani.models import Broadcast, BroadcastAck, Device, DeviceEvent, Zone
from apps.aakashvani.tasks.broadcasts import dispatch_broadcast


class DeviceEventApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.zone = Zone.objects.create(name="Main Hall")
        self.device = Device.objects.create(name="Pi Speaker", model="Raspberry Pi 4", zone=self.zone)
        self.auth_headers = {"HTTP_AUTHORIZATION": f"Device {self.device.api_key}"}

    def test_poll_returns_204_when_queue_empty(self):
        url = reverse("v1:devices-events-next", kwargs={"pk": self.device.id})
        response = self.client.get(url, **self.auth_headers)
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)

    def test_poll_returns_next_pending_event(self):
        event = DeviceEvent.objects.create(
            device=self.device,
            event_type=DeviceEvent.EventType.BELL,
            payload={"broadcast_id": "abc", "chime_id": "bell"},
        )
        url = reverse("v1:devices-events-next", kwargs={"pk": self.device.id})
        response = self.client.get(url, **self.auth_headers)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["id"], str(event.id))
        event.refresh_from_db()
        self.assertEqual(event.status, DeviceEvent.Status.DELIVERED)
        self.assertIsNotNone(event.delivered_at)

    def test_ack_updates_event_and_broadcast_ack(self):
        broadcast = Broadcast.objects.create(
            source_type=Broadcast.SourceType.TTS,
            tts_text="Bell",
            chime_id="bell",
            target_all=True,
        )
        ack = BroadcastAck.objects.create(broadcast=broadcast, device=self.device)
        event = DeviceEvent.objects.create(
            device=self.device,
            event_type=DeviceEvent.EventType.BELL,
            payload={"broadcast_id": str(broadcast.id), "chime_id": "bell"},
            status=DeviceEvent.Status.DELIVERED,
        )

        url = reverse("v1:devices-ack-event", kwargs={"pk": self.device.id, "event_id": event.id})
        response = self.client.post(url, {"status": "played"}, format="json", **self.auth_headers)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        event.refresh_from_db()
        ack.refresh_from_db()
        broadcast.refresh_from_db()
        self.assertEqual(event.status, DeviceEvent.Status.ACKED)
        self.assertEqual(event.ack_status, DeviceEvent.AckStatus.PLAYED)
        self.assertEqual(ack.status, BroadcastAck.Status.PLAYED)
        self.assertEqual(broadcast.state, Broadcast.State.DONE)


class BellDispatchTests(TestCase):
    def setUp(self):
        self.zone = Zone.objects.create(name="Cafeteria")
        self.device = Device.objects.create(name="Pi Bell", model="Raspberry Pi 4", zone=self.zone)

    def test_dispatch_creates_bell_events_for_targets(self):
        broadcast = Broadcast.objects.create(
            source_type=Broadcast.SourceType.TTS,
            tts_text="Bell",
            chime_id="bell",
            target_all=False,
        )
        broadcast.zone_targets.create(zone=self.zone)
        BroadcastAck.objects.create(broadcast=broadcast, device=self.device)

        dispatch_broadcast(broadcast.id)

        events = DeviceEvent.objects.filter(device=self.device, event_type=DeviceEvent.EventType.BELL)
        self.assertEqual(events.count(), 1)
        self.assertEqual(events.first().payload["chime_id"], "bell")
        broadcast.refresh_from_db()
        self.assertEqual(broadcast.state, Broadcast.State.PLAYING)
