abstract class SettingsRepository {
  Future<bool> getFingerprintEnabled();
  Future<bool> getFaceScanEnabled();

  Future<void> setFingerprintEnabled(bool value);
  Future<void> setFaceScanEnabled(bool value);
}
