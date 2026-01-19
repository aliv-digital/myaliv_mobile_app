import 'package:equatable/equatable.dart';

enum CardBrand { visa, mastercard, unknown }

class SavedCard extends Equatable {
  final String id;
  final CardBrand brand;
  final String ending; // "1234"
  final String expiry; // "06/2024"

  const SavedCard({
    required this.id,
    required this.brand,
    required this.ending,
    required this.expiry,
  });

  @override
  List<Object?> get props => [id, brand, ending, expiry];
}
