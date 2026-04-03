import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefKey = 'app_theme_mode';

final initialThemeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.light);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.watch(initialThemeModeProvider);
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _persistState();
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _persistState();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefKey, state.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

Future<ThemeMode> loadPersistedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final stored = prefs.getString(_themeModePrefKey);
  if (stored == null || stored.isEmpty) {
    return ThemeMode.light;
  }
  return ThemeMode.values.firstWhere(
    (mode) => mode.name == stored,
    orElse: () => ThemeMode.light,
  );
}
