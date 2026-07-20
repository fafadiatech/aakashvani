from datetime import timedelta

from django.core.management.base import BaseCommand, CommandError
from django.db import transaction
from django.utils import timezone

from apps.aakashvani.models import (
    AppSettings,
    Broadcast,
    BroadcastAck,
    BroadcastDeviceTarget,
    BroadcastZoneTarget,
    Device,
    DeviceLog,
    OTAJob,
    Schedule,
    ScheduleDeviceTarget,
    ScheduleZoneTarget,
    Trigger,
    User,
    UserZoneScope,
    Voice,
    Zone,
)

MARKER = "[load_testing_data]"
ZONE_PREFIX = "test-zone"
DEVICE_PREFIX = "test-device"
TEST_EMAIL_DOMAIN = "loadtest.aakashvani.local"

USERS = [
    {
        "email": f"admin@{TEST_EMAIL_DOMAIN}",
        "name": "Load Test Admin",
        "password": "admin123",
        "role": User.Role.ADMIN,
        "is_staff": True,
        "is_superuser": True,
    },
    {
        "email": f"broadcaster@{TEST_EMAIL_DOMAIN}",
        "name": "Load Test Broadcaster",
        "password": "broadcaster123",
        "role": User.Role.BROADCASTER,
        "is_staff": False,
        "is_superuser": False,
    },
    {
        "email": f"viewer@{TEST_EMAIL_DOMAIN}",
        "name": "Load Test Viewer",
        "password": "viewer123",
        "role": User.Role.VIEWER,
        "is_staff": False,
        "is_superuser": False,
    },
]

VOICES = [
    ("en-IN-F", "English India Female", "en-IN"),
    ("hi-IN-F", "Hindi India Female", "hi-IN"),
    ("en-IN-M", "English India Male", "en-IN"),
]


class Command(BaseCommand):
    help = "Generate linked fixtures for integration and load testing."

    def add_arguments(self, parser):
        parser.add_argument("--zones", type=int, default=3, help="Number of test zones to create.")
        parser.add_argument("--devices-per-zone", type=int, default=4, help="Number of test devices per zone.")
        parser.add_argument("--broadcasts", type=int, default=6, help="Number of test broadcasts.")
        parser.add_argument("--schedules", type=int, default=6, help="Number of test schedules.")
        parser.add_argument("--logs-per-device", type=int, default=2, help="Number of logs to create per device.")
        parser.add_argument("--ota-per-device", type=int, default=1, help="Number of OTA jobs per device.")
        parser.add_argument("--triggers", type=int, default=3, help="Number of test triggers.")
        parser.add_argument("--reset", action="store_true", help="Delete previously generated fixtures first.")

    def handle(self, *args, **options):
        self._validate_non_negative(options)
        counters = {"created": 0, "updated": 0}
        deleted = {}

        with transaction.atomic():
            if options["reset"]:
                deleted = self._reset_generated_data()

            AppSettings.objects.get_or_create(id=1)
            self._seed_voices(counters)
            users = self._seed_users(counters)
            zones = self._seed_zones(options["zones"], counters)
            devices = self._seed_devices(zones, options["devices_per_zone"], counters)
            self._seed_user_zone_scopes(users, zones, counters)
            self._seed_broadcasts(users, zones, devices, options["broadcasts"], counters)
            self._seed_schedules(users, zones, devices, options["schedules"], counters)
            self._seed_device_logs(devices, options["logs_per_device"], counters)
            self._seed_ota_jobs(users, devices, options["ota_per_device"], counters)
            self._seed_triggers(options["triggers"], counters)

        if deleted:
            self.stdout.write(self.style.WARNING(f"Deleted previously generated records: {deleted}"))
        self.stdout.write(self.style.SUCCESS(f"Load testing data complete. Created={counters['created']} Updated={counters['updated']}"))

    def _validate_non_negative(self, options):
        numeric_options = [
            "zones",
            "devices_per_zone",
            "broadcasts",
            "schedules",
            "logs_per_device",
            "ota_per_device",
            "triggers",
        ]
        for option in numeric_options:
            if options[option] < 0:
                raise CommandError(f"--{option.replace('_', '-')} must be >= 0")

    def _count_result(self, counters, created):
        key = "created" if created else "updated"
        counters[key] += 1

    def _seed_voices(self, counters):
        for voice_id, label, language_code in VOICES:
            _, created = Voice.objects.update_or_create(
                id=voice_id, defaults={"label": label, "language_code": language_code}
            )
            self._count_result(counters, created)

    def _seed_users(self, counters):
        users = {}
        for user_data in USERS:
            data = {**user_data}
            password = data.pop("password")
            email = data.pop("email")
            user, created = User.objects.update_or_create(email=email, defaults=data)
            user.set_password(password)
            user.save(update_fields=["password"])
            self._count_result(counters, created)
            users[user.role] = user
        return users

    def _seed_zones(self, count, counters):
        zones = []
        for index in range(1, count + 1):
            zone_name = f"{ZONE_PREFIX}-{index:03d}"
            zone, created = Zone.objects.update_or_create(
                name=zone_name,
                defaults={"default_volume": 55 + (index % 35)},
            )
            self._count_result(counters, created)
            zones.append(zone)
        return zones

    def _seed_devices(self, zones, devices_per_zone, counters):
        devices = []
        serial = 1
        for zone in zones:
            for local_index in range(1, devices_per_zone + 1):
                device_name = f"{DEVICE_PREFIX}-{serial:04d}"
                defaults = {
                    "zone": zone,
                    "model": f"AV-{(local_index % 3) + 1}",
                    "firmware_version": f"v1.{serial % 10}.{local_index % 5}",
                    "volume": max(40, zone.default_volume - 5 + (local_index % 8)),
                    "is_online": (serial % 3) != 0,
                    "is_playing": serial % 4 == 0,
                    "last_seen": timezone.now() - timedelta(minutes=serial),
                }
                device, created = Device.objects.update_or_create(name=device_name, defaults=defaults)
                self._count_result(counters, created)
                devices.append(device)
                serial += 1
        return devices

    def _seed_user_zone_scopes(self, users, zones, counters):
        scoped_users = [users[User.Role.BROADCASTER], users[User.Role.VIEWER]]
        for user in scoped_users:
            for zone in zones:
                _, created = UserZoneScope.objects.get_or_create(user=user, zone=zone)
                self._count_result(counters, created)

    def _seed_broadcasts(self, users, zones, devices, count, counters):
        priorities = [Broadcast.Priority.NORMAL, Broadcast.Priority.URGENT, Broadcast.Priority.EMERGENCY]
        states = [Broadcast.State.PENDING, Broadcast.State.PLAYING, Broadcast.State.DONE, Broadcast.State.STOPPED]
        for index in range(1, count + 1):
            message = f"{MARKER} Broadcast {index:03d}"
            defaults = {
                "created_by": users[User.Role.BROADCASTER],
                "state": states[(index - 1) % len(states)],
                "priority": priorities[(index - 1) % len(priorities)],
                "source_type": Broadcast.SourceType.TTS,
                "tts_voice_id": VOICES[(index - 1) % len(VOICES)][0],
                "chime_id": f"chime-{index:03d}",
                "target_all": index % 4 == 0,
            }
            broadcast, created = Broadcast.objects.update_or_create(tts_text=message, defaults=defaults)
            self._count_result(counters, created)

            BroadcastZoneTarget.objects.filter(broadcast=broadcast).delete()
            BroadcastDeviceTarget.objects.filter(broadcast=broadcast).delete()

            if not broadcast.target_all and zones and devices:
                zone = zones[(index - 1) % len(zones)]
                device = devices[(index - 1) % len(devices)]
                _, created = BroadcastZoneTarget.objects.get_or_create(broadcast=broadcast, zone=zone)
                self._count_result(counters, created)
                _, created = BroadcastDeviceTarget.objects.get_or_create(broadcast=broadcast, device=device)
                self._count_result(counters, created)

            for offset in range(min(3, len(devices))):
                device = devices[(index + offset - 1) % len(devices)]
                ack_status = [
                    BroadcastAck.Status.PENDING,
                    BroadcastAck.Status.PLAYED,
                    BroadcastAck.Status.FAILED,
                ][offset % 3]
                ack_defaults = {
                    "status": ack_status,
                    "acknowledged_at": timezone.now() - timedelta(minutes=index + offset),
                }
                ack, created = BroadcastAck.objects.update_or_create(
                    broadcast=broadcast, device=device, defaults=ack_defaults
                )
                if ack.status == BroadcastAck.Status.PENDING:
                    ack.acknowledged_at = None
                    ack.save(update_fields=["acknowledged_at"])
                self._count_result(counters, created)

    def _seed_schedules(self, users, zones, devices, count, counters):
        recurrences = [
            Schedule.Recurrence.NONE,
            Schedule.Recurrence.DAILY,
            Schedule.Recurrence.WEEKDAYS,
            Schedule.Recurrence.WEEKLY,
            Schedule.Recurrence.MONTHLY,
        ]
        priorities = [Broadcast.Priority.NORMAL, Broadcast.Priority.URGENT, Broadcast.Priority.EMERGENCY]
        for index in range(1, count + 1):
            tts_text = f"{MARKER} Schedule {index:03d}"
            run_at = timezone.now() + timedelta(hours=index)
            defaults = {
                "created_by": users[User.Role.BROADCASTER],
                "enabled": index % 5 != 0,
                "source_type": Broadcast.SourceType.TTS,
                "tts_voice_id": VOICES[(index - 1) % len(VOICES)][0],
                "priority": priorities[(index - 1) % len(priorities)],
                "target_all": index % 3 == 0,
                "chime_id": f"schedule-chime-{index:03d}",
                "run_at": run_at,
                "recurrence": recurrences[(index - 1) % len(recurrences)],
            }
            schedule, created = Schedule.objects.update_or_create(tts_text=tts_text, defaults=defaults)
            self._count_result(counters, created)

            ScheduleZoneTarget.objects.filter(schedule=schedule).delete()
            ScheduleDeviceTarget.objects.filter(schedule=schedule).delete()

            if not schedule.target_all and zones and devices:
                zone = zones[(index - 1) % len(zones)]
                device = devices[(index - 1) % len(devices)]
                _, created = ScheduleZoneTarget.objects.get_or_create(schedule=schedule, zone=zone)
                self._count_result(counters, created)
                _, created = ScheduleDeviceTarget.objects.get_or_create(schedule=schedule, device=device)
                self._count_result(counters, created)

    def _seed_device_logs(self, devices, logs_per_device, counters):
        levels = [Device.LogLevel.INFO, Device.LogLevel.WARN, Device.LogLevel.ERROR]
        for device in devices:
            for index in range(1, logs_per_device + 1):
                level = levels[(index - 1) % len(levels)]
                message = f"{MARKER} {device.name} log {index:02d}"
                _, created = DeviceLog.objects.get_or_create(device=device, message=message, level=level)
                self._count_result(counters, created)

    def _seed_ota_jobs(self, users, devices, jobs_per_device, counters):
        statuses = [OTAJob.Status.PENDING, OTAJob.Status.IN_PROGRESS, OTAJob.Status.SUCCESS, OTAJob.Status.FAILED]
        initiated_by = users[User.Role.ADMIN]
        for device in devices:
            for index in range(1, jobs_per_device + 1):
                status = statuses[(index - 1) % len(statuses)]
                ota, created = OTAJob.objects.get_or_create(device=device, initiated_by=initiated_by, status=status)
                if status in (OTAJob.Status.SUCCESS, OTAJob.Status.FAILED) and ota.completed_at is None:
                    ota.completed_at = timezone.now() - timedelta(minutes=index)
                    ota.save(update_fields=["completed_at"])
                self._count_result(counters, created)

    def _seed_triggers(self, count, counters):
        conditions = [
            Trigger.Condition.DEVICE_OFFLINE,
            Trigger.Condition.SCHEDULE_OVERRIDE,
            Trigger.Condition.MANUAL_WEBHOOK,
        ]
        for index in range(1, count + 1):
            name = f"{MARKER} trigger-{index:03d}"
            condition = conditions[(index - 1) % len(conditions)]
            defaults = {
                "description": f"{MARKER} trigger description {index:03d}",
                "enabled": index % 2 == 1,
                "condition": condition,
                "spec": {"marker": MARKER, "sequence": index, "condition": condition},
            }
            _, created = Trigger.objects.update_or_create(name=name, defaults=defaults)
            self._count_result(counters, created)

    def _reset_generated_data(self):
        deleted = {}

        deleted["broadcast_acks"] = BroadcastAck.objects.filter(broadcast__tts_text__startswith=MARKER).delete()[0]
        deleted["broadcast_zone_targets"] = BroadcastZoneTarget.objects.filter(
            broadcast__tts_text__startswith=MARKER
        ).delete()[0]
        deleted["broadcast_device_targets"] = BroadcastDeviceTarget.objects.filter(
            broadcast__tts_text__startswith=MARKER
        ).delete()[0]
        deleted["broadcasts"] = Broadcast.objects.filter(tts_text__startswith=MARKER).delete()[0]

        deleted["schedule_zone_targets"] = ScheduleZoneTarget.objects.filter(
            schedule__tts_text__startswith=MARKER
        ).delete()[0]
        deleted["schedule_device_targets"] = ScheduleDeviceTarget.objects.filter(
            schedule__tts_text__startswith=MARKER
        ).delete()[0]
        deleted["schedules"] = Schedule.objects.filter(tts_text__startswith=MARKER).delete()[0]

        deleted["device_logs"] = DeviceLog.objects.filter(message__startswith=MARKER).delete()[0]
        deleted["ota_jobs"] = OTAJob.objects.filter(device__name__startswith=DEVICE_PREFIX).delete()[0]
        deleted["triggers"] = Trigger.objects.filter(name__startswith=MARKER).delete()[0]
        deleted["user_zone_scopes"] = UserZoneScope.objects.filter(
            user__email__endswith=f"@{TEST_EMAIL_DOMAIN}"
        ).delete()[0]
        deleted["devices"] = Device.objects.filter(name__startswith=DEVICE_PREFIX).delete()[0]
        deleted["zones"] = Zone.objects.filter(name__startswith=ZONE_PREFIX).delete()[0]
        deleted["users"] = User.objects.filter(email__endswith=f"@{TEST_EMAIL_DOMAIN}").delete()[0]

        return deleted
