import 'package:equatable/equatable.dart';

enum GuestCardBrand { visa, mastercard, unknown }

class GuestSavedPaymentMethod extends Equatable {
  final String id;
  final GuestCardBrand brand;
  final String ending; // "1234"
  final String expiry; // "06/2024"
  final bool isChargeToMyAccount;

  /// ✅ SVG logo asset path (you will set later)
  final String logoSvgAsset;

  const GuestSavedPaymentMethod({
    required this.id,
    required this.brand,
    required this.ending,
    required this.expiry,
    required this.logoSvgAsset,
    this.isChargeToMyAccount = false,
  });

  @override
  List<Object?> get props => [
        id,
        brand,
        ending,
        expiry,
        logoSvgAsset,
        isChargeToMyAccount,
      ];
}
