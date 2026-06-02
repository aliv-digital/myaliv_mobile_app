import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/bucket_unit_converter.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plans_expander.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bucket detail bottom sheet — shows full API totals (total / used /
/// remaining) and per-instance expiry rows for a single bucket, plus the
/// shared "your active plans" expander (collapsed by default here; the
/// home screen renders the same widget expanded).
///
/// Renders raw `BucketUsageItem` values, not the plan-group-filtered
/// view-model — the modal is the "see everything for this bucket" surface
/// regardless of which plan group contributed it.
class BucketDetailModal extends StatelessWidget {
  const BucketDetailModal._({required this.bucketName});

  final String bucketName;

  /// Opens the modal as a bottom sheet for [bucketName]. The bucket name
  /// is matched case-insensitively against `BucketUsageItem.freeUnitTypeName`.
  static Future<void> show(BuildContext context, String bucketName) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => BucketDetailModal._(bucketName: bucketName),
    );
  }

  /// Same external-launch + toast-fallback path as
  /// `HomePlanAddOnsTabContent._openFairUsePolicy`, so users see one
  /// consistent fair-use experience across the app.
  static final Uri _fairUsePolicyUri =
      Uri.parse('https://www.bealiv.com/fair-use-policy/');

  Future<void> _openFairUsePolicy() async {
    try {
      final launched = await launchUrl(
        _fairUsePolicyUri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return;
    } catch (_) {
      // launchUrl can throw PlatformException when no handler is
      // installed for the URI scheme — fall through to the toast.
    }
    AppToast.show(
      message: 'could not open fair use policy',
      type: ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF1F7FA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
            buildWhen: (a, b) =>
                a.summary != b.summary || a.activePlans != b.activePlans,
            builder: (context, state) {
              final item = _findItem(state.items, bucketName);
              final isUnlimited = _resolveIsUnlimited(state, bucketName);
              return _body(context, scrollController, item, isUnlimited);
            },
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    ScrollController scrollController,
    BucketUsageItem? item,
    bool isUnlimited,
  ) {
    return Column(
      children: [
        _titleBar(context),
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No details available for this bucket.',
                        style: TextStyle(
                          color: Color(0xFF707070),
                          fontFamily: 'CircularPro',
                        ),
                      ),
                    ),
                  )
                else ...[
                  _detailsCard(item, isUnlimited),
                  const SizedBox(height: 16),
                  _expireDatesCard(item, isUnlimited),
                ],
                const SizedBox(height: 16),
                const ActivePlansExpander(initiallyExpanded: false),
                const SizedBox(height: 20),
                _fairUseLink(),
                const SizedBox(height: 12),
                _closeButton(context),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _titleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              bucketName.toLowerCase(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 22, color: Color(0xFF222222)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: const BorderSide(color: Color(0xFFE4E6EC)),
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(BucketUsageItem item, bool isUnlimited) {
    final unit = item.displayUnitLabelText;
    String fmt(double amount) =>
        isUnlimited ? 'unlimited' : formatBucketAmount(amount, unit);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.list_alt_outlined,
            label: 'details',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _metricBox(
                  label: 'total',
                  value: fmt(item.displayInitialAmount),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricBox(
                  label: 'used',
                  value: fmt(item.displayUsedAmount),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _metricBox(
            label: 'remaining',
            value: fmt(item.displayUnusedAmount),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFF707070),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Color(0xFF222222),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expireDatesCard(BucketUsageItem item, bool isUnlimited) {
    final rows = _sortedRows(item, isUnlimited);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // will work on it
          const Text(
            'expire dates',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: rows.isEmpty
                ? const Text(
                    'no expiry details available.',
                    style: TextStyle(
                      color: Color(0xFF707070),
                      fontSize: 13,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final row in rows)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            row,
                            style: const TextStyle(
                              color: Color(0xFF222222),
                              fontSize: 13,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _fairUseLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: _openFairUsePolicy,
        borderRadius: BorderRadius.circular(4),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'fair use policy',
            style: TextStyle(
              color: Color(0xFF645D9C),
              fontSize: 13,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF645D9C),
            ),
          ),
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF645D9C),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: const Text(
          'close',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Locate the matching `BucketUsageItem` for [name] using normalized
  /// (lowercased, trimmed) `freeUnitTypeName` equality so casing/spacing
  /// drift between plan declarations and API responses doesn't break the
  /// lookup. Returns null when nothing matches.
  BucketUsageItem? _findItem(List<BucketUsageItem> items, String name) {
    final target = name.trim().toLowerCase();
    if (target.isEmpty) return null;
    for (final item in items) {
      if (item.freeUnitTypeName.trim().toLowerCase() == target) return item;
    }
    return null;
  }

  /// Each row in the expire-dates list shows the per-instance current
  /// balance + human-formatted expiry. `currentAmount` is exact when
  /// nothing has been consumed from the instance; it drifts toward zero
  /// as the user spends down the allowance (the API does not expose the
  /// per-instance initial separately, so this is the closest signal).
  /// Rows are ordered earliest-expiring first for at-a-glance triage.
  List<String> _sortedRows(BucketUsageItem item, bool isUnlimited) {
    final details = [...item.nestedDetails];
    details.sort((a, b) {
      final aTime = a.expireDateTime;
      final bTime = b.expireDateTime;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return aTime.compareTo(bTime);
    });

    final unit = item.displayUnitLabelText;
    return [
      for (final detail in details)
        '${isUnlimited ? 'unlimited' : formatBucketAmount(toDisplayUnit(detail.currentAmount, item.unitType), unit)} '
            'expires ${_formatExpiry(detail.expireDateTime)}',
    ];
  }

  /// Looks up `isUnlimited` for [name] from the cubit's per-plan view-models.
  /// Checks active plan buckets first, then roaming. Falls back to `false`.
  bool _resolveIsUnlimited(BucketUsageSummaryState state, String name) {
    final target = name.trim().toLowerCase();
    if (target.isEmpty) return false;
    for (final usage in state.activePlanBucketUsage) {
      if (usage.bucketName.trim().toLowerCase() == target) {
        return usage.isUnlimited;
      }
    }
    for (final usage in state.roamingPlanBucketUsage) {
      if (usage.bucketName.trim().toLowerCase() == target) {
        return usage.isUnlimited;
      }
    }
    return false;
  }

  String _formatExpiry(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('EEEE, MMMM d, yyyy h:mm a').format(date).toLowerCase();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF645D9C)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
