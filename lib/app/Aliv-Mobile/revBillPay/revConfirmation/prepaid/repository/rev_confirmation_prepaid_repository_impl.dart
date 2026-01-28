import 'rev_confirmation_prepaid_repository.dart';

class RevConfirmationPrepaidRepositoryImpl implements RevConfirmationPrepaidRepository {
  @override
  Future<RevConfirmationData> fetchConfirmation() async {
    await Future.delayed(const Duration(milliseconds: 350));

    return const RevConfirmationData(
      customerName: 'Jade Turnquest',
      service: 'REV',
      accountNumber: '348340572044',
      amount: 200.00,
      vat: 0.00,
    );
  }

  @override
  Future<PromoResult> applyPromo({
    required String code,
    required double subtotal,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    final normalized = code.trim().toUpperCase();

    // Demo rule:
    // SAVE10 => 10% discount
    if (normalized == 'SAVE10') {
      return PromoResult(discount: subtotal * 0.10);
    }

    // invalid or no discount
    return const PromoResult(discount: 0.0);
  }
}
