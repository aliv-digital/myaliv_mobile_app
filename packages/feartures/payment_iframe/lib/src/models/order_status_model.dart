import 'dart:convert';

/// Minimal projection of the `GET MyAliv/Order?orderId=` response.
///
/// Only [orderId] and [orderStatus] are needed to determine payment outcome.
/// The full `OrderData` nested payload is intentionally ignored.
class OrderStatusModel {
  const OrderStatusModel({
    required this.orderId,
    required this.orderStatus,
  });

  final int orderId;

  /// Raw value from the API, e.g. `"Completed"`, `"New"`, `"Failed"`.
  final String orderStatus;

  bool get isCompleted => orderStatus.toLowerCase() == 'completed';

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      orderId: (json['OrderId'] as num?)?.toInt() ?? 0,
      orderStatus: (json['OrderStatus'] as String?) ?? '',
    );
  }

  static OrderStatusModel parse(dynamic data) {
    Map<String, dynamic>? map;

    if (data is Map<String, dynamic>) {
      map = data;
    } else if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) map = decoded;
      } catch (_) {}
    }

    if (map == null) throw const FormatException('Not a valid JSON object');
    return OrderStatusModel.fromJson(map);
  }
}
