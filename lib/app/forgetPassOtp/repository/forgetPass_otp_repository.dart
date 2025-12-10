class ForgetPasswordOtpRepository {
  Future<void> verifyCode({required String code}) async {
    // TODO: এখানে আসল API call বসাবে
    await Future.delayed(const Duration(seconds: 5));

    if (code != '12345') {
      throw Exception('Invalid code');
    }
  }

  Future<void> resendCode() async {
    // TODO: resend API
    await Future.delayed(const Duration(seconds: 1));
  }
}
