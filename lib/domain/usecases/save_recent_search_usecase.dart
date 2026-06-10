import '../repositories/weather_repository.dart';

class SaveRecentSearchUseCase {
  final WeatherRepository _repository;

  const SaveRecentSearchUseCase(this._repository);

  Future<void> call(String cityName) =>
      _repository.saveRecentSearch(cityName.trim());
}