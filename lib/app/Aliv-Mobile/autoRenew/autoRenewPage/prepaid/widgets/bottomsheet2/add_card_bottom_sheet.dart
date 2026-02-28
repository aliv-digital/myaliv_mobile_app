import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../userProfile/addOrEditCards/prepaid/theme/add_or_edit_cards_prepaid_theme.dart';


class AddCardExpiryResult {
  final int month;
  final int year;

  const AddCardExpiryResult({required this.month, required this.year});
}

class AddCardBottomSheet extends StatefulWidget {
  final String last4;

  const AddCardBottomSheet({super.key, required this.last4});

  /// ✅ show helper (returns selected month/year)
  static Future<AddCardExpiryResult?> show(
    BuildContext context, {
    required String last4,
  }) {
    return showModalBottomSheet<AddCardExpiryResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SheetScaffold(child: AddCardBottomSheet(last4: last4)),
    );
  }

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  int _month = DateTime.now().month;
  int _year = DateTime.now().year;

  List<int> get _years {
    final now = DateTime.now().year;
    return List.generate(12, (i) => now + i);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ✅ iOS keyboard safe
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: icon + close
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F0FA),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/Featured icon.svg',
                  ), //const Icon(Icons.credit_card_sharp, color: AddOrEditCardsPrepaidTheme.primary),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(
                    'assets/icons/ic_back_bold.svg',
                    height: 32,
                    width: 32,
                  ),
                  // Container(
                  //   width: 32,
                  //   height: 32,
                  //   decoration: BoxDecoration(
                  //
                  //     border: Border.all(color: const Color(0xFF1F1F1F), width: 2),
                  //     shape: BoxShape.circle,
                  //   ),
                  //   child: const Icon(Icons.close, size: 18, color: Color(0xFF1F1F1F)),
                  // ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'save *${widget.last4} card',
                style: const TextStyle(
                  color: const Color(0xFF222222),
                  fontSize: 18,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'confirm expiration date',
                style: TextStyle(
                  color: const Color(0xFF707070),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _DropField<int>(
                    value: _month,
                    items: List.generate(12, (i) => i + 1),
                    labelBuilder: (m) => _monthLabel(m),
                    onChanged: (v) => setState(() => _month = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropField<int>(
                    value: _year,
                    items: _years,
                    labelBuilder: (y) => y.toString(),
                    onChanged: (v) => setState(() => _year = v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AddOrEditCardsPrepaidTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    AddCardExpiryResult(month: _month, year: _year),
                  );
                },
                child: const Text(
                  'save card',
                  style: TextStyle(
                    color: const Color(0xFFF1F1F8),
                    fontSize: 13,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[(m - 1).clamp(0, 11)];
  }
}

class _SheetScaffold extends StatelessWidget {
  final Widget child;
  const _SheetScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(alignment: Alignment.bottomCenter, child: child),
    );
  }
}

class _DropField<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  const _DropField({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AddOrEditCardsPrepaidTheme.primary,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    labelBuilder(e),
                    style: const TextStyle(
                      color: const Color(0xFF707070),
                      fontSize: 14,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                      height: 1.43,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
