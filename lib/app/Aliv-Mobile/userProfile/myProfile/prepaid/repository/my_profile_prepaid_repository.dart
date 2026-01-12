import 'dart:async';
import '../model/my_profile_prepaid_model.dart';

class MyProfilePrepaidRepository {
  Future<MyProfilePrepaidModel> fetchProfile() async {
    // TODO: replace with real API call
    await Future.delayed(const Duration(milliseconds: 450));

    return const MyProfilePrepaidModel(
      avatarLetter: 'J',
      fullName: 'Jade Turnquest',
      statusLabel: 'active',
      phone: '242-801-1616',
      activeOn: '12/02/2024',
      email: 'digitalappss@bealiv.com',
      deviceTitle: 'your device',
      deviceModel: 'iphone 14 pro',
    );
  }
}
