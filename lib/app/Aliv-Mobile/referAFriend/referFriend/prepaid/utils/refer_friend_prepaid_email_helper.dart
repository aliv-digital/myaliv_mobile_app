class ReferFriendPrepaidEmailHelper {
  const ReferFriendPrepaidEmailHelper();

  static const String invalidEmailMessage = 'invalid email address';

  /// Reuses the same basic email rule already used in the profile email flow.
  bool isValid(String rawEmail) {
    final String trimmedEmail = rawEmail.trim();

    if (trimmedEmail.isEmpty) {
      return false;
    }

    if (trimmedEmail.contains(' ')) {
      return false;
    }

    final List<String> emailParts = trimmedEmail.split('@');
    if (emailParts.length != 2) {
      return false;
    }

    final String localPart = emailParts[0];
    final String domainPart = emailParts[1];

    if (localPart.isEmpty || domainPart.isEmpty) {
      return false;
    }

    final int firstDotIndex = domainPart.indexOf('.');
    final int lastDotIndex = domainPart.lastIndexOf('.');

    if (firstDotIndex <= 0 || lastDotIndex == domainPart.length - 1) {
      return false;
    }

    return true;
  }

  /// Live validation stays quiet until the user starts typing.
  bool hasLiveValidationError(String rawEmail) {
    if (rawEmail.trim().isEmpty) {
      return false;
    }

    return !isValid(rawEmail);
  }
}
