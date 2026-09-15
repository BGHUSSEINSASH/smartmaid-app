import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/app_lock_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/platform_control_provider.dart';
import 'providers/security_provider.dart';
import 'providers/settings_provider.dart';

/// يستمع لتغييرات stream ويُخطر GoRouter بإعادة تقييم redirect.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class SmartMaidApp extends ConsumerStatefulWidget {
  const SmartMaidApp({super.key});

  @override
  ConsumerState<SmartMaidApp> createState() => _SmartMaidAppState();
}

class _SmartMaidAppState extends ConsumerState<SmartMaidApp> {
  late final _refresh = _RouterRefresh(
    ref.read(authProvider.notifier).stream,
  );

  late final routerConfig = buildRouter(
    () => ref.read(authProvider).isLoggedIn,
    currentRole: () => ref.read(authProvider).user?.role,
    refreshListenable: _refresh,
    getFlags: () => ref.read(platformFlagsProvider),
    getUser: () => ref.read(authProvider).user,
  );

  @override
  void dispose() {
    _refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'شغّالتي',
      debugShowCheckedModeBanner: false,
      routerConfig: routerConfig,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.followSystem
          ? ThemeMode.system
          : (settings.darkMode ? ThemeMode.dark : ThemeMode.light),
      locale: Locale(settings.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final security = ref.watch(securityProvider);
        final loggedIn = ref.watch(authProvider).isLoggedIn;
        final showLock = loggedIn && security.mustUnlock;
        // textScale: نقيّد بين 0.85 و 1.3 لمنع نصوص كبيرة/صغيرة جداً
        final scale = (settings.textScale).clamp(0.85, 1.3);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: showLock
              ? AppLockScreen(
                  onDone: () => ref.read(securityProvider.notifier).unlock(),
                )
              : child!,
        );
      },
    );
  }
}
