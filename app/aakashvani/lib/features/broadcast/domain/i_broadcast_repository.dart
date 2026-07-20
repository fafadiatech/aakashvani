import 'package:aakashvani/domain/models/audio_clip.dart';
import 'package:aakashvani/domain/models/broadcast.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/domain/models/voice.dart';
import 'package:aakashvani/domain/models/zone.dart';

abstract interface class IBroadcastRepository {
  Future<List<Zone>> getZones();
  Future<List<AudioClip>> getClips();
  Future<List<Voice>> getVoices();
  Future<Broadcast> sendBroadcast(BroadcastSpec spec, User sender);
  Future<Broadcast> ringBell(String zoneId, User sender);
  Future<void> stopBroadcast(String id);
  Future<List<Broadcast>> getBroadcasts();
  Stream<Broadcast> streamBroadcast(String id);
}
