/// Generic in-memory key-value scratch space used across the app.
///
/// Auth state used to live here (basicAuthToken/username/deviceAccountID).
/// That was moved to [AuthManager] + [TokenSession] during the JWT
/// migration. Keep this class strictly for non-auth ephemera.
class GlobalState {
  final Map<dynamic, dynamic> _data = <dynamic, dynamic>{};

  static final GlobalState _instance = GlobalState._internal();

  static GlobalState get instance => _instance;

  GlobalState._internal();

  dynamic set(dynamic key, dynamic value) => _data[key] = value;

  dynamic get(dynamic key) => _data[key];
}

/// Global accessor (for convenience)
final globalState = GlobalState.instance;
