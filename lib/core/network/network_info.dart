import '../connectivity/connectivity_service.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final ConnectivityService connectivityService;
  NetworkInfoImpl(this.connectivityService);

  @override
  Future<bool> get isConnected => connectivityService.isConnected;
}
