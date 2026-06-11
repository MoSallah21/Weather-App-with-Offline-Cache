import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../data/datasources/weather_local_datasource.dart';
import '../../../../data/datasources/weather_remote_datasource.dart';
import '../../../../data/repositories/weather_repository_impl.dart';
import '../../../../domain/repositories/weather_repository.dart';
import '../../../../domain/usecases/get_cached_weather_usecase.dart';
import '../../../../domain/usecases/get_recent_searches_usecase.dart';
import '../../../../domain/usecases/get_weather_usecase.dart';
import '../../../../domain/usecases/save_recent_search_usecase.dart';
import '../../../../presentation/cubit/weather_cubit.dart';
import '../../presentation/cubit/theme_cubit.dart';
import '../constants/app_constants.dart';
import '../network/connectivity_service.dart';
import '../network/network_client.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // External
  sl.registerLazySingleton<NetworkClient>(() => NetworkClient());
  sl.registerLazySingleton<Dio>(() => sl<NetworkClient>().dio);

  // Services
  sl.registerLazySingleton<ConnectivityService>(
        () => ConnectivityServiceImpl(),
  );

  // Hive Boxes
  sl.registerLazySingleton<Box>(
        () => Hive.box(AppConstants.weatherBoxName),
    instanceName: AppConstants.weatherBoxName,
  );
  sl.registerLazySingleton<Box>(
        () => Hive.box(AppConstants.recentSearchesBoxName),
    instanceName: AppConstants.recentSearchesBoxName,
  );
  sl.registerLazySingleton<Box>(
        () => Hive.box(AppConstants.settingsBoxName),
    instanceName: AppConstants.settingsBoxName,
  );
  // Data Sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
        () => WeatherRemoteDataSourceImpl(sl<NetworkClient>()),
  );
  sl.registerLazySingleton<WeatherLocalDataSource>(
        () => WeatherLocalDataSourceImpl(
      weatherBox: sl<Box>(instanceName: AppConstants.weatherBoxName),
      recentSearchesBox:
      sl<Box>(instanceName: AppConstants.recentSearchesBoxName),
    ),
  );



  // Repository
  sl.registerLazySingleton<WeatherRepository>(
        () => WeatherRepositoryImpl(
      remoteDataSource: sl<WeatherRemoteDataSource>(),
      localDataSource: sl<WeatherLocalDataSource>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetWeatherUseCase(sl<WeatherRepository>()));
  sl.registerLazySingleton(
          () => GetCachedWeatherUseCase(sl<WeatherRepository>()));
  sl.registerLazySingleton(
          () => GetRecentSearchesUseCase(sl<WeatherRepository>()));
  sl.registerLazySingleton(
          () => SaveRecentSearchUseCase(sl<WeatherRepository>()));

  // Cubit
  sl.registerFactory(
        () => WeatherCubit(
      getWeatherUseCase: sl<GetWeatherUseCase>(),
      getCachedWeatherUseCase: sl<GetCachedWeatherUseCase>(),
      getRecentSearchesUseCase: sl<GetRecentSearchesUseCase>(),
      saveRecentSearchUseCase: sl<SaveRecentSearchUseCase>(),
    ),
  );
  // ThemeCubit
  sl.registerLazySingleton<ThemeCubit>(
        () => ThemeCubit(sl<Box>(instanceName: AppConstants.settingsBoxName)),
  );
}