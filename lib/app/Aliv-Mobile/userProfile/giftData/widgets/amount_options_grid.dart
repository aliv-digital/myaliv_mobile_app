import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_amount_option_chip.dart';

/// 3-column × 2-row page of amount chips, with horizontal paging when the
/// catalog exceeds 6 items. Each page fills exactly the available horizontal
/// space (chip width = (pageWidth - 2 * hGap) / 3); additional pages scroll
/// into view via a horizontal `SingleChildScrollView`. Partially filled pages
/// (e.g. 3 items on page 1, bottom row empty) keep chip widths consistent by
/// inserting fixed-width `SizedBox.shrink()` placeholders.
class AmountOptionsGrid extends StatelessWidget {
  const AmountOptionsGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.isEnabled,
    required this.onSelected,
  });

  static const int _columns = 3;
  static const int _rows = 2;
  static const int _itemsPerPage = _columns * _rows;
  static const double _hGap = 10;
  static const double _vGap = 10;

  final List<GiftAmountOption> options;
  final GiftAmountOption? selected;
  final bool Function(int amountMb) isEnabled;
  final ValueChanged<GiftAmountOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = constraints.maxWidth;
        final chipWidth = (pageWidth - _hGap * (_columns - 1)) / _columns;
        final pageCount = (options.length / _itemsPerPage).ceil().clamp(
          1,
          1 << 30,
        );
        final canScroll = options.length > _itemsPerPage;

        final children = <Widget>[];
        for (var page = 0; page < pageCount; page++) {
          if (children.isNotEmpty) children.add(const SizedBox(width: _hGap));
          children.add(_buildPage(page, chipWidth, pageWidth));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: canScroll
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Row(children: children),
        );
      },
    );
  }

  Widget _buildPage(int page, double chipWidth, double pageWidth) {
    final rows = <Widget>[];
    for (var row = 0; row < _rows; row++) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: _vGap));
      final cells = <Widget>[];
      for (var col = 0; col < _columns; col++) {
        if (col > 0) cells.add(const SizedBox(width: _hGap));
        final i = page * _itemsPerPage + row * _columns + col;
        cells.add(SizedBox(width: chipWidth, child: _cell(i)));
      }
      rows.add(Row(children: cells));
    }
    return SizedBox(
      width: pageWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: rows,
      ),
    );
  }

  Widget _cell(int index) {
    if (index >= options.length) return const SizedBox.shrink();
    final option = options[index];
    return GiftAmountOptionChip(
      label: option.label,
      selected: selected == option,
      enabled: isEnabled(option.amountMb),
      onTap: () => onSelected(option),
    );
  }
}
