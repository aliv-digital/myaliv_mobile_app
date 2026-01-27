class EnterPasswordPostpaidRepository {
  Future<bool> verifyPassword(String password) async {
    // TODO: API call later
    await Future.delayed(const Duration(milliseconds: 350));
    return password.length >= 4;
  }

  Future<void> authenticateWithFaceId() async {
    // TODO: local_auth later
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> authenticateWithFingerprint() async {
    // TODO: local_auth later
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
