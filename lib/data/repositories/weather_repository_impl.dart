import '../../core/error/exceptions.dart';
import '../../core/network/connectivity_service.dart';
import '../../data/datasources/weather_local_datasource.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/models/weather_model.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  const WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<({WeatherEntity weather, bool isFromCache})> getWeather(
      String cityName,
      ) async {
    final hasConnection = await connectivityService.isConnected;

    if (!hasConnection) {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) {
        return (weather: cached, isFromCache: true);
      }
      throw const NetworkException(
        'No internet connection and no cached data available.',
      );
    }

    try {
      final model = await remoteDataSource.getWeather(cityName);
      await localDataSource.cacheWeather(model);
      return (weather: model, isFromCache: false);
    } on NetworkException {
      final cached = await localDataSource.getCachedWeather();
      if (cached != null) {
        return (weather: cached, isFromCache: true);
      }
      rethrow;
    } on CityNotFoundException {
      rethrow;
    } on RateLimitException {
      rethrow;
    } on ServerException {
      rethrow;
    } on CacheException {
      rethrow;
    }
  }

  @override
  Future<WeatherEntity?> getCachedWeather() async {
    return localDataSource.getCachedWeather();
  }

  @override
  Future<List<String>> getRecentSearches() async {
    return localDataSource.getRecentSearches();
  }

  @override
  Future<void> saveRecentSearch(String cityName) async {
    await localDataSource.saveRecentSearch(cityName);
  }
}