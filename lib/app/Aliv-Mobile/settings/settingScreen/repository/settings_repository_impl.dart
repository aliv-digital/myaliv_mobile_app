import 'package:shared_preferences/shared_preferences.dart';
import 'settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _kFingerprint = 'settings_fingerprint_enabled';
  static const _kFaceScan = 'settings_face_scan_enabled';

  @override
  Future<bool> getFingerprintEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kFingerprint) ?? false;
  }

  @override
  Future<bool> getFaceScanEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kFaceScan) ?? false;
  }

  @override
  Future<void> setFingerprintEnabled(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kFingerprint, value);
  }

  @override
  Future<void> setFaceScanEnabled(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kFaceScan, value);
  }
}
