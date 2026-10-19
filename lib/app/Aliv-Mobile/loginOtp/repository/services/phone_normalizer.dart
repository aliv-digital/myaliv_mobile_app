/// Service for normalizing and validating phone numbers.
///
/// Handles phone number formatting for API requests.
class PhoneNormalizer {
  /// Extracts only digits from a phone number string.
  ///
  /// Example: "+1 (242) 899-7105" -> "12428997105"
  String normalize(String phoneNumber) {
    final StringBuffer digitsOnlyBuffer = StringBuffer();

    for (int index = 0; index < phoneNumber.length; index++) {
      final String character = phoneNumber[index];
      final int codeUnit = character.codeUnitAt(0);
      final bool isDigit = codeUnit >= 48 && codeUnit <= 57;

      if (isDigit) {
        digitsOnlyBuffer.write(character);
      }
    }

    return digitsOnlyBuffer.toString();
  }

  /// Validates if a phone number has a valid format.
  ///
  /// Returns true if the phone number contains at least 7 digits and at most 15 digits.
  bool isValid(String phoneNumber) {
    final normalized = normalize(phoneNumber);
    return normalized.length >= 7 && normalized.length <= 15;
  }
}
