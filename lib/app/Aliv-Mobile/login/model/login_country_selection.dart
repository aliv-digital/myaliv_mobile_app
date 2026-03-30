import 'package:equatable/equatable.dart';

/// Minimal country data needed by the login flow.
///
/// The login screen only needs the ISO code, the dial code rendered beside the
/// input, and the flag emoji shown in the picker box.
class LoginCountrySelection extends Equatable {
  static const LoginCountrySelection defaultBahamas = LoginCountrySelection(
    isoCode: 'BS',
    dialCode: '242',
    flagEmoji: '🇧🇸',
  );

  final String isoCode;
  final String dialCode;
  final String flagEmoji;

  const LoginCountrySelection({
    required this.isoCode,
    required this.dialCode,
    required this.flagEmoji,
  });

  @override
  List<Object?> get props => [isoCode, dialCode, flagEmoji];
}
