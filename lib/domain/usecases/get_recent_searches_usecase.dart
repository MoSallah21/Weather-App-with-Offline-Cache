import '../repositories/weather_repository.dart';

class GetRecentSearchesUseCase {
  final WeatherRepository _repository;

  const GetRecentSearchesUseCase(this._repository);

  Future<List<String>> call() => _repository.getRecentSearches();
}