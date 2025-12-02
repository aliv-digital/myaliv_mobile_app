class Api {
  static const baseUrl = 'https://uat.api.events.bealiv.com';
  // endpoints
  static const login = '/auth/signin_scan';
  static const verifyOtp = '/auth/verify_signin_otp_scan';
  static const getUserDetails = '/users/current_user';
  static const updateUserInfo = '/users/update_user_profile';
  static const getTickets = '/tickets'; // home tab e thakbe for getting current event
  static const me    = '/auth/me';
  static const getNotification = '/notification';
  static const resetPassword = '/users/reset_password';
  static const getUpcomingEvents = '/events/scan-app-upcoming'; // 2nd tab er lower portion e thakbe eita

  ///
  static const getActiveEvents = '/events/scan-app-active';
  ///events/scan/68
  static const getActiveEventById = '/events/scan/';
  static const getTicketHistoryByTicketId = '/tickets/history';

  static const getTicketsBySelectedEventID = '/tickets/event';
  static const postAllowTicketsToMarkedAsScanned = '/scan';

  static const defaultPic = 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgNuhWOJmTU309mVg39l-OPTv9ui4kJJXUZr6UZQpiMsKAxj1qSlfjCRjIoxR05yxiZUkmitTPVvDL7YHuBWVBFXZ1QBXR-itM0KFrzxiOkcubRfUWq980zdw8qkJJ1J9tzx6TpXLgLHUWFkEoqpydk0TYtsvlkPFTB6k62Jm1w1K13GYCQmr7w8hPd4zc/s512/broken-image.png';

  static const getUserTicketsByScan = '/tickets/qr-scan'; //{scanID got from scan}/{event ID = selected Active event}
  static const getAllTicketsOfUserByPhone = '/tickets/search'; //{event}/{phone} https://uat.api.events.bealiv.com/tickets/search/74/12425449020
  // jokhon manually ticket allow korte hobe and ticket history screen theke click kore oi user er shob
  // ticket dekhte jabe





  static const postRequestToSendForgotPassOTP = '/users/send_forgot_password_otp';
  static const postRequestToVerifyResetPassOTP = '/users/verify_password_reset_otp';
  static const postRequestToChangePassword = '/users/change_password';
}
/*


   @GET("tickets/event/{eventID}")
    suspend fun getAllTickets(@Header("Authorization") auth: String?,@Path("eventID") eventID:String): Response<ApiResponse<MutableList<TicketModel>>>


   ** Get all tickets of a single User by their phone no
   @GET("tickets/search/{event}/{phone}")
    suspend fun getAllTicketsbyPhone(@Header("Authorization") auth: String?,@Path("phone") eventID:String,@Path("event") eventID2:String): Response<ApiResponse<MutableList<TicketModel>>>

 ----- body for reset password -----

{
    "phone": "String",
    "phone_otp": "String",
    "password": "String",
    "new_password": "String",
    "password_reset_otp": "String"
}
data class userRequest(
    val phone: String?=null,
    val phone_otp: String?=null,
    val password: String?=null,
    val new_password: String?=null,
    val password_reset_otp: String?=null,
)















============ forgot password =================

verify otp
url : https://uat.api.events.bealiv.com/users/verify_password_reset_otp
req body :
{
    "phone" : "8801792812733",
    "phone_otp":"2580"
}

------------------------------------------------------------------------------------------

url : https://uat.api.events.bealiv.com/users/reset_password
req body :
{
    "phone" : "8801792812733",
    "new_password" : "newpass123"
}







============= Change Password ===============
url : https://uat.api.events.bealiv.com/users/change_password

req body :
{
    "oldPassword" : "newpass123",
    "password" : "newpass321",
    "password_confirmation" : "newpass321"
}














 */