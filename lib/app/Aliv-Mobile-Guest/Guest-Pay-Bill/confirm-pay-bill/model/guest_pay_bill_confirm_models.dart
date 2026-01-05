class GuestPayBillConfirmArgs {
  final String serviceName;           // e.g. ALIV Postpaid, ALIVFibr
  final String identifierLabel;       // e.g. "mobile no.", "Acc #"
  final String identifierValue;       // e.g. "242-801-0000", "348340572044"
  final double amount;                // e.g. 200.00

  const GuestPayBillConfirmArgs({
    required this.serviceName,
    required this.identifierLabel,
    required this.identifierValue,
    required this.amount,
  });
}
