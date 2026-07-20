import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plays the local bell sound on the broadcasting device as immediate
/// audio feedback when a bell broadcast is sent to a zone.
class BellService {
  final AudioPlayer _player = AudioPlayer();

  /// Plays `assets/sounds/bell.wav`.
  /// AssetSource omits the leading `assets/` prefix automatically.
  Future<void> ring() => _player.play(AssetSource('sounds/bell.wav'));

  void dispose() => _player.dispose();
}

final bellServiceProvider = Provider<BellService>((ref) {
  final svc = BellService();
  ref.onDispose(svc.dispose);
  return svc;
});
