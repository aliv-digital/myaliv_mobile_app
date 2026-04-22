import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/theme/review_invoice_postpaid_theme.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton placeholder for InvoiceTile while loading.
class InvoiceTileSkeleton extends StatelessWidget {
  const InvoiceTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ReviewInvoicePostpaidTheme.radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBox(width: 100, height: 16),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetaBlock(labelWidth: 70, valueWidth: 80),
                      const SizedBox(width: 16),
                      _buildMetaBlock(labelWidth: 50, valueWidth: 80),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBox(width: 32, height: 32),
                const SizedBox(height: 14),
                _buildBox(width: 60, height: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildMetaBlock({
    required double labelWidth,
    required double valueWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBox(width: labelWidth, height: 10),
        const SizedBox(height: 4),
        _buildBox(width: valueWidth, height: 12),
      ],
    );
  }
}

/// A list of skeleton tiles for loading state.
class InvoiceTileSkeletonList extends StatelessWidget {
  final int itemCount;

  const InvoiceTileSkeletonList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const InvoiceTileSkeleton(),
    );
  }
}
