import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the user's login credentials (API-formatted phone + password)
/// in encrypted secure storage so the biometric login flow can replay them
/// without the user re-typing.
///
/// Credentials are written after every successful login API call and wiped
/// on hard-logout. The biometric auth gate itself is handled separately by
/// [FingerFaceSecurityCubit] — this class only stores/retrieves the payload.
class CredentialStore {
  CredentialStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const _kApiPhone = 'auth.login_api_phone';
  static const _kPassword = 'auth.login_password';

  Future<void> save({
    required String apiPhone,
    required String password,
  }) async {
    await Future.wait([
      _storage.write(key: _kApiPhone, value: apiPhone),
      _storage.write(key: _kPassword, value: password),
    ]);
  }

  Future<({String apiPhone, String password})?> load() async {
    final results = await Future.wait([
      _storage.read(key: _kApiPhone),
      _storage.read(key: _kPassword),
    ]);
    final apiPhone = results[0];
    final password = results[1];
    if (apiPhone == null || password == null) return null;
    return (apiPhone: apiPhone, password: password);
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kApiPhone),
      _storage.delete(key: _kPassword),
    ]);
  }
}
