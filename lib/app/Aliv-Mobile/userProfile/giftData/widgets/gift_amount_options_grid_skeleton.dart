import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer placeholder shown in place of "choose gift amount" chips while
/// the recipient's `can-send-data-share` request is in flight. Mirrors the
/// 3-column × 2-row layout of `_AmountOptionsGrid` so the final chips drop
/// into the exact same footprint when the response arrives.
class GiftAmountOptionsGridSkeleton extends StatelessWidget {
  const GiftAmountOptionsGridSkeleton({super.key});

  static const int _columns = 3;
  static const int _rows = 2;
  static const double _hGap = 10;
  static const double _vGap = 10;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final chipWidth = (pageWidth - _hGap * (_columns - 1)) / _columns;

        final rows = <Widget>[];
        for (var row = 0; row < _rows; row++) {
          if (rows.isNotEmpty) rows.add(const SizedBox(height: _vGap));
          final cells = <Widget>[];
          for (var col = 0; col < _columns; col++) {
            if (col > 0) cells.add(const SizedBox(width: _hGap));
            cells.add(SizedBox(width: chipWidth, child: _ChipPlaceholder()));
          }
          rows.add(Row(children: cells));
        }

        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          ),
        );
      },
    );
  }
}

class _ChipPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: GiftDataTheme.fieldHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GiftDataTheme.fieldRadius),
      ),
    );
  }
}
