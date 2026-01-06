abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // For simplicity, always return true
    // In production, use connectivity_plus package
    return true;
  }
}
