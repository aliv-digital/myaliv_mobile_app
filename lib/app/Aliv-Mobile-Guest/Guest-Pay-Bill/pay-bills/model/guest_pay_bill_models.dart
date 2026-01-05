class BillService {
  final String code;   // e.g. 'REV', 'ALIV_POSTPAID'
  final String label;  // e.g. 'REV', 'ALIV Postpaid'
  const BillService({required this.code, required this.label});
}

class PayBillAccountInfo {
  final String status;      // Active
  final String? name;       // optional (REV type)
  final double? balance;    // optional (REV type)

  const PayBillAccountInfo({
    required this.status,
    this.name,
    this.balance,
  });
}
