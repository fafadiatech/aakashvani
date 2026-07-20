import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/models/zone.dart';
import 'package:aakashvani/domain/role.dart';

// The clip used for Bell Mode — the Opening Chime (3 s)
const kBellClipId = 'clip-1';

final seedUsers = [
  const User(
    id: 'user-admin',
    name: 'Admin User',
    role: Role.admin,
    zoneScope: [],
    token: 'mock-token-admin',
  ),
  const User(
    id: 'user-broadcaster',
    name: 'Broadcaster Bob',
    role: Role.broadcaster,
    zoneScope: ['zone-1', 'zone-2'],
    token: 'mock-token-broadcaster',
  ),
  const User(
    id: 'user-viewer',
    name: 'Viewer Victor',
    role: Role.viewer,
    zoneScope: [],
    token: 'mock-token-viewer',
  ),
];

/// Mock credentials: email → (password, userId)
/// Demo accounts:
///   admin@aakashvani.in / admin123
///   broadcaster@aakashvani.in / cast123
///   viewer@aakashvani.in / view123
const mockCredentials = <String, (String password, String userId)>{
  'admin@aakashvani.in': ('admin123', 'user-admin'),
  'broadcaster@aakashvani.in': ('cast123', 'user-broadcaster'),
  'viewer@aakashvani.in': ('view123', 'user-viewer'),
};

final seedZones = [
  const Zone(id: 'zone-1', name: 'Main Hall', deviceIds: ['dev-1', 'dev-2'], defaultVolume: 70),
  const Zone(id: 'zone-2', name: 'Cafeteria', deviceIds: ['dev-3', 'dev-4'], defaultVolume: 65),
  const Zone(id: 'zone-3', name: 'Lobby', deviceIds: ['dev-5', 'dev-6'], defaultVolume: 60),
];

final seedDevices = [
  Device(id: 'dev-1', name: 'Hall Speaker 1', zoneId: 'zone-1', online: true, playing: false, volume: 70, lastSeen: DateTime.now(), firmwareVersion: '1.2.0', model: 'esp32'),
  Device(id: 'dev-2', name: 'Hall Speaker 2', zoneId: 'zone-1', online: true, playing: false, volume: 70, lastSeen: DateTime.now(), firmwareVersion: '1.2.0', model: 'esp32'),
  Device(id: 'dev-3', name: 'Cafe Speaker 1', zoneId: 'zone-2', online: true, playing: false, volume: 65, lastSeen: DateTime.now(), firmwareVersion: '1.1.5', model: 'esp8266'),
  Device(id: 'dev-4', name: 'Cafe Speaker 2', zoneId: 'zone-2', online: false, playing: false, volume: 65, lastSeen: DateTime.now().subtract(const Duration(hours: 2)), firmwareVersion: '1.1.5', model: 'esp8266'),
  Device(id: 'dev-5', name: 'Lobby Speaker 1', zoneId: 'zone-3', online: true, playing: false, volume: 60, lastSeen: DateTime.now(), firmwareVersion: '1.2.0', model: 'esp32'),
  Device(id: 'dev-6', name: 'Lobby Speaker 2', zoneId: 'zone-3', online: false, playing: false, volume: 60, lastSeen: DateTime.now().subtract(const Duration(minutes: 30)), firmwareVersion: '1.2.0', model: 'esp32'),
];

final seedClips = [
  const AudioClip(id: 'clip-1', title: 'Opening Chime', category: 'chimes', durationMs: 3000, source: ClipSource.uploaded, url: 'mock://clips/chime_open.mp3'),
  const AudioClip(id: 'clip-2', title: 'Closing Chime', category: 'chimes', durationMs: 2800, source: ClipSource.uploaded, url: 'mock://clips/chime_close.mp3'),
  const AudioClip(id: 'clip-3', title: 'Lunch Announcement', category: 'announcements', durationMs: 8000, source: ClipSource.recorded, url: 'mock://clips/lunch.mp3'),
  const AudioClip(id: 'clip-4', title: 'Meeting Reminder', category: 'announcements', durationMs: 6500, source: ClipSource.tts, url: 'mock://clips/meeting.mp3'),
  const AudioClip(id: 'clip-5', title: 'Welcome Message', category: 'greetings', durationMs: 5000, source: ClipSource.tts, url: 'mock://clips/welcome.mp3'),
  const AudioClip(id: 'clip-6', title: 'Good Morning', category: 'greetings', durationMs: 3500, source: ClipSource.tts, url: 'mock://clips/goodmorning.mp3'),
  const AudioClip(id: 'clip-7', title: 'Fire Drill Alert', category: 'alerts', durationMs: 4200, source: ClipSource.uploaded, url: 'mock://clips/fire_drill.mp3'),
  const AudioClip(id: 'clip-8', title: 'Building Closed', category: 'alerts', durationMs: 5500, source: ClipSource.recorded, url: 'mock://clips/closed.mp3'),
];
