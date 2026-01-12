import 'package:equatable/equatable.dart';

class MyProfilePrepaidModel extends Equatable {
  final String avatarLetter;
  final String fullName;
  final String statusLabel;

  final String phone;
  final String activeOn;
  final String email;

  final String deviceTitle;
  final String deviceModel;

  const MyProfilePrepaidModel({
    required this.avatarLetter,
    required this.fullName,
    required this.statusLabel,
    required this.phone,
    required this.activeOn,
    required this.email,
    required this.deviceTitle,
    required this.deviceModel,
  });

  @override
  List<Object?> get props => [
    avatarLetter,
    fullName,
    statusLabel,
    phone,
    activeOn,
    email,
    deviceTitle,
    deviceModel,
  ];
}
