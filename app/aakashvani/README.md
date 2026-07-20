# Aakashvani — Smart Speaker Companion

A Flutter mobile app that controls a network of smart speakers. Send audio announcements to networked speaker endpoints — instantly, from a library, or on a schedule — and monitor what played where.

---

## Running the app

### With mock backend (default — no hardware needed)

```bash
flutter run --dart-define=USE_MOCK=true
```

Or simply:

```bash
flutter run
```

`USE_MOCK` defaults to `true` in debug builds.

### With real backend

```bash
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

On the **Android emulator**, `127.0.0.1` is rewritten to `10.0.2.2` automatically.
If that still fails, pass `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1` explicitly,
and ensure the Django server is listening (`runserver 0.0.0.0:8000` if needed).

Optional WebSocket URL (not used for bell delivery yet):

```bash
flutter run \
  --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1 \
  --dart-define=WS_URL=ws://127.0.0.1:8000/ws
```

---

## Build milestones

| Milestone | Status | Description |
|---|---|---|
| **M1** | ✅ Done | Foundation: folder structure, theme, i18n, role-aware navigation shell, mock backend |
| M2 | — | Broadcast flow: composer, target selector, live delivery status via WebSocket |
| M3 | — | Schedule: list/calendar view, schedule editor with recurrence |
| M4 | — | Library: browser, clip detail, in-app record & upload |
| M5 | — | Activity & Status: feed, viewer status board, alerts, deep-linked notifications |
| M6 | — | Admin: devices, zones, users, integrations, settings, health dashboard |
| M7 | — | Offline-first: drift cache + outbox queue, sync on reconnect |

---

## Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Navigation | `go_router` (StatefulShellRoute) |
| HTTP | `dio` |
| Realtime | `web_socket_channel` |
| i18n | `intl` / `flutter_localizations` (en, hi, mr) |

---

## Roles

Log in as any role from the login screen to see the correct tabs:

| Role | Tabs |
|---|---|
| **Administrator** | Broadcast · Devices · Activity · Admin |
| **Broadcaster** | Broadcast · Schedule · Library · Activity |
| **Viewer** | Status · Schedule · History |

---

## Project structure

```
lib/
  app/           # Router, theme, localization
  core/          # Result types, error hierarchy
  domain/        # Models, Role enum, Permissions
  features/      # Feature modules (auth, broadcast, schedule, …)
  mock/          # Mock backend: seed data + simulated WS stream
```
