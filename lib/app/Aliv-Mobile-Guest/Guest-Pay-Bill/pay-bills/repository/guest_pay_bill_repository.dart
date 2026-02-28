import '../model/guest_pay_bill_models.dart';

class GuestPayBillRepository {
  Future<List<BillService>> fetchServices() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const [
      BillService(code: 'ALIV_POSTPAID', label: 'ALIV Postpaid'),
      BillService(code: 'ALIV_FIBR', label: 'ALIVFibr'),
      BillService(code: 'REV', label: 'REV'),
    ];
  }

  Future<PayBillAccountInfo> verifyAlivPostpaid({
    required String mobileNumber,
    required String confirmMobileNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (mobileNumber.trim().isEmpty || confirmMobileNumber.trim().isEmpty) {
      throw Exception('Missing number');
    }
    if (mobileNumber.trim() != confirmMobileNumber.trim()) {
      throw Exception('Number mismatch');
    }

    // Sample response aligned with the UI mock.
    return const PayBillAccountInfo(
      status: 'Active',
      balance: 200.00,
    );
  }

  Future<PayBillAccountInfo> verifyRev({
    required String accountNumber,
    required String enteredName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (accountNumber.trim().length >= 8) {
      return const PayBillAccountInfo(
        status: 'Active',
        name: 'James Bain',
        balance: 200.00,
      );
    }

    throw Exception('Account not found');
  }

  Future<PayBillAccountInfo> verifyAlivFibr({
    required String accountNumberOrUsername,
    required String enteredName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (accountNumberOrUsername.trim().length >= 8) {
      return PayBillAccountInfo(
        status: 'Active',
        name: enteredName.trim().isEmpty ? 'Tanya Bain' : enteredName.trim(),
        balance: 200.00,
      );
    }

    throw Exception('Account not found');
  }

  Future<void> submitBillPayment({
    required String serviceCode,
    required String identifier, // phone or account number
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return;
  }
}
