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

  /// Auto-renew from credit card: PUT /CreditCard/auto-renew (empty body)
  static const creditCardAutoRenew = '$baseUrl/v1/MyAliv/CreditCard/auto-renew';
}