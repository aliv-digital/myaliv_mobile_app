import 'package:flutter/painting.dart';

/// Shared sizing for every radio-style payment row on `TopUpPaymentScreen`.
///
/// Mirrors the metrics used by `HomePlansPaymentMethodTile` so the saved-card
/// tiles and the "pay with card" tile read as one consistent radio group on
/// both screens.
class TopUpPaymentRadioMetrics {
  TopUpPaymentRadioMetrics._();

  static const double tileRadius = 10;
  static const double radioSize = 16;
  static const double logoBoxWidth = 46;
  static const double logoBoxHeight = 32;
  static const Color unselectedRadioFill = Color(0xFFE0E0E0);
}
