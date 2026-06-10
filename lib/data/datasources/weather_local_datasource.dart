import 'dart:convert';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/weather_model.dart';

abstract class WeatherLocalDataSource {
  Future<WeatherModel?> getCachedWeather();
  Future<WeatherModel?> getCachedWeatherForCity(String cityName);
  Future<void> cacheWeather(WeatherModel weather);
  Future<List<String>> getRecentSearches();
  Future<void> saveRecentSearch(String cityName);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final Box weatherBox;
  final Box recentSearchesBox;

  const WeatherLocalDataSourceImpl({
    required this.weatherBox,
    required this.recentSearchesBox,
  });

  @override
  Future<WeatherModel?> getCachedWeather() async {
    try {
      final jsonString =
      weatherBox.get(AppConstants.cachedWeatherKey) as String?;
      if (jsonString == null) return null;
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return WeatherModel.fromCacheJson(jsonMap);
    } catch (_) {
      return null;
    }
  }


  @override
  Future<List<String>> getRecentSearches() async {
    try {
      final stored =
      recentSearchesBox.get(AppConstants.recentSearchesKey) as String?;
      if (stored == null) return [];
      final decoded = json.decode(stored);
      if (decoded is List) {
        return decoded.cast<String>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveRecentSearch(String cityName) async {
    try {
      final current = await getRecentSearches();
      final normalised = cityName.trim();
      final updated = [
        normalised,
        ...current.where(
              (c) => c.toLowerCase() != normalised.toLowerCase(),
        ),
      ].take(AppConstants.maxRecentSearches).toList();

      final jsonString = json.encode(updated);
      await recentSearchesBox.put(AppConstants.recentSearchesKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to save recent search: $e');
    }
  }

  @override
  Future<WeatherModel?> getCachedWeatherForCity(String cityName) async {
    try {
      final key = 'weather_${cityName.toLowerCase().trim()}';
      final jsonString = weatherBox.get(key) as String?;
      if (jsonString == null) return null;
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return WeatherModel.fromCacheJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    try {
      final jsonString = json.encode(weather.toJson());
      final cityKey = 'weather_${weather.cityName.toLowerCase().trim()}';
      await weatherBox.put(cityKey, jsonString);
      await weatherBox.put(AppConstants.cachedWeatherKey, jsonString);
    } catch (e) {
      throw CacheException('Failed to cache weather data: $e');
    }
  }
}