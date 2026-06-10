import 'package:flutter/material.dart';

/// Maps a WeatherAPI condition text to a Material icon and a gradient pair.
class WeatherConditionStyle {
  const WeatherConditionStyle({
    required this.icon,
    required this.gradientColors,
    required this.emoji,
  });

  final IconData icon;
  final List<Color> gradientColors;
  final String emoji;

  static WeatherConditionStyle fromCondition(String condition) {
    final lower = condition.toLowerCase();

    if (_contains(lower, ['thunder', 'lightning', 'storm'])) {
      return const WeatherConditionStyle(
        icon: Icons.thunderstorm_rounded,
        gradientColors: [Color(0xFF37474F), Color(0xFF546E7A)],
        emoji: '⛈️',
      );
    }
    if (_contains(lower, ['snow', 'blizzard', 'sleet', 'ice'])) {
      return const WeatherConditionStyle(
        icon: Icons.ac_unit_rounded,
        gradientColors: [Color(0xFF90CAF9), Color(0xFFBBDEFB)],
        emoji: '❄️',
      );
    }
    if (_contains(lower, ['heavy rain', 'torrential', 'downpour'])) {
      return const WeatherConditionStyle(
        icon: Icons.water_rounded,
        gradientColors: [Color(0xFF1565C0), Color(0xFF1976D2)],
        emoji: '🌧️',
      );
    }
    if (_contains(lower, ['rain', 'drizzle', 'shower'])) {
      return const WeatherConditionStyle(
        icon: Icons.grain_rounded,
        gradientColors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        emoji: '🌦️',
      );
    }
    if (_contains(lower, ['fog', 'mist', 'haze', 'smoke', 'dust'])) {
      return const WeatherConditionStyle(
        icon: Icons.foggy,
        gradientColors: [Color(0xFF78909C), Color(0xFF90A4AE)],
        emoji: '🌫️',
      );
    }
    if (_contains(lower, ['overcast', 'cloudy'])) {
      return const WeatherConditionStyle(
        icon: Icons.cloud_rounded,
        gradientColors: [Color(0xFF607D8B), Color(0xFF78909C)],
        emoji: '☁️',
      );
    }
    if (_contains(lower, ['partly cloudy', 'partial'])) {
      return WeatherConditionStyle(
        icon: Icons.cloud,
        gradientColors: const [Color(0xFF1E88E5), Color(0xFF64B5F6)],
        emoji: '⛅',
      );
    }
    if (_contains(lower, ['sunny', 'clear'])) {
      return const WeatherConditionStyle(
        icon: Icons.wb_sunny_rounded,
        gradientColors: [Color(0xFFF57F17), Color(0xFFFFB300)],
        emoji: '☀️',
      );
    }
    // Default — generic sky
    return const WeatherConditionStyle(
      icon: Icons.wb_cloudy_rounded,
      gradientColors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      emoji: '🌤️',
    );
  }

  static bool _contains(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));
}