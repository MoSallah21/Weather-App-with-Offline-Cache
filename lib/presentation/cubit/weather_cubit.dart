import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/error/exceptions.dart';
import '../../domain/usecases/get_cached_weather_usecase.dart';
import '../../domain/usecases/get_recent_searches_usecase.dart';
import '../../domain/usecases/get_weather_usecase.dart';
import '../../domain/usecases/save_recent_search_usecase.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final GetWeatherUseCase getWeatherUseCase;
  final GetCachedWeatherUseCase getCachedWeatherUseCase;
  final GetRecentSearchesUseCase getRecentSearchesUseCase;
  final SaveRecentSearchUseCase saveRecentSearchUseCase;

  WeatherCubit({
    required this.getWeatherUseCase,
    required this.getCachedWeatherUseCase,
    required this.getRecentSearchesUseCase,
    required this.saveRecentSearchUseCase,
  }) : super(const WeatherInitial());

  Future<void> init() async {
    final searches = await getRecentSearchesUseCase();
    emit(WeatherInitial(recentSearches: searches));
  }

  Future<void> searchWeather(String cityName) async {
    // Prevent duplicate requests during loading
    if (state is WeatherLoading) return;

    final trimmed = cityName.trim();
    if (trimmed.isEmpty) return;

    emit(const WeatherLoading());

    try {
      final result = await getWeatherUseCase(trimmed);

      // Persist recent search only for successful live fetches
      if (!result.isFromCache) {
        await saveRecentSearchUseCase(result.weather.cityName);
      }

      final searches = await getRecentSearchesUseCase();

      emit(
        WeatherLoaded(
          weather: result.weather,
          recentSearches: searches,
          isFromCache: result.isFromCache,
        ),
      );
    } on ArgumentError {
      final searches = await getRecentSearchesUseCase();
      emit(WeatherError(
        message: 'Please enter a valid city name.',
        recentSearches: searches,
      ));
    } on CityNotFoundException catch (e) {
      final searches = await getRecentSearchesUseCase();
      emit(WeatherError(message: e.message, recentSearches: searches));
    } on NetworkException catch (e) {
      final searches = await getRecentSearchesUseCase();
      emit(WeatherError(message: e.message, recentSearches: searches));
    } on RateLimitException catch (e) {
      final searches = await getRecentSearchesUseCase();
      emit(WeatherError(message: e.message, recentSearches: searches));
    } on ServerException catch (e) {
      final searches = await getRecentSearchesUseCase();
      emit(WeatherError(message: e.message, recentSearches: searches));
    } catch (e) {
      final searches = await getRecentSearchesUseCase();
      emit(
        WeatherError(
          message: 'An unexpected error occurred. Please try again.',
          recentSearches: searches,
        ),
      );
    }
  }

  Future<void> refresh() async {
    final current = state;
    if (current is WeatherLoaded) {
      await searchWeather(current.weather.cityName);
    }
  }

  Future<void> loadCachedWeather() async {
    final cached = await getCachedWeatherUseCase();
    if (cached != null) {
      final searches = await getRecentSearchesUseCase();
      emit(
        WeatherLoaded(
          weather: cached,
          recentSearches: searches,
          isFromCache: true,
        ),
      );
    }
  }
}