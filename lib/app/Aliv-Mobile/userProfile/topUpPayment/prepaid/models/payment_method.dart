import 'package:equatable/equatable.dart';

enum CardBrand { visa, mastercard }

class PaymentMethod extends Equatable {
  final String id;
  final CardBrand brand;
  final String last4;
  final String expiry; // "06/2024"
  final String logoAsset; // asset path

  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.logoAsset,
  });

  String get title {
    switch (brand) {
      case CardBrand.visa:
        return 'visa ending in $last4';
      case CardBrand.mastercard:
        return 'mastercard ending in $last4';
    }
  }

  @override
  List<Object?> get props => [id, brand, last4, expiry, logoAsset];
}
