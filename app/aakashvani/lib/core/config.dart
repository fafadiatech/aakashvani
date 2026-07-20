import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Compile-time configuration via `--dart-define`.
abstract final class AppConfig {
  static const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: true);

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  /// Resolves [apiBaseUrl] for the current platform.
  ///
  /// On the Android emulator, `127.0.0.1` / `localhost` point at the emulator
  /// itself — rewrite to `10.0.2.2` (host loopback) so the default URL works.
  static String get resolvedApiBaseUrl {
    if (kIsWeb || !Platform.isAndroid) return apiBaseUrl;
    final uri = Uri.tryParse(apiBaseUrl);
    if (uri == null) return apiBaseUrl;
    if (uri.host != '127.0.0.1' && uri.host != 'localhost') return apiBaseUrl;
    return uri.replace(host: '10.0.2.2').toString();
  }
}
