import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String cityName;
  final String country;
  final double temperatureCelsius;
  final double temperatureFahrenheit;
  final String condition;
  final String conditionIconUrl;
  final double humidity;
  final double windSpeedKph;
  final double windSpeedMph;
  final double feelsLikeCelsius;
  final DateTime lastUpdated;

  const WeatherEntity({
    required this.cityName,
    required this.country,
    required this.temperatureCelsius,
    required this.temperatureFahrenheit,
    required this.condition,
    required this.conditionIconUrl,
    required this.humidity,
    required this.windSpeedKph,
    required this.windSpeedMph,
    required this.feelsLikeCelsius,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    cityName,
    country,
    temperatureCelsius,
    temperatureFahrenheit,
    condition,
    conditionIconUrl,
    humidity,
    windSpeedKph,
    windSpeedMph,
    feelsLikeCelsius,
    lastUpdated,
  ];
}