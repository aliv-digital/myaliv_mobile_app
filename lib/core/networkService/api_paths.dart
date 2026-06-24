class Api {
  static const baseUrl = 'https://mockservice.newcomobile.com/NewCoRestApi';
  static const loginUrl = '$baseUrl/v1/MyAliv/Auth/login';
  static const verifyOtpUrl = '$baseUrl/v1/MyAliv/Auth/two-factor-auth';
  static const resendOtpUrl = '$baseUrl/v1/MyAliv/Auth/two-factor-auth/resend';

  static const accountUrl = '$baseUrl/v1/MyAliv/Account';
  static const logOutUrl = '$baseUrl/v1/MyAliv/Auth/logout';

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

  static const payFromWalletUrl = "$baseUrl/v1/MyAliv/Order/change-bundle";

  /// Wallet-to-wallet transfer (send top-up):
  /// POST /Order/transfer
  /// Body: `{ "ToNumber": "<digits>", "Amount": <number> }`
  static const orderTransferUrl = '$baseUrl/v1/MyAliv/Order/transfer';
  //{{baseUrl}}/v1/MyAliv/device/:deviceAccountId/bucket-usage-summary
  static String bucketUsageSummary(int deviceAccountId) => '$baseUrl/v1/MyAliv/device/$deviceAccountId/bucket-usage-summary';
}
