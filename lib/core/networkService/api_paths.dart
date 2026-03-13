class Api {
  static const baseUrl = 'https://mockservice.newcomobile.com/NewCoRestApi';
  static const loginUrl = '$baseUrl/v1/MyAliv/Auth/login';
  static const verifyOtpUrl = '$baseUrl/v1/MyAliv/Auth/two-factor-auth';
  static const resendOtpUrl = '$baseUrl/v1/MyAliv/Auth/two-factor-auth/resend';

  static const accountUrl = '$baseUrl/v1/MyAliv/Account';
  static const logOutUrl = '$baseUrl/v1/MyAliv/Auth/logout';

  static const getAllPlans = '$baseUrl/v1/MyAliv/device';
}