import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/core/api/api_client.dart';
import 'package:aakashvani/core/config.dart';
import 'package:aakashvani/domain/models/user.dart';
import 'package:aakashvani/features/auth/data/api_auth_repository.dart';
import 'package:aakashvani/features/auth/domain/i_auth_repository.dart';
import 'package:aakashvani/mock/mock_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  if (AppConfig.useMock) {
    return MockAuthRepository();
  }
  final client = ref.watch(apiClientProvider);
  final tokenHolder = ref.watch(authTokenHolderProvider);
  return ApiAuthRepository(client, tokenHolder);
});

// User state notifier
class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  void setUser(User? user) => state = user;
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);

// Theme mode notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
