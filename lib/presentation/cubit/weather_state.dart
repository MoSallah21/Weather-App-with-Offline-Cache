import 'package:equatable/equatable.dart';
import '../../domain/entities/weather_entity.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data loaded yet
class WeatherInitial extends WeatherState {
  final List<String> recentSearches;

  const WeatherInitial({this.recentSearches = const []});

  @override
  List<Object?> get props => [recentSearches];
}

/// Fetching weather from API or cache
class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

/// Successfully loaded weather data
class WeatherLoaded extends WeatherState {
  final WeatherEntity weather;
  final List<String> recentSearches;

  /// True when data came from local cache due to offline/error
  final bool isFromCache;

  const WeatherLoaded({
    required this.weather,
    required this.recentSearches,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [weather, recentSearches, isFromCache];
}

/// Error occurred with no fallback data
class WeatherError extends WeatherState {
  final String message;
  final List<String> recentSearches;

  const WeatherError({
    required this.message,
    this.recentSearches = const [],
  });

  @override
  List<Object?> get props => [message, recentSearches];
}