import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_state.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/transactions_cubit.dart';

/// Shared month selector dropdown for both tabs
class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallLogsCubit, CallLogsState>(
      buildWhen: (prev, curr) => prev.selectedMonth != curr.selectedMonth,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => _showMonthPicker(context, state),
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                const Icon(Icons.calendar_today, size: 14),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy').format(state.currentMonth),
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset('assets/icons/CHEVRON-DOWN.svg'),
                const SizedBox(width: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMonthPicker(BuildContext context, CallLogsState state) {
    final callLogsCubit = context.read<CallLogsCubit>();
    final transactionsCubit = context.read<TransactionsCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => _MonthPickerSheet(
        availableMonths: state.availableMonths,
        selectedMonth: state.currentMonth,
        onSelect: (month) {
          // Update both cubits with same month
          callLogsCubit.selectMonth(month);
          transactionsCubit.selectMonth(month);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }
}

class _MonthPickerSheet extends StatelessWidget {
  final List<DateTime> availableMonths;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onSelect;

  const _MonthPickerSheet({
    required this.availableMonths,
    required this.selectedMonth,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Select Month',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: availableMonths.length,
              itemBuilder: (_, index) {
                final month = availableMonths[index];
                final isSelected = _isSameMonth(month, selectedMonth);
                return ListTile(
                  title: Text(
                    DateFormat('MMMM yyyy').format(month),
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? const Color(0xFF645D9C) : null,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF645D9C))
                      : null,
                  onTap: () => onSelect(month),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
