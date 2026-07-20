import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStreamProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final results =
      ref.watch(connectivityStreamProvider).value;
  if (results == null) return true; // assume online until proven otherwise
  return results.any((r) => r != ConnectivityResult.none);
});
