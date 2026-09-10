import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class SaveNewCardBottomSheet extends StatefulWidget {
  const SaveNewCardBottomSheet({super.key, required this.orderId});

  final String orderId;

  static Future<bool?> show(BuildContext context, {required String orderId}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider<SavedCardsCubit>.value(
        value: instance<SavedCardsCubit>(),
        child: SaveNewCardBottomSheet(orderId: orderId),
      ),
    );
  }

  @override
  State<SaveNewCardBottomSheet> createState() => _SaveNewCardBottomSheetState();
}

class _SaveNewCardBottomSheetState extends State<SaveNewCardBottomSheet> {
  static const Color _primary = Color(0xFF645D9C);
  static const Color _iconBg = Color(0xFFEDE9F9);
  static const Color _dropdownBg = Color(0xFFF5F4F8);
  static const Color _labelColor = Color(0xFF8E8E9A);
  static const Color _titleColor = Color(0xFF1A1A2E);
  static const Color _chevronColor = Color(0xFF5A5A6E);
  static const Color _closeBorderColor = Color(0xFFD0CDD7);

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December',
  ];

  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
  }

  List<int> get _years {
    final current = DateTime.now().year;
    return List.generate(21, (i) => current + i);
  }

  String get _expirationDate {
    final mm = _selectedMonth.toString().padLeft(2, '0');
    final yy = (_selectedYear % 100).toString().padLeft(2, '0');
    return '$mm$yy';
  }

  Future<void> _onSave() async {
    final orderId = int.tryParse(widget.orderId);
    if (orderId == null) return;

    final cubit = instance<SavedCardsCubit>();
    final ok = await cubit.saveNewCard(
      orderId: orderId,
      expirationDate: _expirationDate,
    );

    if (!mounted) return;

    if (ok) {
      AppToast.show(
        message: 'your card has been saved successfully',
        type: ToastType.success,
      );
      Navigator.of(context).pop(true);
      return;
    }

    final msg = cubit.state.errorMessage?.trim();
    AppToast.show(
      message: (msg == null || msg.isEmpty)
          ? 'Failed to save card. Try again.'
          : msg,
      type: ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: card icon + close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.credit_card, color: _primary, size: 24),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _closeBorderColor, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: _chevronColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'save card',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'CircularPro',
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'confirm expiration date',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'CircularPro',
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 20),
          // Month / Year dropdowns
          Row(
            children: [
              Expanded(child: _buildMonthDropdown()),
              const SizedBox(width: 12),
              Expanded(child: _buildYearDropdown()),
            ],
          ),
          const SizedBox(height: 24),
          // Save button
          BlocBuilder<SavedCardsCubit, SavedCardsState>(
            buildWhen: (p, c) => p.isAddingCard != c.isAddingCard,
            builder: (context, state) {
              return SizedBox(
                height: 46,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isAddingCard ? null : _onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: state.isAddingCard
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'save card',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'CircularPro',
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return DropdownButton2<int>(
      valueListenable: ValueNotifier<int>(_selectedMonth),
      isExpanded: true,
      underline: const SizedBox.shrink(),
      buttonStyleData: ButtonStyleData(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _dropdownBg,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _chevronColor,
        ),
        iconSize: 22,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
      items: List.generate(
        12,
        (i) => DropdownItem<int>(
          value: i + 1,
          height: 44,
          child: Text(
            _monthNames[i],
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      onChanged: (v) {
        if (v != null) setState(() => _selectedMonth = v);
      },
    );
  }

  Widget _buildYearDropdown() {
    final years = _years;
    return DropdownButton2<int>(
      valueListenable: ValueNotifier<int>(_selectedYear),
      isExpanded: true,
      underline: const SizedBox.shrink(),
      buttonStyleData: ButtonStyleData(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _dropdownBg,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _chevronColor,
        ),
        iconSize: 22,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
      items: years
          .map(
            (y) => DropdownItem<int>(
              value: y,
              height: 44,
              child: Text(
                y.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => _selectedYear = v);
      },
    );
  }
}
