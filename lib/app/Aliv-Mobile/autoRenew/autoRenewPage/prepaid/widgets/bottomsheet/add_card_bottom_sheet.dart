import 'package:flutter/material.dart';
import '../../theme/auto_renew_prepaid_theme.dart';

class AddCardExpiryResult {
  final int month;
  final int year;

  const AddCardExpiryResult({required this.month, required this.year});
}

class AddCardBottomSheet extends StatefulWidget {
  const AddCardBottomSheet({super.key});

  static Future<AddCardExpiryResult?> show(BuildContext context) {
    return showModalBottomSheet<AddCardExpiryResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutoRenewPrepaidTheme.sheetBg,
      shape: AutoRenewPrepaidTheme.sheetShape(),
      builder: (_) => const AddCardBottomSheet(),
    );
  }

  @override
  State<AddCardBottomSheet> createState() => _AddCardBottomSheetState();
}

class _AddCardBottomSheetState extends State<AddCardBottomSheet> {
  int _month = 6;
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: AutoRenewPrepaidTheme.addCardBottomSheetPadding.copyWith(
          bottom: AutoRenewPrepaidTheme.addCardBottomSheetBottomBase + bottom),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AutoRenewPrepaidTheme.dragHandleWidth,
              height: AutoRenewPrepaidTheme.dragHandleHeight,
              decoration: BoxDecoration(
                color: AutoRenewPrepaidTheme.dragHandle,
                borderRadius: BorderRadius.circular(
                  AutoRenewPrepaidTheme.dragHandleRadius,
                ),
              ),
            ),
            const SizedBox(height: AutoRenewPrepaidTheme.bottomSheetTitleGap),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'add card expiry',
                style: AutoRenewPrepaidTheme.addCardSheetTitleStyle,
              ),
            ),
            const SizedBox(height: AutoRenewPrepaidTheme.bottomSheetFieldsGap),
            Row(
              children: [
                Expanded(
                  child: _Dropdown<int>(
                    value: _month,
                    items: List.generate(12, (i) => i + 1),
                    label: 'month',
                    onChanged: (v) => setState(() => _month = v),
                  ),
                ),
                const SizedBox(width: AutoRenewPrepaidTheme.bottomSheetFieldsGap),
                Expanded(
                  child: _Dropdown<int>(
                    value: _year,
                    items: List.generate(10, (i) => DateTime.now().year + i),
                    label: 'year',
                    onChanged: (v) => setState(() => _year = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AutoRenewPrepaidTheme.bottomSheetButtonTopGap),
            SizedBox(
              height: AutoRenewPrepaidTheme.bottomSheetActionHeight,
              width: double.infinity,
              child: ElevatedButton(
                style: AutoRenewPrepaidTheme.primaryPillButtonStyle(
                  backgroundColor: AutoRenewPrepaidTheme.primary,
                ),
                onPressed: () {
                  Navigator.of(context).pop(
                    AddCardExpiryResult(month: _month, year: _year),
                  );
                },
                child: const Text(
                  'save',
                  style: AutoRenewPrepaidTheme.addCardSheetSaveStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String label;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: AutoRenewPrepaidTheme.dropdownInputDecoration(label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text('$e',
                      style: AutoRenewPrepaidTheme.dropdownItemStyle),
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
