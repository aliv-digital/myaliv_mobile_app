import 'package:equatable/equatable.dart';

class ReferralHistoryItem extends Equatable {
  final String code;
  final String email;
  final String sentDate; // display-friendly (ex: 12/02/2024)
  final String acceptedDate; // 'Pending' or date
  final String? expiryLabel; // ex: 'Exp: 12/02/2024' (optional)

  const ReferralHistoryItem({
    required this.code,
    required this.email,
    required this.sentDate,
    required this.acceptedDate,
    this.expiryLabel,
  });

  @override
  List<Object?> get props => [code, email, sentDate, acceptedDate, expiryLabel];
}
