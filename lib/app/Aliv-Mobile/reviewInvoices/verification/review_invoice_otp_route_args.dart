class ReviewInvoiceOtpRouteArgs {
  const ReviewInvoiceOtpRouteArgs({
    required this.mfaToken,
    required this.apiPhoneNumber,
  });

  final String mfaToken;
  final String apiPhoneNumber;

  bool get isValid =>
      mfaToken.trim().isNotEmpty && apiPhoneNumber.trim().isNotEmpty;
}
