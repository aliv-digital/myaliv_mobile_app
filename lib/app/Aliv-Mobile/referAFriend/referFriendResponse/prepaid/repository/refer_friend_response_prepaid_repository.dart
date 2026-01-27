class ReferFriendResponsePrepaidRepository {
  Future<String> fetchReferralCode() async {
    // TODO: real API/LocalStorage integration later
    await Future.delayed(const Duration(milliseconds: 250));
    return 'REF026BFDFEA12';
  }
}
