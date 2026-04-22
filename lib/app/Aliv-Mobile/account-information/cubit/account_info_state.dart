import 'package:equatable/equatable.dart';
import '../../loginOtp/model/account_info_model.dart';

/// Status of account information operations
enum AccountInfoStatus {
  /// Initial state, no data loaded yet
  initial,

  /// Loading account information
  loading,

  /// Account information loaded successfully
  success,

  /// Failed to load account information
  failure,

  /// Refreshing existing account information
  refreshing,
}

/// State for account information management
///
/// This state is hydrated and persists across app restarts.
class AccountInfoState extends Equatable {
  const AccountInfoState({
    this.status = AccountInfoStatus.initial,
    this.accountInfo,
    this.lastFetchedAt,
    this.errorMessage,
    this.isTogglingAutoPayInvoice = false,
  });

  final AccountInfoStatus status;
  final AccountInfoModel? accountInfo;
  final DateTime? lastFetchedAt;
  final String? errorMessage;

  /// Whether auto-pay invoice toggle operation is in progress
  final bool isTogglingAutoPayInvoice;

  // ========== Computed Properties ==========

  /// Check if account information is available
  bool get hasAccount => accountInfo != null;

  /// Check if user is prepaid
  bool get isPrepaid => accountInfo?.paymentOption == "PrePay";

  /// Check if user is postpaid
  bool get isPostpaid => accountInfo?.paymentOption == "PostPay";

  /// Get device account ID
  String? get deviceAccountID => accountInfo?.idAcc.toString();

  /// Get user email
  String? get email => accountInfo?.email;

  /// Get account status
  String? get accountStatus => accountInfo?.accountStatus;

  /// Get account type
  String? get accountType => accountInfo?.accountType;

  /// Get payment option
  String? get paymentOption => accountInfo?.paymentOption;

  /// Get first name
  String? get firstName => accountInfo?.fName;

  /// Get last name
  String? get lastName => accountInfo?.lName;

  /// Get full name
  String? get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    final combined = '$first $last'.trim();
    return combined.isEmpty ? null : combined;
  }

  /// Get auto-pay invoice status (for postpaid)
  bool get autoPayInvoice => accountInfo?.autoPayInvoice ?? false;

  /// Check if cache is stale based on TTL (time-to-live)
  bool isCacheStale({Duration ttl = const Duration(hours: 24)}) {
    if (lastFetchedAt == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastFetchedAt!);
    return difference > ttl;
  }

  // ========== State Management ==========

  AccountInfoState copyWith({
    AccountInfoStatus? status,
    AccountInfoModel? accountInfo,
    DateTime? lastFetchedAt,
    String? errorMessage,
    bool? isTogglingAutoPayInvoice,
  }) {
    return AccountInfoState(
      status: status ?? this.status,
      accountInfo: accountInfo ?? this.accountInfo,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      errorMessage: errorMessage,
      isTogglingAutoPayInvoice:
          isTogglingAutoPayInvoice ?? this.isTogglingAutoPayInvoice,
    );
  }

  /// Create state for clearing account information
  AccountInfoState cleared() {
    return const AccountInfoState(
      status: AccountInfoStatus.initial,
      accountInfo: null,
      lastFetchedAt: null,
      errorMessage: null,
      isTogglingAutoPayInvoice: false,
    );
  }

  // ========== Serialization for HydratedBloc ==========

  /// Serialize state to JSON for hydration
  Map<String, dynamic> toJson() {
    return {
      'status': status.index, // Store enum as int
      'accountInfo': accountInfo?.toJson(),
      'lastFetchedAt': lastFetchedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      // isTogglingAutoPayInvoice is transient, not persisted
    };
  }

  /// Deserialize state from JSON
  static AccountInfoState fromJson(Map<String, dynamic> json) {
    return AccountInfoState(
      status: AccountInfoStatus.values[json['status'] as int? ?? 0],
      accountInfo: json['accountInfo'] != null
          ? AccountInfoModel.fromJson(
              json['accountInfo'] as Map<String, dynamic>,
            )
          : null,
      lastFetchedAt: json['lastFetchedAt'] != null
          ? DateTime.parse(json['lastFetchedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        status,
        accountInfo,
        lastFetchedAt,
        errorMessage,
        isTogglingAutoPayInvoice,
      ];
}
