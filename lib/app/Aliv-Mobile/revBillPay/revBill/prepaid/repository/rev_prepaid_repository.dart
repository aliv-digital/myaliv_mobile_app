class RevAccountInfo {
  final String status; // e.g. Active
  final double balance; // e.g. 200.00

  const RevAccountInfo({
    required this.status,
    required this.balance,
  });
}

abstract class RevPrepaidRepository {
  Future<RevAccountInfo> fetchAccountInfo({
    required String accountNumber,
    required String name,
  });
}
