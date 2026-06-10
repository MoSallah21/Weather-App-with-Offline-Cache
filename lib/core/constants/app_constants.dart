class AppConstants {
  AppConstants._();

  static const String baseUrl = 'https://api.weatherapi.com/v1';
  static const String weatherEndpoint = '/current.json';
  static const String apiKeyParam = 'key';
  static const String queryParam = 'q';
  static const String aqi = 'no';

  static const String apiKey = '4a292f4b221640f9aed172028242805';

  // Hive
  static const String weatherBoxName        = 'weatherBox';
  static const String recentSearchesBoxName = 'recentSearchesBox';
  static const String settingsBoxName       = 'settingsBox';

  static const String cachedWeatherKey  = 'cachedWeather';
  static const String recentSearchesKey = 'recentSearches';
  static const String themeModeKey      = 'themeMode';

  // UI
  static const int    maxRecentSearches   = 10;
  static const double defaultPadding      = 16.0;
  static const double cardBorderRadius    = 16.0;
}