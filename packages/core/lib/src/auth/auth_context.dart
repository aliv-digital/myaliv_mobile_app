import 'dart:convert';

/// Immutable authentication context that holds all credentials and pre-computed tokens
///
/// This class serves as the single source of truth for authentication state in the app.
/// It stores credentials in memory and provides pre-computed auth tokens to avoid
/// repeated encoding operations.
class AuthContext {
  final String username;
  final String password; // ticket from login
  final String deviceAccountID;
  final String basicAuthToken; // Pre-computed: Base64(username:password)
  final DateTime timestamp;

  const AuthContext({
    required this.username,
    required this.password,
    required this.deviceAccountID,
    required this.basicAuthToken,
    required this.timestamp,
  });

  /// Factory: Build from raw credentials
  ///
  /// This is the primary way to create an AuthContext. It automatically
  /// computes the Basic Auth token from username and password.
  factory AuthContext.fromCredentials({
    required String username,
    required String password,
    required String deviceAccountID,
  }) {
    final credentials = '$username:$password';
    final basicAuthToken = base64Encode(utf8.encode(credentials));

    return AuthContext(
      username: username,
      password: password,
      deviceAccountID: deviceAccountID,
      basicAuthToken: basicAuthToken,
      timestamp: DateTime.now(),
    );
  }

  /// Factory: Build from SharedPreferences data
  ///
  /// Used when loading stored credentials at app startup.
  factory AuthContext.fromStorage({
    required String username,
    required String ticket,
    required int accountId,
  }) {
    return AuthContext.fromCredentials(
      username: username,
      password: ticket,
      deviceAccountID: accountId.toString(),
    );
  }

  /// Check if this context represents a valid authenticated state
  bool get isAuthenticated =>
      username.isNotEmpty &&
      password.isNotEmpty &&
      deviceAccountID.isNotEmpty;

  /// Check if the auth context has expired
  ///
  /// TODO: Implement proper expiration logic based on ticket TTL from backend
  /// For now, considers valid for 24 hours
  bool get isExpired {
    return DateTime.now().difference(timestamp).inHours > 24;
  }

  /// Create a copy with updated fields
  AuthContext copyWith({
    String? username,
    String? password,
    String? deviceAccountID,
  }) {
    return AuthContext.fromCredentials(
      username: username ?? this.username,
      password: password ?? this.password,
      deviceAccountID: deviceAccountID ?? this.deviceAccountID,
    );
  }

  /// Serialize for GlobalState storage
  Map<String, dynamic> toMap() => {
        'username': username,
        'password': password,
        'deviceAccountID': deviceAccountID,
        'basicAuthToken': basicAuthToken,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Deserialize from GlobalState storage
  factory AuthContext.fromMap(Map<String, dynamic> map) {
    return AuthContext(
      username: map['username'] as String,
      password: map['password'] as String,
      deviceAccountID: map['deviceAccountID'] as String,
      basicAuthToken: map['basicAuthToken'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'AuthContext(username: $username, deviceAccountID: $deviceAccountID, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthContext &&
        other.username == username &&
        other.password == password &&
        other.deviceAccountID == deviceAccountID &&
        other.basicAuthToken == basicAuthToken &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return username.hashCode ^
        password.hashCode ^
        deviceAccountID.hashCode ^
        basicAuthToken.hashCode ^
        timestamp.hashCode;
  }
}
