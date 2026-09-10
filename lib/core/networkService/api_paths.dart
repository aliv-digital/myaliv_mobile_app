class Api {
  static const baseUrl = 'https://mockservice.newcomobile.com/NewCoRestApi';
  static const loginUrl = '$baseUrl/v1/MyAliv/Auth/login';
  static const forgotPasswordUrl = '$baseUrl/v1/MyAliv/Auth/forgot';
  static const updatePasswordUrl = '$baseUrl/v1/MyAliv/Auth/update-password';
  static const verifyOtpUrl = '$baseUrl/v1/MyAliv/Auth/2fa/verify';
  static const resendOtpUrl = '$baseUrl/v1/MyAliv/Auth/2fa/resend';
  static const refreshUrl = '$baseUrl/v1/MyAliv/Auth/refresh';

  static const accountUrl = '$baseUrl/v1/MyAliv/Account';
  static const logOutUrl = '$baseUrl/v1/MyAliv/Auth/logout';
  static const logOutAllUrl = '$baseUrl/v1/MyAliv/Auth/logout-all';

  static const getAllPlans = '$baseUrl/v1/MyAliv/device';
  static const getBundles = '$baseUrl/v1/MyAliv/device';
  static const adsTimer = 'https://myalivappuat-api.bealiv.com/api/ads-timer/active';
  static const bestPlans = 'https://myalivappuat-api.bealiv.com/api/plans/active';
  static const balances = '$baseUrl/v1/MyAliv/device'; // Append /{deviceAccountId}/balances
  static const consumptionLimits = '$baseUrl/v1/MyAliv/device'; // Append /{deviceAccountId}/query-consumption-limi
  static const devices = '$baseUrl/v1/MyAliv/Account/devices'; // Get device limits for credit limit update
  static const deviceLimits = '$baseUrl/v1/MyAliv/device'; // Append /{deviceAccountId}/limits - PUT to update limits
  static const usages = '$baseUrl/v1/MyAliv/Account/usages'; // GET with ?startDate=&endDate= (ISO 8601)
  static const transactions = '$baseUrl/v1/MyAliv/Account/transactions'; // GET with ?startDate=&endDate= (ISO 8601)
  static const rewards = '$baseUrl/v1/MyAliv/Info/rewards'; // GET - fetch all rewards

  // Auto-renew endpoints
  /// Auto-renew from wallet: PUT /device/{deviceAccountId}/auto-renew?autoRenew={true|false}
  static String deviceAutoRenew(int deviceAccountId) =>
      '$baseUrl/v1/MyAliv/device/$deviceAccountId/auto-renew';

  /// Auto-renew from credit card: PUT /CreditCard/auto-renew
  /// Body: `{ "Token": "...", "AgreementText": "I agree to automatic renewal" }`
  /// Also supports GET to read the currently saved auto-renew token (prepaid):
  /// Response: `{ "Token": "..." }`
  static const creditCardAutoRenew = '$baseUrl/v1/MyAliv/CreditCard/auto-renew';

  /// Auto-pay token for postpaid: GET /CreditCard/auto-pay
  /// Response: `{ "Token": "..." }`
  static const creditCardAutoPay = '$baseUrl/v1/MyAliv/CreditCard/auto-pay';

  /// Saved credit cards: GET /CreditCard/saved
  static const savedCardsUrl = '$baseUrl/v1/MyAliv/CreditCard/saved';

  /// Auto-pay invoice for postpaid: PUT /Account/invoice-autopayment?autoPayInvoice={true|false}
  static String invoiceAutoPayment(bool enable) =>
      '$baseUrl/v1/MyAliv/Account/invoice-autopayment?autoPayInvoice=$enable';

  /// Balance threshold settings: PUT /device/{deviceAccountId}/balance-threshold-settings
  static String balanceThresholdSettings(int deviceAccountId) =>
      '$baseUrl/v1/MyAliv/device/$deviceAccountId/balance-threshold-settings';

  static const faq = 'https://myalivappuat-api.bealiv.com/api/app-settings/faqs';
  static const privacyPolicy = 'https://myalivappuat-api.bealiv.com/api/app-settings/privacy-policy';
  static const security = 'https://myalivappuat-api.bealiv.com/api/app-settings/security';
  static const isReferralValid = '$baseUrl/v1/MyAliv/Referral';
  static const referAFriend = '$baseUrl/v1/MyAliv/Referral/refer';

  static const redeemReferral = '$baseUrl/v1/MyAliv/Referral/redeem';

  // Invoice endpoints
  static const invoices = '$baseUrl/v1/MyAliv/Account/invoices';

  /// Invoice PDF download: GET /Account/invoice/{invoiceId}?filename={encodedFilePath}
  /// Returns base64 encoded PDF string
  static String invoicePdf(int invoiceId, String filename) =>
      '$baseUrl/v1/MyAliv/Account/invoice/$invoiceId?filename=${Uri.encodeComponent(filename)}';

  static const referAFriendText = 'https://myalivappuat-api.bealiv.com/api/app-settings/refer-a-friend';
  static const redeemReferralText = "https://myalivappuat-api.bealiv.com/api/app-settings/redeem-referral";

  static const startFuturePlan = '$baseUrl/v1/MyAliv/device'; // Append /{deviceAccountId}/future-plan - POST to start future plan

  static const guestPageMobileImage = 'https://myalivappuat-api.bealiv.com/api/app-settings/guest-page-mobile-image';
  static const welcomePageMobileImage = 'https://myalivappuat-api.bealiv.com/api/app-settings/login-page-mobile-image';

  static const prepaidTermsConditions = "https://myalivappuat-api.bealiv.com/api/app-settings/terms-and-conditions-prepaid";
  static const postPaidTermsConditions = "https://myalivappuat-api.bealiv.com/api/app-settings/terms-and-conditions-postpaid";

  // {{baseUrl}}/v1/MyAliv/device/{{deviceAccountId}}/promo-code-info?promoCode=12345
  static String applyPromoCodeUrl({
    required int deviceAccountId,
    required String promoCode,
  }) {
    final encodedPromoCode = Uri.encodeQueryComponent(promoCode);
    return '$baseUrl/v1/MyAliv/device/$deviceAccountId/promo-code-info?promoCode=$encodedPromoCode';
  }

  /// Alternate-contact number validation: GET /AltNumber/validate/{altNumber}
  /// Response: `{ "IsValid": true }`
  static String altNumberValidate(String altNumber) =>
      '$baseUrl/v1/MyAliv/AltNumber/validate/${Uri.encodeComponent(altNumber.trim())}';

  /// Alternate-contact number update: POST /AltNumber
  /// Body: `{ "NewAltNumber": "<number>" }`
  /// Response: `{ "Success": true }`
  static const altNumberUpdate = '$baseUrl/v1/MyAliv/AltNumber';

  static const payFromWalletUrl = "$baseUrl/v1/MyAliv/Order/change-bundle";

  /// Order status verification: GET /Order?orderId={orderId}
  /// Pass as [PaymentRequest.orderVerificationUrl] to enable server-side
  /// outcome check after the payment redirect (`OrderStatus == "Completed"`).
  static const orderVerificationUrl = '$baseUrl/v1/MyAliv/Order';

  /// Top-up 24h rolling limit remaining:
  /// GET /Account/top-up-limit-left
  /// Response: `{ "TopUp24HourLimitLeft": <number>, "EarliestTopUpDate": "YYYY-MM-DD HH:mm:ss" (UTC) }`
  static const topUpLimitLeft = '$baseUrl/v1/MyAliv/Account/top-up-limit-left';

  /// Recipient transfer eligibility check (Send Top-up preflight, Gate 2):
  /// GET /device/transfer-is-valid/{phoneNumber}
  /// 200 → `{ "Success": true }` — can proceed
  /// non-200 → `{ "ErrorCode": ..., "Message": "...", ... }` — show Message
  static String transferIsValid({required String phoneNumber}) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '$baseUrl/v1/MyAliv/device/transfer-is-valid/${Uri.encodeComponent(digits)}';
  }

  /// Recipient phone-number-is-an-Aliv-device check (Send Top-up Gate 0):
  /// GET /device/exists/{phoneNumber}
  /// Success → 200 `{ "Success": true }`
  /// Not found → error envelope `{ "ErrorCode": 501, "ErrorCodeName": "InvalidDevice", ... }`
  static String deviceExists({required String phoneNumber}) {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '$baseUrl/v1/MyAliv/device/exists/${Uri.encodeComponent(digits)}';
  }

  /// Concurrent-order pre-flight (Gate 3, both tabs):
  /// GET /Account/can-submit-order?amount={amount}
  /// Response is always HTTP 200. Check the body:
  ///   `{ "Info": "" }`                          → OK
  ///   `{ "Info": "Order # ... in progress..." }` → blocked, display Info directly
  static String canSubmitOrder({required double amount}) =>
      '$baseUrl/v1/MyAliv/Account/can-submit-order?amount=$amount';

  /// Top-up (recharge) endpoint. Phone number is the recipient's primary
  /// number and lives in the URL path; body shape matches change-bundle
  /// minus the `Bundle` block.
  /// POST /Order/top-up/{PrimaryPhoneNumber}
  static String topUpUrl(String primaryPhoneNumber) =>
      '$baseUrl/v1/MyAliv/Order/top-up/${Uri.encodeComponent(primaryPhoneNumber.trim())}';

  /// 3DS top-up initiation: POST /Order/3ds/top-up/{PrimaryPhoneNumber}
  /// Same body shape as [topUpUrl]. Returns `{"html": "..."}` for the iframe.
  static String topUp3dsUrl(String primaryPhoneNumber) =>
      '$baseUrl/v1/MyAliv/Order/top-up/3ds/${Uri.encodeComponent(primaryPhoneNumber.trim())}';

  /// Postpaid make-payment endpoint. Same envelope shape as top-up (no
  /// `Bundle` block); account is inferred from the auth context.
  /// POST /Order/payment
  static const orderPaymentUrl = '$baseUrl/v1/MyAliv/Order/payment';

  /// Wallet-to-wallet transfer (send top-up):
  /// POST /Order/transfer
  /// Body: `{ "ToNumber": "<digits>", "Amount": <number> }`
  static const orderTransferUrl = '$baseUrl/v1/MyAliv/Order/transfer';
  //{{baseUrl}}/v1/MyAliv/device/:deviceAccountId/bucket-usage-summary
  static String bucketUsageSummary(int deviceAccountId) => '$baseUrl/v1/MyAliv/device/$deviceAccountId/bucket-usage-summary';

  /// Alternate-contact marketing preference: POST /AltNumber/opt-in/{number}
  /// Body: `{ "DeviceAccountId": <int>, "IsOptedIn": <bool> }`
  static String mifiAltNumber(String number) =>
      '$baseUrl/v1/MyAliv/AltNumber/opt-in/${Uri.encodeComponent(number.trim())}';
  static const addCreditCard = "$baseUrl/v1/MyAliv/CreditCard/add";

  /// Guest top-up (no auth required).
  /// POST /v1/MyAliv/Guest/top-up
  /// Body: `{ "Amount": double, "PhoneNumber": "digits",
  ///          "RedirectURL": "myaliv://topup-callback",
  ///          "Branch": "BRANCH_MAIN", "ChannelType": "SelfCare" }`
  /// Response: `{ "html": "full HTML document" }`
  static const guestTopupUrl = '$baseUrl/v1/MyAliv/Guest/top-up';
}
