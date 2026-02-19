class PostpaidUsageItem {
  final String title;
  final String subtitle;      // "2.4 GB of 15 GB"
  final String trailingText;  // "25% used" / "unlimited"
  final double? progress;     // null = no progress bar
  final bool isUnlimited;

  PostpaidUsageItem({
    required this.title,
    required this.subtitle,
    required this.trailingText,
    this.progress,
    this.isUnlimited = false,
  });
}
