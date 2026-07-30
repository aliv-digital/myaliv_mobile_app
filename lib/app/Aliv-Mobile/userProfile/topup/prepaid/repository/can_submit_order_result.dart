import 'package:equatable/equatable.dart';

/// Response for GET /Account/can-submit-order.
///
/// Backend always returns HTTP 200. Distinguish OK vs blocked by the `Info`
/// field: empty string → OK, non-empty → blocked with human-readable copy
/// meant to be displayed as-is (e.g. "Order # 12234 is in progress for # …").
class CanSubmitOrderResult extends Equatable {
  static const pendingOrdersMessage = 'You have pending or failed orders. '
      'Please wait for the open orders to complete '
      'before sending another request.';

  final String infoMessage;

  const CanSubmitOrderResult(this.infoMessage);

  factory CanSubmitOrderResult.fromJson(Map<String, dynamic> json) {
    return CanSubmitOrderResult((json['Info'] as String?) ?? '');
  }

  bool get canProceed => infoMessage.isEmpty;

  @override
  List<Object?> get props => [infoMessage];
}
