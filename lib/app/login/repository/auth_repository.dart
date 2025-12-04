// lib/login/login_repository.dart
class LoginRepository {
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    // TODO: এখানে তোমার API call বসাবে
    await Future.delayed(const Duration(seconds: 1));

    // demo: সবসময় invalid করবে
    throw Exception('invalid credentials!');
  }
}

