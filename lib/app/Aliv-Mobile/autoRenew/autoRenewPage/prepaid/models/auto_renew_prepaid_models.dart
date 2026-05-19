enum CardBrand { visa, mastercard, unknown }
enum AutoRenewMethodType { card, wallet, none, payWithCard }

class SavedCard {
  final String id;
  final CardBrand brand;
  final String ending;
  final String expiry; // "06/2024"

  const SavedCard({
    required this.id,
    required this.brand,
    required this.ending,
    required this.expiry,
  });
}

class AutoRenewPaymentMethod {
  final String id;
  final AutoRenewMethodType type;
  final SavedCard? card;

  const AutoRenewPaymentMethod._({
    required this.id,
    required this.type,
    this.card,
  });

  /// ✅ NOT const (because id depends on runtime card)
  factory AutoRenewPaymentMethod.card(SavedCard card) {
    return AutoRenewPaymentMethod._(
      id: card.id,
      type: AutoRenewMethodType.card,
      card: card,
    );
  }

  /// ✅ const is fine
  static const AutoRenewPaymentMethod wallet =
  AutoRenewPaymentMethod._(id: 'wallet', type: AutoRenewMethodType.wallet);

  /// ✅ const is fine
  static const AutoRenewPaymentMethod none =
  AutoRenewPaymentMethod._(id: 'none', type: AutoRenewMethodType.none);

  /// Selectable "pay with card" entry — navigates to add/edit cards on proceed.
  static const AutoRenewPaymentMethod payWithCard =
  AutoRenewPaymentMethod._(id: 'pay-with-card', type: AutoRenewMethodType.payWithCard);

  bool get isCard => type == AutoRenewMethodType.card;
}
