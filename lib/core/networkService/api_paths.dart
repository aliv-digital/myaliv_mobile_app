class Api {
  static const baseUrl = 'https://mockservice.newcomobile.com/NewCoRestApi';
  static const loginUrl = '$baseUrl/v1/MyAliv/Auth/login';
  static const verifyOtpUrl = '$baseUrl/v1/MyAliv/Auth/two-factor-auth';
  static const resendOtpUrl = '$baseUrl/v1/MyAliv/Auth/two-factor-auth/resend';

  static const accountUrl = '$baseUrl/v1/MyAliv/Account';
  static const logOutUrl = '$baseUrl/v1/MyAliv/Auth/logout';

  static const getAllPlans = '$baseUrl/v1/MyAliv/device';
  static const getBundles = '$baseUrl/v1/MyAliv/device';
// body: {"Ticket":"db09c1ce-9969-43d3-a346-a5cb18f1d366MexB4vZwJ30PyNaWKbfAK+8+7DLAMFyFUPIZmmueGWj+8J5i+JYxU5beqX7pZxPS1NCtV/Jc570QMV3IiQucnw==","AccountId":1320845927}
  //{{baseUrl}}/v1/MyAliv/device/{{deviceAccountId}}/bundles
}