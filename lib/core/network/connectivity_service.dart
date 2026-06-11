import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class ConnectivityService {
  Future<bool> get isConnected;
}

class ConnectivityServiceImpl implements ConnectivityService {
  @override
  Future<bool> get isConnected async {
    return await InternetConnection().hasInternetAccess;
  }
}