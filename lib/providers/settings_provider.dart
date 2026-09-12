import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/session/session_store.dart';

class SettingsState {
  final bool darkMode;
  final String language;
  final bool notificationsEnabled;
  final bool followSystem;
  final double textScale;
  final bool highContrast;
  final bool reduceMotion;

  const SettingsState({
    this.darkMode = false,
    this.language = 'ar',
    this.notificationsEnabled = true,
    this.followSystem = false,
    this.textScale = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
  });

  SettingsState copyWith({
    bool? darkMode,
    String? language,
    bool? notificationsEnabled,
    bool? followSystem,
    double? textScale,
    bool? highContrast,
    bool? reduceMotion,
  }) {
    return SettingsState(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      followSystem: followSystem ?? this.followSystem,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _restore();
  }

  Future<void> _restore() async {
    final dark = await SettingsPersistence.loadBool(SettingsPersistence.kDark);
    final lang = await SettingsPersistence.loadString(
      SettingsPersistence.kLang,
      fallback: 'ar',
    );
    final notif = await SettingsPersistence.loadBool(
      SettingsPersistence.kNotif,
      fallback: true,
    );
    final system =
        await SettingsPersistence.loadBool(SettingsPersistence.kSystem);
    final textScale = await SettingsPersistence.loadDouble('sm.settings.textScale', fallback: 1.0);
    final highContrast = await SettingsPersistence.loadBool('sm.settings.highContrast');
    final reduceMotion = await SettingsPersistence.loadBool('sm.settings.reduceMotion');
    if (!mounted) return;
    state = state.copyWith(
      darkMode: dark,
      language: lang,
      notificationsEnabled: notif,
      followSystem: system,
      textScale: textScale,
      highContrast: highContrast,
      reduceMotion: reduceMotion,
    );
  }

  void toggleDarkMode() {
    state = state.copyWith(darkMode: !state.darkMode, followSystem: false);
    SettingsPersistence.saveBool(SettingsPersistence.kDark, state.darkMode);
    SettingsPersistence.saveBool(SettingsPersistence.kSystem, false);
  }

  void useSystemTheme() {
    state = state.copyWith(followSystem: !state.followSystem);
    SettingsPersistence.saveBool(
        SettingsPersistence.kSystem, state.followSystem);
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
    SettingsPersistence.saveString(SettingsPersistence.kLang, lang);
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    SettingsPersistence.saveBool(
      SettingsPersistence.kNotif,
      state.notificationsEnabled,
    );
  }

  void setTextScale(double scale) {
    state = state.copyWith(textScale: scale);
    SettingsPersistence.saveDouble('sm.settings.textScale', scale);
  }

  void toggleHighContrast() {
    state = state.copyWith(highContrast: !state.highContrast);
    SettingsPersistence.saveBool('sm.settings.highContrast', state.highContrast);
  }

  void toggleReduceMotion() {
    state = state.copyWith(reduceMotion: !state.reduceMotion);
    SettingsPersistence.saveBool('sm.settings.reduceMotion', state.reduceMotion);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

class CurrencyNotifier2 extends StateNotifier<String> {
  CurrencyNotifier2() : super('usd');
  void set(String code) => state = code;
}

final onboardingDoneProvider = FutureProvider<bool>((ref) async {
  return SettingsPersistence.loadBool(SettingsPersistence.kOnboarded);
});

Future<void> markOnboardingDone() =>
    SettingsPersistence.saveBool(SettingsPersistence.kOnboarded, true);
