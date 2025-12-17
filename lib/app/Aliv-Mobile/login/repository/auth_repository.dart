// lib/login/login_repository.dart
import 'package:flutter/material.dart';

class LoginRepository {
  Future<void> login({
    required String phone,
    required String password,
  }) async {
    // TODO: এখানে তোমার API call বসাবে
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('phone: $phone, password: $password');
    // demo: সবসময় invalid করবে
    throw Exception('invalid credentials!');
  }
}

