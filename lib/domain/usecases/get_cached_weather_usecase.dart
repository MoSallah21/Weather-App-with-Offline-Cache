import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetCachedWeatherUseCase {
  final WeatherRepository _repository;

  const GetCachedWeatherUseCase(this._repository);

  Future<WeatherEntity?> call() => _repository.getCachedWeather();
}