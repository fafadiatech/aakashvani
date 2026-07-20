# Aakashvani — Django Backend Plan

## Overview

Aakashvani is a smart speaker control and broadcasting system. The Django backend serves:

- **REST API** (versioned under `/api/v1/`) consumed by the Flutter mobile app
- **WebSocket server** for real-time broadcast acknowledgements and device status
- **Admin portal** (Django admin) for ops/super-admin use
- **Media storage** for uploaded/recorded audio clips

---

## Project Structure

The backend uses a two-app layout:

- **`apps/core/`** — pure infrastructure: base model mixins, permission classes, pagination, exception types, WebSocket base consumer, Celery task base. No business logic lives here.
- **`apps/aakashvani/`** — all domain models, serializers, views, tasks, consumers, and URL routing. Internal files are split by domain into sub-packages to keep files manageable.

```
aakashvani_backend/
├── manage.py
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   ├── asgi.py
│   └── wsgi.py
├── apps/
│   ├── core/                        # Shared infrastructure (no business logic)
│   │   ├── models.py                # UUIDModel, TimestampedModel (abstract mixins)
│   │   ├── permissions.py           # IsAdmin, IsBroadcaster, IsViewer, IsAdminOrBroadcaster
│   │   ├── pagination.py            # AppCursorPagination (page_size=25, ordering=-created_at)
│   │   ├── serializers.py           # TimestampedSerializer base (auto read_only id/timestamps)
│   │   ├── exceptions.py            # AakashvaniError, DeviceOfflineError, BroadcastDispatchError, QuietHoursActiveError
│   │   ├── consumers.py             # AuthenticatedJsonConsumer base (token auth on connect)
│   │   ├── tasks.py                 # AppTask Celery base (autoretry + structured logging)
│   │   ├── filters.py               # Shared filter backends
│   │   └── apps.py                  # AppConfig: name = "apps.core"
│   └── aakashvani/                  # All business logic
│       ├── apps.py                  # AppConfig: name = "apps.aakashvani"
│       ├── admin.py                 # Django admin registrations
│       ├── models/
│       │   ├── __init__.py          # re-exports all models
│       │   ├── accounts.py          # User, UserZoneScope
│       │   ├── zones.py             # Zone
│       │   ├── devices.py           # Device, DeviceLog, OtaJob
│       │   ├── broadcasts.py        # Broadcast, BroadcastZoneTarget, BroadcastDeviceTarget, BroadcastAck
│       │   ├── schedules.py         # Schedule, ScheduleZoneTarget, ScheduleDeviceTarget
│       │   ├── library.py           # AudioClip, Voice
│       │   ├── settings_config.py   # AppSettings
│       │   └── integrations.py      # Trigger
│       ├── serializers/
│       │   ├── __init__.py
│       │   ├── accounts.py
│       │   ├── zones.py
│       │   ├── devices.py
│       │   ├── broadcasts.py
│       │   ├── schedules.py
│       │   ├── library.py
│       │   ├── settings_config.py
│       │   └── integrations.py
│       ├── views/
│       │   ├── __init__.py
│       │   ├── accounts.py          # LoginView, LogoutView, MeView, UserViewSet
│       │   ├── zones.py             # ZoneViewSet
│       │   ├── devices.py           # DeviceViewSet (ota/, heartbeat/, logs/ actions)
│       │   ├── broadcasts.py        # BroadcastViewSet (stop/, ring-bell/ actions)
│       │   ├── schedules.py         # ScheduleViewSet
│       │   ├── library.py           # AudioClipViewSet, VoiceListView
│       │   ├── settings_config.py   # AppSettingsView
│       │   └── integrations.py      # TriggerViewSet (fire/ action)
│       ├── consumers/
│       │   ├── __init__.py
│       │   ├── devices.py           # DeviceStatusConsumer
│       │   └── broadcasts.py        # BroadcastConsumer
│       ├── tasks/
│       │   ├── __init__.py
│       │   ├── broadcasts.py        # dispatch_broadcast, send_tts, send_clip
│       │   ├── schedules.py         # fire_schedule (Celery Beat)
│       │   ├── devices.py           # dispatch_ota_job
│       │   └── integrations.py      # execute_trigger
│       └── urls.py                  # Single router wiring all ViewSets
└── requirements/
    ├── base.txt
    ├── development.txt
    └── production.txt
```

---

## `apps/core/` Reference

### `models.py` — Abstract Base Models

```python
class UUIDModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    class Meta:
        abstract = True

class TimestampedModel(UUIDModel):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    class Meta:
        abstract = True
```

All domain models inherit from `TimestampedModel` (or `UUIDModel` where `updated_at` is not needed, e.g. `DeviceLog`, `BroadcastAck`).

### `permissions.py` — DRF Permission Classes

`IsAdmin`, `IsBroadcaster`, `IsViewer` backed by `request.user.role`. `IsAdminOrBroadcaster` combines them. All ViewSets import from here.

### `pagination.py` — Cursor Pagination

`AppCursorPagination` sets `page_size = 25`, `ordering = "-created_at"`. Set as `DEFAULT_PAGINATION_CLASS` in DRF settings.

### `serializers.py` — Base Serializer

`TimestampedSerializer(serializers.ModelSerializer)` marks `id`, `created_at`, `updated_at` as `read_only`. All domain serializers inherit from this.

### `exceptions.py` — Exception Hierarchy

```python
class AakashvaniError(Exception): ...
class DeviceOfflineError(AakashvaniError): ...
class BroadcastDispatchError(AakashvaniError): ...
class QuietHoursActiveError(AakashvaniError): ...
```

A single DRF `EXCEPTION_HANDLER` in `config/settings/base.py` maps these to structured JSON error responses.

### `consumers.py` — WebSocket Base

`AuthenticatedJsonConsumer(JsonWebsocketConsumer)` handles token auth in `websocket_connect`, disconnects unauthenticated clients, sets `self.user`. Domain consumers extend this.

### `tasks.py` — Celery Task Base

`AppTask(celery.Task)` with `autoretry_for = (Exception,)`, `max_retries = 3`, structured logging. Domain tasks bind to this via `@app.task(base=AppTask)`.

### Dependency Rule

`apps.core` never imports from `apps.aakashvani`. The domain app imports freely from `apps.core`.

---

## INSTALLED_APPS

```python
# config/settings/base.py
INSTALLED_APPS = [
    # Django built-ins ...
    "rest_framework",
    "channels",
    "knox",
    "django_filters",
    "drf_spectacular",

    # Project apps
    "apps.core",
    "apps.aakashvani",
]
```

---

## Domain Models

### Accounts — `models/accounts.py`

```python
class User(AbstractBaseUser, PermissionsMixin):
    # inherits id from UUIDModel
    email     = EmailField(unique=True)
    name      = CharField(max_length=150)
    role      = CharField(choices=["admin", "broadcaster", "viewer"])
    is_active = BooleanField(default=True)
    created_at = DateTimeField(auto_now_add=True)
    updated_at = DateTimeField(auto_now=True)

class UserZoneScope(Model):
    """M2M through-table: which zones a broadcaster/viewer is scoped to."""
    user = ForeignKey(User)
    zone = ForeignKey("Zone")
    class Meta:
        unique_together = ("user", "zone")
```

**Auth**: Token-based (Knox). Login returns a bearer token.

---

### Zones — `models/zones.py`

```python
class Zone(TimestampedModel):
    name           = CharField(max_length=100, unique=True)
    default_volume = IntegerField(default=80)   # 0–100
```

---

### Devices — `models/devices.py`

```python
class Device(TimestampedModel):
    name             = CharField(max_length=100)
    zone             = ForeignKey("Zone", on_delete=SET_NULL, null=True)
    model            = CharField(max_length=50)
    firmware_version = CharField(max_length=30, blank=True)
    volume           = IntegerField(default=80)
    is_online        = BooleanField(default=False)
    is_playing       = BooleanField(default=False)
    last_seen        = DateTimeField(null=True, blank=True)

class DeviceLog(UUIDModel):
    device    = ForeignKey(Device, on_delete=CASCADE, related_name="logs")
    message   = TextField()
    level     = CharField(choices=["info", "warn", "error"], default="info")
    logged_at = DateTimeField(auto_now_add=True)

class OtaJob(UUIDModel):
    device        = ForeignKey(Device, on_delete=CASCADE)
    initiated_by  = ForeignKey("User", on_delete=SET_NULL, null=True)
    status        = CharField(choices=["pending", "in_progress", "success", "failed"])
    initiated_at  = DateTimeField(auto_now_add=True)
    completed_at  = DateTimeField(null=True, blank=True)
```

---

### Broadcasts — `models/broadcasts.py`

```python
class Broadcast(TimestampedModel):
    created_by   = ForeignKey("User", on_delete=SET_NULL, null=True)
    state        = CharField(choices=["pending", "playing", "done", "stopped"])
    priority     = CharField(choices=["normal", "urgent", "emergency"], default="normal")
    source_type  = CharField(choices=["tts", "clip"])
    tts_text     = TextField(blank=True)
    tts_voice_id = CharField(max_length=50, blank=True)
    clip         = ForeignKey("AudioClip", null=True, blank=True, on_delete=SET_NULL)
    chime_id     = CharField(max_length=50, blank=True)
    target_all   = BooleanField(default=False)

class BroadcastZoneTarget(Model):
    broadcast = ForeignKey(Broadcast, on_delete=CASCADE, related_name="zone_targets")
    zone      = ForeignKey("Zone", on_delete=CASCADE)

class BroadcastDeviceTarget(Model):
    broadcast = ForeignKey(Broadcast, on_delete=CASCADE, related_name="device_targets")
    device    = ForeignKey("Device", on_delete=CASCADE)

class BroadcastAck(UUIDModel):
    broadcast       = ForeignKey(Broadcast, on_delete=CASCADE, related_name="acks")
    device          = ForeignKey("Device", on_delete=CASCADE)
    status          = CharField(choices=["pending", "played", "failed", "offline"])
    acknowledged_at = DateTimeField(null=True, blank=True)
    class Meta:
        unique_together = ("broadcast", "device")
```

---

### Schedules — `models/schedules.py`

```python
class Schedule(TimestampedModel):
    created_by   = ForeignKey("User", on_delete=SET_NULL, null=True)
    enabled      = BooleanField(default=True)
    source_type  = CharField(choices=["tts", "clip"])
    tts_text     = TextField(blank=True)
    tts_voice_id = CharField(max_length=50, blank=True)
    clip         = ForeignKey("AudioClip", null=True, blank=True, on_delete=SET_NULL)
    priority     = CharField(choices=["normal", "urgent", "emergency"], default="normal")
    target_all   = BooleanField(default=False)
    chime_id     = CharField(max_length=50, blank=True)
    run_at       = DateTimeField()
    recurrence   = CharField(choices=["none", "daily", "weekdays", "weekly", "monthly"])

class ScheduleZoneTarget(Model):
    schedule = ForeignKey(Schedule, on_delete=CASCADE, related_name="zone_targets")
    zone     = ForeignKey("Zone", on_delete=CASCADE)

class ScheduleDeviceTarget(Model):
    schedule = ForeignKey(Schedule, on_delete=CASCADE, related_name="device_targets")
    device   = ForeignKey("Device", on_delete=CASCADE)
```

**Task runner**: Celery + Celery Beat via `tasks/schedules.py` → `fire_schedule`.

---

### Library — `models/library.py`

```python
class AudioClip(UUIDModel):
    title       = CharField(max_length=200)
    category    = CharField(max_length=100, blank=True)
    duration_ms = IntegerField()
    source      = CharField(choices=["uploaded", "recorded", "tts"])
    file        = FileField(upload_to="clips/")
    uploaded_by = ForeignKey("User", on_delete=SET_NULL, null=True)
    created_at  = DateTimeField(auto_now_add=True)

class Voice(Model):
    """Supported TTS voices — seeded via fixture."""
    id            = CharField(max_length=50, primary_key=True)  # e.g. "en-IN-F"
    label         = CharField(max_length=100)
    language_code = CharField(max_length=10)
```

---

### Settings — `models/settings_config.py`

```python
class AppSettings(Model):
    """Singleton-style: always a single row (id=1)."""
    quiet_hours_enabled = BooleanField(default=False)
    quiet_start_time    = TimeField(null=True, blank=True)
    quiet_end_time      = TimeField(null=True, blank=True)
    default_priority    = CharField(choices=["normal", "urgent", "emergency"], default="normal")
    default_voice_id    = CharField(max_length=50, blank=True)
    updated_at          = DateTimeField(auto_now=True)
```

---

### Integrations — `models/integrations.py`

```python
class Trigger(TimestampedModel):
    name        = CharField(max_length=100)
    description = TextField(blank=True)
    enabled     = BooleanField(default=True)
    condition   = CharField(choices=["device_offline", "schedule_override", "manual_webhook"])
    spec        = JSONField()   # broadcast spec snapshot
```

---

## API Design

All REST endpoints are versioned under `/api/v1/`. Authentication: `Authorization: Bearer <token>` required on all endpoints except `/auth/login/`.

### `config/urls.py`

```python
from django.urls import path, include

urlpatterns = [
    path("api/v1/", include(("apps.aakashvani.urls", "v1"))),
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
]
```

### `apps/aakashvani/urls.py`

```python
router = DefaultRouter()
router.register("zones",        ZoneViewSet)
router.register("devices",      DeviceViewSet)
router.register("broadcasts",   BroadcastViewSet)
router.register("schedules",    ScheduleViewSet)
router.register("library/clips",AudioClipViewSet)
router.register("admin/users",  UserViewSet)
router.register("integrations/triggers", TriggerViewSet)

urlpatterns = router.urls + [
    path("auth/login/",          LoginView.as_view()),
    path("auth/logout/",         LogoutView.as_view()),
    path("auth/me/",             MeView.as_view()),
    path("library/voices/",      VoiceListView.as_view()),
    path("admin/settings/",      AppSettingsView.as_view()),
    path("admin/health/",        SystemHealthView.as_view()),
]
```

---

### Auth — `/api/v1/auth/`

| Method | Endpoint        | Description                     | Roles  |
|--------|-----------------|---------------------------------|--------|
| POST   | `/auth/login/`  | Email + password → token + user | Public |
| POST   | `/auth/logout/` | Invalidate current token        | All    |
| GET    | `/auth/me/`     | Current user profile            | All    |

**POST `/auth/login/`** Request:
```json
{ "email": "admin@aakashvani.in", "password": "admin123" }
```
Response:
```json
{
  "token": "abc123…",
  "user": { "id": "…", "name": "Admin", "role": "admin", "zone_scope": [] }
}
```

---

### Zones — `/api/v1/zones/`

| Method | Endpoint       | Description    | Roles |
|--------|----------------|----------------|-------|
| GET    | `/zones/`      | List zones     | All   |
| POST   | `/zones/`      | Create zone    | Admin |
| GET    | `/zones/{id}/` | Zone detail    | All   |
| PATCH  | `/zones/{id}/` | Update zone    | Admin |
| DELETE | `/zones/{id}/` | Delete zone    | Admin |

---

### Devices — `/api/v1/devices/`

| Method | Endpoint                  | Description               | Roles |
|--------|---------------------------|---------------------------|-------|
| GET    | `/devices/`               | List devices              | Admin |
| POST   | `/devices/`               | Register device           | Admin |
| GET    | `/devices/{id}/`          | Device detail             | Admin |
| PATCH  | `/devices/{id}/`          | Update name/zone/volume   | Admin |
| DELETE | `/devices/{id}/`          | Remove device             | Admin |
| POST   | `/devices/{id}/ota/`      | Trigger OTA firmware push | Admin |
| GET    | `/devices/{id}/logs/`     | Fetch device logs         | Admin |
| POST   | `/devices/{id}/heartbeat/`| Firmware heartbeat        | Device|

---

### Broadcasts — `/api/v1/broadcasts/`

| Method | Endpoint                    | Description                   | Roles              |
|--------|-----------------------------|-------------------------------|--------------------|
| GET    | `/broadcasts/`              | List broadcasts (paginated)   | Admin, Broadcaster |
| POST   | `/broadcasts/`              | Send new broadcast            | Admin, Broadcaster |
| GET    | `/broadcasts/{id}/`         | Broadcast detail + acks       | Admin, Broadcaster |
| POST   | `/broadcasts/{id}/stop/`    | Stop in-progress broadcast    | Admin, Broadcaster |
| POST   | `/broadcasts/ring-bell/`    | Quick bell ring to a zone     | Admin, Broadcaster |

**POST `/broadcasts/`** Request:
```json
{
  "source_type": "tts",
  "tts_text": "Attention please...",
  "tts_voice_id": "hi-IN-F",
  "priority": "urgent",
  "target_all": false,
  "zone_targets": ["zone-uuid-1"],
  "device_targets": [],
  "chime_id": "chime-1"
}
```

---

### Schedules — `/api/v1/schedules/`

| Method | Endpoint            | Description      | Roles              |
|--------|---------------------|------------------|--------------------|
| GET    | `/schedules/`       | List schedules   | Admin, Broadcaster |
| POST   | `/schedules/`       | Create schedule  | Admin, Broadcaster |
| GET    | `/schedules/{id}/`  | Schedule detail  | Admin, Broadcaster |
| PATCH  | `/schedules/{id}/`  | Update schedule  | Admin, Broadcaster |
| DELETE | `/schedules/{id}/`  | Delete schedule  | Admin, Broadcaster |

**POST `/schedules/`** Request:
```json
{
  "source_type": "clip",
  "clip_id": "clip-uuid",
  "priority": "normal",
  "target_all": true,
  "zone_targets": [],
  "device_targets": [],
  "run_at": "2026-07-20T08:00:00Z",
  "recurrence": "weekdays"
}
```

---

### Library — `/api/v1/library/`

| Method | Endpoint               | Description              | Roles              |
|--------|------------------------|--------------------------|--------------------|
| GET    | `/library/clips/`      | List clips (searchable)  | Admin, Broadcaster |
| POST   | `/library/clips/`      | Upload clip (multipart)  | Admin, Broadcaster |
| GET    | `/library/clips/{id}/` | Clip detail + URL        | Admin, Broadcaster |
| DELETE | `/library/clips/{id}/` | Delete clip              | Admin, Broadcaster |
| GET    | `/library/voices/`     | List TTS voices          | Admin, Broadcaster |

**GET `/library/clips/`** supports query params: `?search=bell&category=alert`

---

### Admin — `/api/v1/admin/`

#### Users

| Method | Endpoint             | Description       | Roles |
|--------|----------------------|-------------------|-------|
| GET    | `/admin/users/`      | List users        | Admin |
| POST   | `/admin/users/`      | Create user       | Admin |
| GET    | `/admin/users/{id}/` | User detail       | Admin |
| PATCH  | `/admin/users/{id}/` | Update role/scope | Admin |
| DELETE | `/admin/users/{id}/` | Deactivate user   | Admin |

#### App Settings

| Method | Endpoint           | Description          | Roles |
|--------|--------------------|----------------------|-------|
| GET    | `/admin/settings/` | Get app settings     | Admin |
| PUT    | `/admin/settings/` | Replace app settings | Admin |

#### System Health

| Method | Endpoint         | Description                 | Roles |
|--------|------------------|-----------------------------|-------|
| GET    | `/admin/health/` | Device connectivity summary | Admin |

---

### Integrations — `/api/v1/integrations/`

| Method | Endpoint                             | Description    | Roles |
|--------|--------------------------------------|----------------|-------|
| GET    | `/integrations/triggers/`            | List triggers  | Admin |
| PATCH  | `/integrations/triggers/{id}/`       | Toggle enabled | Admin |
| POST   | `/integrations/triggers/{id}/fire/`  | Manually fire  | Admin |

---

## WebSocket API

Endpoint: `ws://<host>/ws/v1/`

Authentication: token as query param on connect:
```
ws://<host>/ws/v1/?token=<bearer_token>
```

Handled by `core.consumers.AuthenticatedJsonConsumer`. Domain consumers (`consumers/devices.py`, `consumers/broadcasts.py`) extend this base.

### `config/asgi.py` Routing

```python
application = ProtocolTypeRouter({
    "websocket": AuthMiddlewareStack(URLRouter([
        path("ws/v1/", include("apps.aakashvani.consumers")),
    ])),
})
```

### Server → Client Events

**Device status update:**
```json
{
  "type": "device_status",
  "device_id": "uuid",
  "online": true,
  "playing": false,
  "volume": 80,
  "last_seen": "2026-07-19T10:30:00Z"
}
```

**Broadcast acknowledgement:**
```json
{
  "type": "broadcast_ack",
  "broadcast_id": "uuid",
  "device_id": "uuid",
  "status": "played",
  "acknowledged_at": "2026-07-19T10:30:05Z"
}
```

**Broadcast state change:**
```json
{
  "type": "broadcast_state",
  "broadcast_id": "uuid",
  "state": "done"
}
```

**Alert:**
```json
{
  "type": "alert",
  "alert_type": "device_offline",
  "device_id": "uuid"
}
```

### Client → Server Events

```json
{ "type": "subscribe_broadcast", "broadcast_id": "uuid" }
```

---

## Tech Stack

| Concern          | Technology                                   |
|------------------|----------------------------------------------|
| Web framework    | Django 5.x + Django REST Framework           |
| API versioning   | URL namespace (`/api/v1/`, `/api/v2/`)       |
| Auth             | django-knox (multi-device token auth)        |
| WebSockets       | Django Channels + Redis channel layer        |
| Async tasks      | Celery + Celery Beat (schedule dispatch)     |
| Message broker   | Redis                                        |
| Database         | PostgreSQL                                   |
| Media storage    | Local (dev) → S3-compatible (prod)           |
| API docs         | drf-spectacular (OpenAPI 3 / Swagger UI)     |
| Permissions      | `apps.core.permissions` — custom DRF classes |
| Migrations       | Django's built-in migration framework        |

---

## Permissions Matrix

| Resource           | Admin | Broadcaster | Viewer |
|--------------------|-------|-------------|--------|
| Auth (login/me)    | ✓     | ✓           | ✓      |
| Zones (read)       | ✓     | ✓           | ✓      |
| Zones (write)      | ✓     | —           | —      |
| Devices (read)     | ✓     | —           | —      |
| Devices (write)    | ✓     | —           | —      |
| Broadcasts (read)  | ✓     | ✓           | —      |
| Broadcasts (write) | ✓     | ✓           | —      |
| Schedules (read)   | ✓     | ✓           | ✓      |
| Schedules (write)  | ✓     | ✓           | —      |
| Library (read)     | ✓     | ✓           | —      |
| Library (write)    | ✓     | ✓           | —      |
| Admin users        | ✓     | —           | —      |
| Admin settings     | ✓     | —           | —      |
| Integrations       | ✓     | —           | —      |

---

## Pagination & Filtering

All list endpoints use cursor pagination:

```json
{
  "count": 42,
  "next": "/api/v1/broadcasts/?cursor=abc",
  "previous": null,
  "results": [...]
}
```

Filtering via `django-filter` on relevant fields (e.g. broadcast `state`, clip `category`).

---

## API Versioning Strategy

- **URL-based versioning**: `/api/v1/` prefix on all endpoints
- New version (`/api/v2/`) introduced only for breaking changes
- Both versions can coexist; old version sunset after a deprecation window
- Version communicated back to client in `X-API-Version` response header

---

## Deployment Notes

- Django Channels requires ASGI server — use **Daphne** or **Uvicorn**
- Redis required for both Channels layer and Celery broker
- Celery Beat process manages recurring schedule dispatch (`tasks/schedules.py`)
- Device heartbeat endpoint called by ESP32/ESP8266 firmware: `POST /api/v1/devices/{id}/heartbeat/` — updates `is_online`, `last_seen`, `firmware_version`
