import '../model/add_or_edit_cards_prepaid_models.dart';

class AddOrEditCardsPrepaidRepository {
  Future<List<SavedCard>> fetchSavedCards() async {
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      SavedCard(
        id: '1',
        brand: CardBrand.visa,
        ending: '1234',
        expiry: '06/2024',
      ),
      SavedCard(
        id: '2',
        brand: CardBrand.mastercard,
        ending: '1234',
        expiry: '06/2024',
      ),
    ];
  }

  Future<void> deleteCard(String id) async {
    await Future.delayed(const Duration(milliseconds: 350));
  }

  /// ✅ new card save
  Future<SavedCard> saveCard({
    required int month,
    required int year,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mm = month.toString().padLeft(2, '0');
    final expiry = '$mm/$year';

    // Demo: always add VISA ending 1234
    return SavedCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      brand: CardBrand.visa,
      ending: '1234',
      expiry: expiry,
    );
  }
}
