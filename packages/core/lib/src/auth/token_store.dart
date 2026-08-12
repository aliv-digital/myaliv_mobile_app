import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_session.dart';

/// Secure persistence for [TokenSession] using flutter_secure_storage.
///
/// Never use SharedPreferences for these — refresh tokens must be encrypted
/// at rest.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'auth.access_token';
  static const _kRefreshToken = 'auth.refresh_token';
  static const _kAccessExpiresAt = 'auth.access_expires_at';
  static const _kRefreshExpiresAt = 'auth.refresh_expires_at';

  Future<TokenSession?> load() async {
    final access = await _storage.read(key: _kAccessToken);
    final refresh = await _storage.read(key: _kRefreshToken);
    final accessExp = await _storage.read(key: _kAccessExpiresAt);
    final refreshExp = await _storage.read(key: _kRefreshExpiresAt);
    if (access == null ||
        refresh == null ||
        accessExp == null ||
        refreshExp == null) {
      return null;
    }
    return TokenSession.fromMap({
      'accessToken': access,
      'refreshToken': refresh,
      'accessExpiresAt': accessExp,
      'refreshExpiresAt': refreshExp,
    });
  }

  Future<void> save(TokenSession session) async {
    final map = session.toMap();
    await Future.wait([
      _storage.write(key: _kAccessToken, value: map['accessToken']),
      _storage.write(key: _kRefreshToken, value: map['refreshToken']),
      _storage.write(key: _kAccessExpiresAt, value: map['accessExpiresAt']),
      _storage.write(key: _kRefreshExpiresAt, value: map['refreshExpiresAt']),
    ]);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
      _storage.delete(key: _kAccessExpiresAt),
      _storage.delete(key: _kRefreshExpiresAt),
    ]);
  }
}
