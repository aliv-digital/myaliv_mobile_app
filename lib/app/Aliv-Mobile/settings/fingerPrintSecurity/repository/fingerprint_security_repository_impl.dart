import 'fingerprint_security_repository.dart';

class FingerPrintSecurityRepositoryImpl implements FingerPrintSecurityRepository {
  @override
  Future<FingerPrintSecurityContent> fetchContent() async {
    // Demo static (replace with API later)
    return const FingerPrintSecurityContent(
      header: 'important message',
      body:
      'biometric security combines convenience with the robust protection of passcodes. It allows users to access devices and apps quickly while maintaining strong security. This functionality alongside passcodes to provide secure, efficient authentication.\n\n'
          'by proceeding with the use of the MyALIV app and its biometric authentication features, you acknowledge and agree to the following terms. You authorize the use of biometric data (e.g., Face ID, Touch ID, or Optic ID) for device and app authentication purposes. Biometric data is securely encrypted and stored locally on your device. It will not be transmitted, shared, or stored outside your device. You are responsible for managing your device’s biometric settings and ensuring that only authorized individuals have access to your enrolled biometrics. You may disable biometric authentication at any time through your device settings. Disabling this feature will delete all associated biometric data stored on your device. While biometric technology is designed to provide secure and convenient access, no system can be entirely risk-free. By using this feature, you accept the inherent risks of biometric authentication.\n\n'
          'by continuing, you confirm your understanding and acceptance of these terms. If you do not agree, please disable biometric authentication in your device settings.',
    );
  }
}
