import 'package:flutter/material.dart';

/// Presentation-only helpers shared by widgets that render
/// `PlanBucketUsage` rows (home active-plan section, Usage current-plan tab,
/// etc.). Pure formatting + classification — no Flutter widget code, no BLoC.

/// Heuristic: roaming buckets carry "roam" in their name (e.g. "Roaming
/// Data", "RoamEasy"). When the API contract is finalized this can be
/// tightened to an exact match list.
bool isRoamingBucket(String bucketName) {
  return bucketName.toLowerCase().contains('roam');
}

/// Formats `value unit` (e.g. "2.4 GB", "30 mins"). Whole numbers drop the
/// decimal; fractional values are kept to one decimal place. Returns the
/// numeric part alone when [unit] is empty.
String formatBucketAmount(double value, String unit) {
  final formatted = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
  if (unit.isEmpty) return formatted;
  return '$formatted $unit';
}

/// Icon path + accent color for a bucket name. Case-insensitive contains
/// matching keeps it resilient to API casing or minor naming variants.
BucketCardStyle styleForBucket(String bucketName) {
  final normalized = bucketName.trim().toLowerCase();
  if (normalized.contains('data')) {
    return const BucketCardStyle(
      icon: 'assets/icons/Rss.svg',
      color: Color(0xFFFF6C36),
    );
  }
  if (normalized.contains('voice') ||
      normalized.contains('talk') ||
      normalized.contains('minute') ||
      normalized.contains('mins')) {
    return const BucketCardStyle(
      icon: 'assets/icons/phone_call.svg',
      color: Color(0xFF00B3E3),
    );
  }
  if (normalized.contains('sms') || normalized.contains('text')) {
    return const BucketCardStyle(
      icon: 'assets/icons/message.svg',
      color: Color(0xFF5045A7),
    );
  }
  return const BucketCardStyle(
    icon: 'assets/icons/Rss.svg',
    color: Color(0xFF707070),
  );
}

class BucketCardStyle {
  const BucketCardStyle({required this.icon, required this.color});
  final String icon;
  final Color color;
}
