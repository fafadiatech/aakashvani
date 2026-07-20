from django.core.management.base import BaseCommand

from apps.aakashvani.models import AppSettings, User, Voice

DEV_USERS = [
    {
        "email": "admin@aakashvani.in",
        "name": "Admin",
        "password": "admin123",
        "role": User.Role.ADMIN,
        "is_staff": True,
        "is_superuser": True,
    },
    {
        "email": "broadcaster@aakashvani.in",
        "name": "Broadcaster",
        "password": "broadcaster123",
        "role": User.Role.BROADCASTER,
        "is_staff": False,
        "is_superuser": False,
    },
    {
        "email": "viewer@aakashvani.in",
        "name": "Viewer",
        "password": "viewer123",
        "role": User.Role.VIEWER,
        "is_staff": False,
        "is_superuser": False,
    },
]


class Command(BaseCommand):
    help = "Seed baseline development data."

    def handle(self, *args, **options):
        AppSettings.objects.get_or_create(id=1)

        voices = [
            ("en-IN-F", "English India Female", "en-IN"),
            ("hi-IN-F", "Hindi India Female", "hi-IN"),
            ("en-IN-M", "English India Male", "en-IN"),
        ]
        for voice_id, label, language_code in voices:
            Voice.objects.get_or_create(id=voice_id, defaults={"label": label, "language_code": language_code})

        for user_data in DEV_USERS:
            if User.objects.filter(email=user_data["email"]).exists():
                continue
            data = {**user_data}
            password = data.pop("password")
            User.objects.create_user(password=password, **data)

        self.stdout.write(self.style.SUCCESS("Seed data loaded."))
