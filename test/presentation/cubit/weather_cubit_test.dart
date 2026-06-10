import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather/core/error/exceptions.dart';
import 'package:weather/domain/entities/weather_entity.dart';
import 'package:weather/domain/usecases/get_cached_weather_usecase.dart';
import 'package:weather/domain/usecases/get_recent_searches_usecase.dart';
import 'package:weather/domain/usecases/get_weather_usecase.dart';
import 'package:weather/domain/usecases/save_recent_search_usecase.dart';
import 'package:weather/presentation/cubit/weather_cubit.dart';
import 'package:weather/presentation/cubit/weather_state.dart';


// ── Mocks ────────────────────────────────────────────────────────────────────

class MockGetWeatherUseCase extends Mock implements GetWeatherUseCase {}
class MockGetCachedWeatherUseCase extends Mock implements GetCachedWeatherUseCase {}
class MockGetRecentSearchesUseCase extends Mock implements GetRecentSearchesUseCase {}
class MockSaveRecentSearchUseCase extends Mock implements SaveRecentSearchUseCase {}

// ── Fixtures ─────────────────────────────────────────────────────────────────

final _tWeather = WeatherEntity(
  cityName: 'Dubai',
  country: 'AE',
  temperatureCelsius: 38.0,
  temperatureFahrenheit: 100.4,
  condition: 'Sunny',
  conditionIconUrl: 'https://example.com/icon.png',
  humidity: 60,
  windSpeedKph: 15,
  windSpeedMph: 9.3,
  feelsLikeCelsius: 42,
  lastUpdated: DateTime(2024, 1, 1, 12),
);

const _tSearches = ['Dubai', 'London'];

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  late MockGetWeatherUseCase mockGetWeather;
  late MockGetCachedWeatherUseCase mockGetCached;
  late MockGetRecentSearchesUseCase mockGetRecent;
  late MockSaveRecentSearchUseCase mockSaveRecent;

  setUp(() {
    mockGetWeather = MockGetWeatherUseCase();
    mockGetCached = MockGetCachedWeatherUseCase();
    mockGetRecent = MockGetRecentSearchesUseCase();
    mockSaveRecent = MockSaveRecentSearchUseCase();
  });

  WeatherCubit _cubit() => WeatherCubit(
    getWeatherUseCase: mockGetWeather,
    getCachedWeatherUseCase: mockGetCached,
    getRecentSearchesUseCase: mockGetRecent,
    saveRecentSearchUseCase: mockSaveRecent,
  );

  // ── init ───────────────────────────────────────────────────────────────────

  group('init', () {
    blocTest<WeatherCubit, WeatherState>(
      'emits WeatherInitial with recent searches',
      build: () {
        when(() => mockGetRecent()).thenAnswer((_) async => _tSearches);
        return _cubit();
      },
      act: (c) => c.init(),
      expect: () => [WeatherInitial(recentSearches: _tSearches)],
    );
  });

  // ── searchWeather ──────────────────────────────────────────────────────────

  group('searchWeather', () {
    blocTest<WeatherCubit, WeatherState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockGetWeather(any())).thenAnswer(
              (_) async => (weather: _tWeather, isFromCache: false)
          ,
        );
        when(() => mockSaveRecent(any())).thenAnswer((_) async {});
        when(() => mockGetRecent()).thenAnswer((_) async => _tSearches);
        return _cubit();
      },
      act: (c) => c.searchWeather('Dubai'),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(
          weather: _tWeather,
          recentSearches: _tSearches,
          isFromCache: false,
        ),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits [Loading, Loaded(isFromCache:true)] when result is from cache',
      build: () {
        when(() => mockGetWeather(any())).thenAnswer(
              (_) async => (weather: _tWeather, isFromCache: false)
          ,
        );
        when(() => mockGetRecent()).thenAnswer((_) async => _tSearches);
        return _cubit();
      },
      act: (c) => c.searchWeather('Dubai'),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(
          weather: _tWeather,
          recentSearches: _tSearches,
          isFromCache: true,
        ),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits [Loading, Error] on CityNotFoundException',
      build: () {
        when(() => mockGetWeather(any()))
            .thenThrow(const CityNotFoundException('City not found.'));
        when(() => mockGetRecent()).thenAnswer((_) async => _tSearches);
        return _cubit();
      },
      act: (c) => c.searchWeather('Atlantis'),
      expect: () => [
        const WeatherLoading(),
        WeatherError(
          message: 'City not found.',
          recentSearches: _tSearches,
        ),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'emits [Loading, Error] on NetworkException',
      build: () {
        when(() => mockGetWeather(any())).thenThrow(
          const NetworkException('No internet connection.'),
        );
        when(() => mockGetRecent()).thenAnswer((_) async => _tSearches);
        return _cubit();
      },
      act: (c) => c.searchWeather('Dubai'),
      expect: () => [
        const WeatherLoading(),
        WeatherError(
          message: 'No internet connection.',
          recentSearches: _tSearches,
        ),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'does nothing for empty city name',
      build: () => _cubit(),
      act: (c) => c.searchWeather('   '),
      expect: () => [],
    );

    blocTest<WeatherCubit, WeatherState>(
      'does not start second request while loading',
      build: () {
        when(() => mockGetWeather(any())).thenAnswer(
              (_) async {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return (weather: _tWeather, isFromCache: false)
            ;
          },
        );
        when(() => mockSaveRecent(any())).thenAnswer((_) async {});
        when(() => mockGetRecent()).thenAnswer((_) async => []);
        return _cubit();
      },
      act: (c) async {
        // fire two requests quickly — second should be ignored
        unawaited(c.searchWeather('Dubai'));
        await c.searchWeather('London');
      },
      verify: (_) {
        // getWeather called only once
        verify(() => mockGetWeather(any())).called(1);
      },
    );
  });

  // ── refresh ────────────────────────────────────────────────────────────────

  group('refresh', () {
    blocTest<WeatherCubit, WeatherState>(
      're-searches with same city when state is WeatherLoaded',
      build: () {
        when(() => mockGetWeather(any())).thenAnswer(
              (_) async =>(weather: _tWeather, isFromCache: false)
          ,
        );
        when(() => mockSaveRecent(any())).thenAnswer((_) async {});
        when(() => mockGetRecent()).thenAnswer((_) async => _tSearches);
        return _cubit()
          ..emit(WeatherLoaded(
            weather: _tWeather,
            recentSearches: _tSearches,
          ));
      },
      act: (c) => c.refresh(),
      expect: () => [
        const WeatherLoading(),
        WeatherLoaded(
          weather: _tWeather,
          recentSearches: _tSearches,
          isFromCache: false,
        ),
      ],
    );

    blocTest<WeatherCubit, WeatherState>(
      'does nothing when state is not WeatherLoaded',
      build: () => _cubit(),
      act: (c) => c.refresh(),
      expect: () => [],
    );
  });
}