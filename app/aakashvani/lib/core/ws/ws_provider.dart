import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/domain/models/device.dart';
import 'package:aakashvani/domain/models/ws_event.dart';
import 'package:aakashvani/mock/mock_ws_stream.dart';
import 'package:aakashvani/mock/seed_data.dart';

final wsEventProvider = StreamProvider<WsEvent>((ref) {
  final ws = MockWsStream();
  ws.start();
  ref.onDispose(ws.stop);
  return ws.stream.map(
    (raw) => WsEvent.tryParse(raw) ?? const UnknownEvent(raw: ''),
  );
});

// ── Live device states ─────────────────────────────────────────────────────

class DeviceStatesNotifier extends Notifier<List<Device>> {
  @override
  List<Device> build() {
    // Start with seed devices, then apply WS updates
    ref.listen(wsEventProvider, (_, next) {
      next.whenData((event) {
        if (event is DeviceStatusEvent) _applyStatusEvent(event);
      });
    });
    return List.from(seedDevices);
  }

  void _applyStatusEvent(DeviceStatusEvent e) {
    state = [
      for (final d in state)
        if (d.id == e.deviceId)
          Device(
            id: d.id,
            name: d.name,
            zoneId: d.zoneId,
            online: e.online,
            playing: e.playing,
            volume: e.volume,
            lastSeen: e.lastSeen,
            firmwareVersion: d.firmwareVersion,
            model: d.model,
          )
        else
          d,
    ];
  }
}

final deviceStatesProvider =
    NotifierProvider<DeviceStatesNotifier, List<Device>>(
  DeviceStatesNotifier.new,
);
