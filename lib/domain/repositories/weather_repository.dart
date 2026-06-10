import '../entities/weather_entity.dart';
import '../../core/error/failures.dart';

abstract class WeatherRepository {
  /// Fetches weather from remote API and caches it.
  /// Falls back to cache if offline.
  Future<({WeatherEntity weather, bool isFromCache})> getWeather(
      String cityName,
      );

  /// Returns the last cached weather data, or null if none exists.
  Future<WeatherEntity?> getCachedWeather();

  /// Returns recent search history (most recent first).
  Future<List<String>> getRecentSearches();

  /// Persists a searched city name, preventing duplicates.
  Future<void> saveRecentSearch(String cityName);
}