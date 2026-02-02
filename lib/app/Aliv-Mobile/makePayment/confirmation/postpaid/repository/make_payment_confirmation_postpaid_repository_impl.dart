import 'make_payment_confirmation_postpaid_repository.dart';

class MakePaymentConfirmationPostPaidRepositoryImpl
    implements MakePaymentConfirmationPostPaidRepository {
  @override
  Future<MakePaymentConfirmationPostPaidData> fetchConfirmation() async {
    return const MakePaymentConfirmationPostPaidData(
      title: 'confirmation',
      customerName: 'Alicia Major',
      accountNumber: '242-801-1616',
      headerLabel: 'payment due',
      amountPill: r'$ 129.00',
      subtotal: r'$ 129.00',
      vat: r'$ 0.00',
      total: r'$ 129.00',
      bottomSubtitle: 'no vat applied',
      bottomAmount: r'$ 129.00',
    );
  }

  @override
  Future<void> applyPromo({required String code}) async {
    return;
  }
}
