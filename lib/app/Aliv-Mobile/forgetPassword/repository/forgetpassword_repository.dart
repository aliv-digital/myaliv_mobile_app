// lib/login/login_repository.dart
class ForgetPasswordRepository {
  Future<void> sendRequest({
    required String phone,
    required String password,
  }) async {
    // TODO: এখানে তোমার API call বসাবে
    await Future.delayed(const Duration(seconds: 1));

    // demo: সবসময় invalid করবে
    throw Exception('invalid credentials!');
  }
}

