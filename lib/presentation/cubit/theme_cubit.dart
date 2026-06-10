import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final Box _box;

  ThemeCubit(this._box) : super(_load(_box));

  static ThemeMode _load(Box box) {
    final saved = box.get(AppConstants.themeModeKey) as String?;
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark'  => ThemeMode.dark,
      _       => ThemeMode.system,
    };
  }

  Future<void> setTheme(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light  => 'light',
      ThemeMode.dark   => 'dark',
      ThemeMode.system => 'system',
    };
    await _box.put(AppConstants.themeModeKey, value);
    emit(mode);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }
}