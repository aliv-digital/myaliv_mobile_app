import 'package:equatable/equatable.dart';

/// Card data captured from a checkout form, ready to be sent as the
/// `CardPayment` block of the `change-bundle` API.
///
/// All fields are pre-formatted for the API:
/// - [cardNumber] — digits only, no spaces (`"4012000000020006"`)
/// - [cardExpiration] — `"YYYY-MM"` (`"2028-12"`)
/// - [cardSecurityCode] — 3 or 4 digits (`"042"`)
/// - [cardHolderName] — trimmed (`"Credit Card Holder"`)
class NewCardDetails extends Equatable {
  final String cardNumber;
  final String cardExpiration;
  final String cardSecurityCode;
  final String cardHolderName;

  const NewCardDetails({
    required this.cardNumber,
    required this.cardExpiration,
    required this.cardSecurityCode,
    required this.cardHolderName,
  });

  @override
  List<Object?> get props =>
      [cardNumber, cardExpiration, cardSecurityCode, cardHolderName];
}
