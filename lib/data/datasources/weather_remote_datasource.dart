import '../../core/error/exceptions.dart';
import '../../core/network/network_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/weather_model.dart';
import 'package:dio/dio.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeather(String cityName);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final NetworkClient _networkClient;

  const WeatherRemoteDataSourceImpl(this._networkClient);

  @override
  Future<WeatherModel> getWeather(String cityName) async {
    try {
      final response = await _networkClient.dio.get(
        AppConstants.weatherEndpoint,
        queryParameters: {
          AppConstants.apiKeyParam: AppConstants.apiKey,
          AppConstants.queryParam: cityName,
          'aqi': AppConstants.aqi,
        },
      );
      return WeatherModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final error = e.error;
      if (error is AppException) throw error;
      throw const ServerException('An unexpected error occurred.');
    }
  }
}