import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.localeCode, this.textScale = 1.0});
  final ThemeMode themeMode;
  final String? localeCode;
  final double textScale;
  AppSettings copyWith({ThemeMode? themeMode, String? localeCode, bool clearLocale = false, double? textScale}) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    localeCode: clearLocale ? null : (localeCode ?? this.localeCode),
    textScale: textScale ?? this.textScale,
  );
}
final appSettingsProvider = StateNotifierProvider<AppSettingsController, AppSettings>((ref) => AppSettingsController());
class AppSettingsController extends StateNotifier<AppSettings> {
  AppSettingsController() : super(const AppSettings()) { _ready = _load(); }
  static const _themeKey = 'settings.themeMode', _localeKey = 'settings.localeCode', _scaleKey = 'settings.textScale';
  late final Future<void> _ready;
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance(); final name = p.getString(_themeKey); final locale = p.getString(_localeKey); final scale = p.getDouble(_scaleKey);
    state = AppSettings(themeMode: ThemeMode.values.firstWhere((m) => m.name == name, orElse: () => ThemeMode.system), localeCode: locale == 'en' || locale == 'ar' ? locale : null, textScale: scale == null ? 1 : scale.clamp(.85, 1.3).toDouble());
  }
  Future<void> setThemeMode(ThemeMode v) async { await _ready; state = state.copyWith(themeMode: v); await (await SharedPreferences.getInstance()).setString(_themeKey, v.name); }
  Future<void> setLocale(String? v) async { await _ready; state = v == null ? state.copyWith(clearLocale: true) : state.copyWith(localeCode: v); final p = await SharedPreferences.getInstance(); if (v == null) { await p.remove(_localeKey); } else { await p.setString(_localeKey, v); } }
  Future<void> setTextScale(double v) async { await _ready; final n = v.clamp(.85, 1.3).toDouble(); state = state.copyWith(textScale: n); await (await SharedPreferences.getInstance()).setDouble(_scaleKey, n); }
  Future<void> reset() async { await _ready; state = const AppSettings(); final p = await SharedPreferences.getInstance(); await p.remove(_themeKey); await p.remove(_localeKey); await p.remove(_scaleKey); }
}
