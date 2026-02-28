import 'make_payment_postpaid_repository.dart';

class MakePaymentPostPaidRepositoryImpl
    implements MakePaymentPostPaidRepository {
  @override
  Future<MakePaymentPostPaidData> fetchPaymentData() async {
    return const MakePaymentPostPaidData(
      title: 'payment',
      paymentDueAmount: r'$ 129.00',
      bottomAmount: r'$ 129.00',
      bottomSubtitle: 'no vat applied',
      methods: [
        MpPaymentMethod(
          brand: MpCardBrand.visa,
          ending: '1234',
          expiry: '06/2024',
        ),
        MpPaymentMethod(
          brand: MpCardBrand.mastercard,
          ending: '1234',
          expiry: '06/2024',
        ),
      ],
    );
  }
}
