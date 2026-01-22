
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/models/auto_renew_prepaid_models.dart';

abstract class AutoRenewPrepaidRepository {
  Future<List<SavedCard>> fetchSavedCards();
  Future<SavedCard> saveNewCard({required int month, required int year});
  Future<void> saveSelectedMethod(String methodId);
}

class AutoRenewPrepaidRepositoryImpl implements AutoRenewPrepaidRepository {
  @override
  Future<List<SavedCard>> fetchSavedCards() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      SavedCard(
        id: 'card_visa_1',
        brand: CardBrand.visa,
        ending: '1234',
        expiry: '06/2024',
      ),
      SavedCard(
        id: 'card_mc_1',
        brand: CardBrand.mastercard,
        ending: '1234',
        expiry: '06/2024',
      ),
    ];
  }

  @override
  Future<SavedCard> saveNewCard({required int month, required int year}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final mm = month.toString().padLeft(2, '0');
    final yy = year.toString();
    return SavedCard(
      id: 'card_new_${DateTime.now().millisecondsSinceEpoch}',
      brand: CardBrand.visa,
      ending: '1234',
      expiry: '$mm/$yy',
    );
  }

  @override
  Future<void> saveSelectedMethod(String methodId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // TODO: integrate API
  }
}
