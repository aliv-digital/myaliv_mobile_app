enum CardBrand { visa, mastercard, unknown }
enum AutoRenewMethodType { card, wallet, none }

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

  bool get isCard => type == AutoRenewMethodType.card;
}
