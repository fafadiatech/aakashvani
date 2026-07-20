import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aakashvani/app/l10n/app_localizations.dart';
import 'package:aakashvani/app/router/app_router.dart';
import 'package:aakashvani/app/theme/app_theme.dart';
import 'package:aakashvani/core/notifications/notification_service.dart';
import 'package:aakashvani/core/offline/outbox_sync_service.dart';
import 'package:aakashvani/features/auth/presentation/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const ProviderScope(child: AakashvaniApp()));
}

class AakashvaniApp extends ConsumerWidget {
  const AakashvaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep outbox sync service alive for the lifetime of the app
    ref.read(outboxSyncProvider);

    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Wire deep-link notification taps to the router
    NotificationService.instance.onNotificationTap = (route) {
      router.push(route);
    };

    return MaterialApp.router(
      title: 'Aakashvani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
