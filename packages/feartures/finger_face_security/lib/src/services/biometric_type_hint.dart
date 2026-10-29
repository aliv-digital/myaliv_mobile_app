/// Hint for which biometric modality to prefer when calling [BiometricAuthService.authenticateWithBiometrics].
///
/// iOS always honors the single enrolled biometric regardless of this hint. On
/// Android, [face] and [fingerprint] route through a platform channel that
/// filters by `BiometricPrompt` authenticator class (`BIOMETRIC_WEAK` vs
/// `BIOMETRIC_STRONG`). Use [any] to show the system prompt that accepts any
/// enrolled biometric.
enum BiometricTypeHint { any, face, fingerprint }
