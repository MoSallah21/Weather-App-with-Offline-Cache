import '../../domain/entities/weather_entity.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.country,
    required super.temperatureCelsius,
    required super.temperatureFahrenheit,
    required super.condition,
    required super.conditionIconUrl,
    required super.humidity,
    required super.windSpeedKph,
    required super.windSpeedMph,
    required super.feelsLikeCelsius,
    required super.lastUpdated,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final conditionMap = current['condition'] as Map<String, dynamic>;

    String iconUrl = conditionMap['icon'] as String? ?? '';
    if (iconUrl.startsWith('//')) {
      iconUrl = 'https:$iconUrl';
    }

    return WeatherModel(
      cityName: location['name'] as String? ?? '',
      country: location['country'] as String? ?? '',
      temperatureCelsius: (current['temp_c'] as num?)?.toDouble() ?? 0.0,
      temperatureFahrenheit: (current['temp_f'] as num?)?.toDouble() ?? 0.0,
      condition: conditionMap['text'] as String? ?? '',
      conditionIconUrl: iconUrl,
      humidity: (current['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeedKph: (current['wind_kph'] as num?)?.toDouble() ?? 0.0,
      windSpeedMph: (current['wind_mph'] as num?)?.toDouble() ?? 0.0,
      feelsLikeCelsius:
      (current['feelslike_c'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'country': country,
      'temperatureCelsius': temperatureCelsius,
      'temperatureFahrenheit': temperatureFahrenheit,
      'condition': condition,
      'conditionIconUrl': conditionIconUrl,
      'humidity': humidity,
      'windSpeedKph': windSpeedKph,
      'windSpeedMph': windSpeedMph,
      'feelsLikeCelsius': feelsLikeCelsius,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory WeatherModel.fromCacheJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['cityName'] as String? ?? '',
      country: json['country'] as String? ?? '',
      temperatureCelsius:
      (json['temperatureCelsius'] as num?)?.toDouble() ?? 0.0,
      temperatureFahrenheit:
      (json['temperatureFahrenheit'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? '',
      conditionIconUrl: json['conditionIconUrl'] as String? ?? '',
      humidity: (json['humidity'] as num?)?.toDouble() ?? 0.0,
      windSpeedKph: (json['windSpeedKph'] as num?)?.toDouble() ?? 0.0,
      windSpeedMph: (json['windSpeedMph'] as num?)?.toDouble() ?? 0.0,
      feelsLikeCelsius: (json['feelsLikeCelsius'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}