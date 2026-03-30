import 'package:country_picker/country_picker.dart';
import 'package:phone_numbers_parser/metadata.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../model/login_country_selection.dart';

class LoginPhoneValidationResult {
  final bool isValid;
  final String? phoneNumberForApi;
  final String? errorMessage;

  const LoginPhoneValidationResult._({
    required this.isValid,
    this.phoneNumberForApi,
    this.errorMessage,
  });

  const LoginPhoneValidationResult.success({
    required String phoneNumberForApi,
  }) : this._(isValid: true, phoneNumberForApi: phoneNumberForApi);

  const LoginPhoneValidationResult.failure({required String errorMessage})
      : this._(isValid: false, errorMessage: errorMessage);
}

class LoginPhoneNumberHelper {
  const LoginPhoneNumberHelper();

  static const String invalidPhoneNumberMessage = 'invalid phone number';
  static const Map<String, String> _territoryDialCodeOverrides = <String, String>{
    // Bahamas is a NANP territory. The picker package can surface the shared
    // parent code `1`, but this login flow must keep the territory code `242`.
    'BS': '242',
  };

  /// country_picker returns composite codes such as `1-242` for Bahamas.
  ///
  /// The login UX wants the territory-specific code shown to the user, so we
  /// keep the last numeric segment instead of the shared parent code.
  LoginCountrySelection selectionFromCountry(Country country) {
    final String isoCode = country.countryCode.toUpperCase();

    return LoginCountrySelection(
      isoCode: isoCode,
      dialCode: _territoryDialCodeOverrides[isoCode] ??
          _normalizeDisplayDialCode(country.phoneCode),
      flagEmoji: country.flagEmoji,
    );
  }

  LoginPhoneValidationResult validateAndBuildApiUsername({
    required String rawPhoneNumber,
    required LoginCountrySelection selectedCountry,
  }) {
    final String enteredDigits = _digitsOnly(rawPhoneNumber);
    if (enteredDigits.isEmpty) {
      return const LoginPhoneValidationResult.failure(
        errorMessage: invalidPhoneNumberMessage,
      );
    }

    final IsoCode? isoCode = _tryParseIsoCode(selectedCountry.isoCode);
    if (isoCode == null) {
      return const LoginPhoneValidationResult.failure(
        errorMessage: invalidPhoneNumberMessage,
      );
    }

    try {
      final PhoneNumber parsedPhone = PhoneNumber.parse(
        enteredDigits,
        destinationCountry: isoCode,
      );

      if (!parsedPhone.isValid()) {
        return const LoginPhoneValidationResult.failure(
          errorMessage: invalidPhoneNumberMessage,
        );
      }

      final metadata = metadataByIsoCode[isoCode];
      final bool matchesExpectedLocalInput = _matchesExpectedLocalInput(
        enteredDigits: enteredDigits,
        parsedPhone: parsedPhone,
        displayDialCode: selectedCountry.dialCode,
        nationalPrefix: metadata?.nationalPrefix,
      );

      if (!matchesExpectedLocalInput) {
        return const LoginPhoneValidationResult.failure(
          errorMessage: invalidPhoneNumberMessage,
        );
      }

      return LoginPhoneValidationResult.success(
        phoneNumberForApi: _buildApiUsername(
          parsedPhone: parsedPhone,
          displayDialCode: selectedCountry.dialCode,
        ),
      );
    } catch (_) {
      return const LoginPhoneValidationResult.failure(
        errorMessage: invalidPhoneNumberMessage,
      );
    }
  }

  String _normalizeDisplayDialCode(String rawPhoneCode) {
    final List<String> phoneCodeSegments = rawPhoneCode
        .replaceAll('-', ' ')
        .split(' ')
        .map((String segment) => segment.trim())
        .where((String segment) => segment.isNotEmpty)
        .toList();

    if (phoneCodeSegments.isEmpty) {
      return '1';
    }

    return phoneCodeSegments.last;
  }

  String _digitsOnly(String value) {
    final StringBuffer digitsOnlyBuffer = StringBuffer();

    for (int index = 0; index < value.length; index++) {
      final String character = value[index];
      final int codeUnit = character.codeUnitAt(0);
      final bool isDigit = codeUnit >= 48 && codeUnit <= 57;

      if (isDigit) {
        digitsOnlyBuffer.write(character);
      }
    }

    return digitsOnlyBuffer.toString();
  }

  IsoCode? _tryParseIsoCode(String rawIsoCode) {
    try {
      return IsoCode.values.byName(rawIsoCode.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  /// Validates the text field value as a local number for the selected country.
  ///
  /// The picker already displays the country code, so the text field should
  /// contain only the local part of the number:
  /// - Bangladesh keeps the local trunk prefix `0`, which makes the local input
  ///   one digit longer than the parsed NSN.
  /// - Bahamas uses `242` in the picker, while libphonenumber internally keeps
  ///   the shared `+1` country code. In that case the text field should contain
  ///   only the subscriber part after `242`.
  bool _matchesExpectedLocalInput({
    required String enteredDigits,
    required PhoneNumber parsedPhone,
    required String displayDialCode,
    required String? nationalPrefix,
  }) {
    final bool usesTerritoryDialCode =
        displayDialCode != parsedPhone.countryCode &&
            parsedPhone.nsn.startsWith(displayDialCode);

    if (usesTerritoryDialCode) {
      final int subscriberLength =
          parsedPhone.nsn.length - displayDialCode.length;
      return enteredDigits.length == subscriberLength;
    }

    if (nationalPrefix == '0') {
      return enteredDigits.length == parsedPhone.nsn.length + 1 &&
          enteredDigits.startsWith('0');
    }

    return enteredDigits.length == parsedPhone.nsn.length;
  }

  /// Builds the username format expected by the login API.
  ///
  /// For regular countries this becomes `<countryCode><nsn>`.
  /// For territories such as Bahamas, the parsed NSN already starts with the
  /// displayed territory code (`242`), so we reuse the NSN directly.
  String _buildApiUsername({
    required PhoneNumber parsedPhone,
    required String displayDialCode,
  }) {
    if (parsedPhone.nsn.startsWith(displayDialCode)) {
      return parsedPhone.nsn;
    }

    return '$displayDialCode${parsedPhone.nsn}';
  }
}
