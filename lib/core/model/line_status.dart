enum LineStatus {
  active('AC'),
  suspended('SU'),
  disconnected('DC'),
  pendingDisconnect('PF'),
  callBarred('CB'),
  closed('CL'),
  unknown('');

  const LineStatus(this.code);
  final String code;

  static LineStatus fromCode(String? raw) => LineStatus.values.firstWhere(
        (s) => s.code == (raw ?? '').trim().toUpperCase(),
        orElse: () => LineStatus.unknown,
      );

  bool get isActive => this == LineStatus.active;

  /// Terminal states — line is gone, not merely restricted.
  bool get isTerminal => this == disconnected || this == closed;

  /// Restricted but recoverable.
  bool get isRestricted =>
      this == suspended || this == callBarred || this == pendingDisconnect;

  String get displayLabel => switch (this) {
        LineStatus.active => 'active',
        LineStatus.suspended => 'suspended',
        LineStatus.disconnected => 'disconnected',
        LineStatus.pendingDisconnect => 'pending disconnect',
        LineStatus.callBarred => 'call barred',
        LineStatus.closed => 'closed',
        LineStatus.unknown => 'unknown',
      };
}
