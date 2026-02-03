import 'rev_prepaid_repository.dart';

class RevPrepaidRepositoryImpl implements RevPrepaidRepository {
  @override
  Future<RevAccountInfo> fetchAccountInfo({
    required String accountNumber,
    required String name,
  }) async {
    // Mock (API later replace)
    await Future.delayed(const Duration(milliseconds: 500));

    return const RevAccountInfo(
      status: 'Active',
      balance: 200.00,
    );
  }
}
