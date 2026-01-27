

import '../models/refer_friend_prepaid_models.dart';

class ReferFriendPrepaidRepository {
  Future<void> shareReferral({
    required String friendPhone,
    required String friendEmail,
  }) async {
    // TODO: API integration later
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> redeemReferral({required String code}) async {
    // TODO: API integration later
    await Future.delayed(const Duration(milliseconds: 600));

    // demo validation
    if (code.trim().length < 5) {
      throw Exception('invalid');
    }
  }

  Future<List<ReferralHistoryItem>> fetchHistory() async {
    // TODO: API integration later
    await Future.delayed(const Duration(milliseconds: 350));

    return const [
      ReferralHistoryItem(
        code: '0002391',
        email: 'Jade123@hotmail.com',
        sentDate: '12/02/2024',
        acceptedDate: 'Pending',
        expiryLabel: 'Exp: 12/02/2024',
      ),
      ReferralHistoryItem(
        code: '0002391',
        email: 'Jade123@hotmail.com',
        sentDate: '12/02/2024',
        acceptedDate: '12/02/2024',
      ),
      ReferralHistoryItem(
        code: '0002391',
        email: 'Jade123@hotmail.com',
        sentDate: '12/02/2024',
        acceptedDate: '12/02/2024',
      ),
    ];
  }
}
