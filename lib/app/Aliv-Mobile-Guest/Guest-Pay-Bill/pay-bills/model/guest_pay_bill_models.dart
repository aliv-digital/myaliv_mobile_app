class BillService {
  final String code; // e.g. 'REV', 'ALIV_POSTPAID'
  final String label; // e.g. 'REV', 'ALIV Postpaid'
  const BillService({required this.code, required this.label});
}

class PayBillAccountInfo {
  final String status; // Active
  final String? name; // optional (REV type)
  final double? balance; // optional (REV type)
  final int? fibrAccountId; // id_acc from /Guest/fibrbalance response

  const PayBillAccountInfo({
    required this.status,
    this.name,
    this.balance,
    this.fibrAccountId,
  });
}

class PayBillCountry {
  final String flagEmoji;
  final String dialCode;
  final String isoCode;

  const PayBillCountry({
    required this.flagEmoji,
    required this.dialCode,
    required this.isoCode,
  });

  static const PayBillCountry defaultCountry = PayBillCountry(
    flagEmoji: '🇧🇸',
    dialCode: '1',
    isoCode: 'BS',
  );
}
