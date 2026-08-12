/// Immutable JWT session: access + refresh tokens and their absolute expiry
/// instants.
///
/// Persist absolute instants (not TTL durations) so app restarts compute
/// expiry correctly regardless of how long the app was backgrounded.
class TokenSession {
  const TokenSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessExpiresAt;
  final DateTime refreshExpiresAt;

  /// 30 s clock skew — refresh proactively a bit before the server thinks
  /// the token has expired.
  static const Duration _skew = Duration(seconds: 30);

  bool get accessExpired =>
      DateTime.now().isAfter(accessExpiresAt.subtract(_skew));

  bool get refreshExpired => DateTime.now().isAfter(refreshExpiresAt);

  /// Build a session from the auth API's response shape:
  /// `{ access_token, refresh_token, expires_in, refresh_expires_in }`
  /// where the two `_in` fields are seconds.
  ///
  /// Throws [FormatException] when any required field is missing or a TTL
  /// is non-positive. A zero-TTL session would round-trip the refresh
  /// endpoint forever, so treat malformed responses as a hard parse
  /// failure and let the caller decide (usually: hard logout).
  factory TokenSession.fromLoginJson(Map<String, dynamic> json) {
    final access = json['access_token'];
    final refresh = json['refresh_token'];
    if (access is! String || access.isEmpty) {
      throw const FormatException('access_token missing or not a string');
    }
    if (refresh is! String || refresh.isEmpty) {
      throw const FormatException('refresh_token missing or not a string');
    }
    final accessTtl = _readSeconds(json, 'expires_in');
    final refreshTtl = _readSeconds(json, 'refresh_expires_in');
    if (accessTtl <= 0 || refreshTtl <= 0) {
      throw const FormatException(
          'expires_in / refresh_expires_in must be positive');
    }
    final now = DateTime.now();
    return TokenSession(
      accessToken: access,
      refreshToken: refresh,
      accessExpiresAt: now.add(Duration(seconds: accessTtl)),
      refreshExpiresAt: now.add(Duration(seconds: refreshTtl)),
    );
  }

  Map<String, String> toMap() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'accessExpiresAt': accessExpiresAt.toIso8601String(),
        'refreshExpiresAt': refreshExpiresAt.toIso8601String(),
      };

  factory TokenSession.fromMap(Map<String, String> map) => TokenSession(
        accessToken: map['accessToken']!,
        refreshToken: map['refreshToken']!,
        accessExpiresAt: DateTime.parse(map['accessExpiresAt']!),
        refreshExpiresAt: DateTime.parse(map['refreshExpiresAt']!),
      );

  static int _readSeconds(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
