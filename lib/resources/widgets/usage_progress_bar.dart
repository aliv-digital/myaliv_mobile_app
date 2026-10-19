import 'package:flutter/material.dart';

/// Background + fill colour pair for a usage / roaming progress bar.
class UsageBarStyle {
  const UsageBarStyle({required this.fill, required this.background});
  final Color fill;
  final Color background;
}

const Color _green = Color(0xFF17B26A);
const Color _yellow = Color(0xFFFFC627);
const Color _red = Color(0xFFDD3038);
const Color _greenBg = Color(0x2617B26A);
const Color _yellowBg = Color(0x26FFC627);
const Color _redBg = Color(0x26DD3038);

/// Resolves the bar palette from the bucket's user type and used fraction.
///
/// Shared by Home `UsageCard` / `RoamingCard` and the Usage tab's
/// `UsageLimitRow` so palette decisions can't drift between surfaces.
/// Fill direction (used-vs-remaining) is left to each caller — Home cards
/// fill to remaining, the Usage tab row fills to used to match its
/// `"N% used"` label.
///
/// Prepaid → solid green. Postpaid (metered) escalates green → yellow → red
/// at >50% / >80% used. Unlimited stays green regardless of user type so
/// the "unlimited" label isn't fighting a red bar.
UsageBarStyle resolveUsageBarStyle({
  required bool isPostpaid,
  required double progressUsed,
  required bool isUnlimited,
}) {
  if (!isPostpaid || isUnlimited) {
    return const UsageBarStyle(fill: _green, background: _greenBg);
  }
  final usedPercent = (progressUsed.clamp(0.0, 1.0) * 100).round();
  if (usedPercent > 80) {
    return const UsageBarStyle(fill: _red, background: _redBg);
  }
  if (usedPercent > 50) {
    return const UsageBarStyle(fill: _yellow, background: _yellowBg);
  }
  return const UsageBarStyle(fill: _green, background: _greenBg);
}
