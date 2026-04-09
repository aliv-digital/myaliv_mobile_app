import '../../loginOtp/model/account_info_model.dart';

/// Abstract base class for account information repositories.
///
/// This interface defines the contract for account operations.
/// Implementations can be:
/// - Production repository (API-based)
/// - Mock repository (hardcoded data for testing/development)
/// - Test repository (for unit tests)
abstract class BaseAccountInfoRepository {
  /// Fetches account details using Basic Auth.
  ///
  /// Credentials are automatically retrieved from AuthManager.
  /// Returns [AccountInfoModel] containing user account information.
  /// Throws [AccountInfoException] on errors.
  Future<AccountInfoModel> fetchAccountInfo();
}
