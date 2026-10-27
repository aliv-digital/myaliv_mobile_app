import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/data_share_status.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';

enum GiftDataStatus {
  initial,
  loading,
  ready,
  ineligible,
  submitting,
  success,
  failure,
}

class GiftDataState extends Equatable {
  const GiftDataState({
    required this.status,
    required this.recipient,
    required this.confirmRecipient,
    required this.selectedAmount,
    required this.shareStatus,
    required this.amountOptions,
    required this.errorMessage,
    required this.orderReference,
    required this.ineligibleReason,
    required this.amountOptionsFor,
    required this.isCheckingRecipient,
  });

  final GiftDataStatus status;
  final String recipient;
  final String confirmRecipient;
  final GiftAmountOption? selectedAmount;

  /// Snapshot of the sender's data-share quota + window. Null when the
  /// `data-share-status` endpoint hasn't landed yet (or failed quietly).
  final DataShareStatus? shareStatus;

  /// Chip catalog shown in "choose gift amount". Sourced from the
  /// `can-send-data-share` response for the *recipient's* msisdn (not the
  /// sender's) — stays empty until the two recipient fields match and the
  /// per-recipient fetch has returned.
  final List<GiftAmountOption> amountOptions;
  final String? errorMessage;
  final String? orderReference;
  final String? ineligibleReason;

  /// Digits-only key of the recipient number that `amountOptions` was
  /// fetched for. Null when no fetch has completed for the current recipient
  /// — used as a cache check so we don't re-fire the same request.
  final String? amountOptionsFor;

  /// True while `can-send-data-share` is in flight for the recipient.
  final bool isCheckingRecipient;

  factory GiftDataState.initial() => const GiftDataState(
    status: GiftDataStatus.initial,
    recipient: '',
    confirmRecipient: '',
    selectedAmount: null,
    shareStatus: null,
    amountOptions: <GiftAmountOption>[],
    errorMessage: null,
    orderReference: null,
    ineligibleReason: null,
    amountOptionsFor: null,
    isCheckingRecipient: false,
  );

  /// True when the info banner has enough data to render.
  bool get hasShareStatus => shareStatus?.dataShareEndDate != null;

  /// Sender's remaining giftable budget in MB (derived from
  /// `shareStatus.availableToShow`, which the backend reports in GB).
  /// Null when `data-share-status` hasn't loaded.
  int? get availableToShowMb {
    final status = shareStatus;
    if (status == null) return null;
    return (status.availableToShow * 1000).round();
  }

  /// MB left in the sender's gift budget after the current selection.
  /// Null when `data-share-status` hasn't loaded. Clamped to 0 otherwise so
  /// the "remaining data" row never renders negative.
  int? get remainingAfterGiftMb {
    final total = availableToShowMb;
    if (total == null) return null;
    final remaining = total - (selectedAmount?.amountMb ?? 0);
    return remaining < 0 ? 0 : remaining;
  }

  /// True once both recipient fields match and contain a 10-digit number.
  /// Drives the visibility of the recipient-capacity banner.
  bool get isRecipientComplete {
    if (recipient.isEmpty || recipient != confirmRecipient) return false;
    final digits = recipient.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  /// Largest gift amount (in GB) the recipient is eligible to receive,
  /// derived from the catalog loaded via `can-send-data-share` for the
  /// recipient's msisdn. Null when the recipient fetch hasn't completed or
  /// returned no eligible plans.
  double? get maxGiftableGb {
    if (amountOptions.isEmpty) return null;
    return amountOptions
        .map((o) => o.amountGb)
        .reduce((a, b) => a > b ? a : b);
  }

  // Form is valid when: both numbers match + non-empty, an amount is picked,
  // and the picked amount does not exceed the sender's current `AvailableToShow`.
  bool get isFormValid {
    final numbersMatch =
        recipient.isNotEmpty &&
        confirmRecipient.isNotEmpty &&
        recipient == confirmRecipient;
    if (!numbersMatch) return false;
    final amount = selectedAmount;
    if (amount == null) return false;
    final cap = availableToShowMb;
    if (cap != null && amount.amountMb > cap) return false;
    return true;
  }

  bool get isSubmitting => status == GiftDataStatus.submitting;

  GiftDataState copyWith({
    GiftDataStatus? status,
    String? recipient,
    String? confirmRecipient,
    GiftAmountOption? selectedAmount,
    bool clearSelectedAmount = false,
    DataShareStatus? shareStatus,
    bool clearShareStatus = false,
    List<GiftAmountOption>? amountOptions,
    String? errorMessage,
    bool clearError = false,
    String? orderReference,
    String? ineligibleReason,
    bool clearIneligibleReason = false,
    String? amountOptionsFor,
    bool clearAmountOptionsFor = false,
    bool? isCheckingRecipient,
  }) {
    return GiftDataState(
      status: status ?? this.status,
      recipient: recipient ?? this.recipient,
      confirmRecipient: confirmRecipient ?? this.confirmRecipient,
      selectedAmount: clearSelectedAmount
          ? null
          : (selectedAmount ?? this.selectedAmount),
      shareStatus: clearShareStatus ? null : (shareStatus ?? this.shareStatus),
      amountOptions: amountOptions ?? this.amountOptions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      orderReference: orderReference ?? this.orderReference,
      ineligibleReason: clearIneligibleReason
          ? null
          : (ineligibleReason ?? this.ineligibleReason),
      amountOptionsFor: clearAmountOptionsFor
          ? null
          : (amountOptionsFor ?? this.amountOptionsFor),
      isCheckingRecipient: isCheckingRecipient ?? this.isCheckingRecipient,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recipient,
    confirmRecipient,
    selectedAmount,
    shareStatus,
    amountOptions,
    errorMessage,
    orderReference,
    ineligibleReason,
    amountOptionsFor,
    isCheckingRecipient,
  ];
}
