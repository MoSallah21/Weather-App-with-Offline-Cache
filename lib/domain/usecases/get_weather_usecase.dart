import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetWeatherUseCase {
  final WeatherRepository _repository;

  const GetWeatherUseCase(this._repository);

  Future<({WeatherEntity weather, bool isFromCache})> call(
      String cityName,
      ) async {
    final trimmed = cityName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('City name cannot be empty.');
    }
    return _repository.getWeather(trimmed);
  }
}