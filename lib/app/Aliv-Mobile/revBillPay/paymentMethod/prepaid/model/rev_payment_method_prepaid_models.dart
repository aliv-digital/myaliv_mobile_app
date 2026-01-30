import 'package:equatable/equatable.dart';

enum RevCardBrand { visa, mastercard, unknown }

class RevSavedPaymentMethod extends Equatable {
  final String id;
  final RevCardBrand brand;
  final String ending; // "1234"
  final String expiry; // "06/2024"

  /// ✅ SVG logo asset path (you will set later)
  final String logoSvgAsset;

  const RevSavedPaymentMethod({
    required this.id,
    required this.brand,
    required this.ending,
    required this.expiry,
    required this.logoSvgAsset,
  });

  @override
  List<Object?> get props => [id, brand, ending, expiry, logoSvgAsset];
}
