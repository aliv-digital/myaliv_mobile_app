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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 18 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'add card expiry',
              style: TextStyle(
                fontFamily: AutoRenewPrepaidTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AutoRenewPrepaidTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _Dropdown<int>(
                value: _month,
                items: List.generate(12, (i) => i + 1),
                label: 'month',
                onChanged: (v) => setState(() => _month = v),
              )),
              const SizedBox(width: 12),
              Expanded(child: _Dropdown<int>(
                value: _year,
                items: List.generate(10, (i) => DateTime.now().year + i),
                label: 'year',
                onChanged: (v) => setState(() => _year = v),
              )),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AutoRenewPrepaidTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop(AddCardExpiryResult(month: _month, year: _year));
              },
              child: const Text(
                'save',
                style: TextStyle(
                  fontFamily: AutoRenewPrepaidTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
