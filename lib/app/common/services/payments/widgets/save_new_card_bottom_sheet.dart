import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

/// Bottom sheet that collects an expiration date (month + year) and calls
/// POST /CreditCard/savenew with the supplied 3DS [orderId].
///
/// Returns `true` via `Navigator.pop` on success so the receipt section can
/// hide the button after a single successful save.
class SaveNewCardBottomSheet extends StatefulWidget {
  const SaveNewCardBottomSheet._({required this.orderId});

  final String orderId;

  static Future<bool?> show(BuildContext context, {required String orderId}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveNewCardBottomSheet._(orderId: orderId),
    );
  }

  @override
  State<SaveNewCardBottomSheet> createState() => _SaveNewCardBottomSheetState();
}

class _SaveNewCardBottomSheetState extends State<SaveNewCardBottomSheet> {
  static const Color _primary = Color(0xFF645D9C);
  static const Color _dropdownBg = Color(0xFFF5F4F8);

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  late int _selectedMonth;
  late int _selectedYear;
  late final ValueNotifier<int> _monthNotifier;
  late final ValueNotifier<int> _yearNotifier;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _monthNotifier = ValueNotifier<int>(_selectedMonth);
    _yearNotifier = ValueNotifier<int>(_selectedYear);
  }

  @override
  void dispose() {
    _monthNotifier.dispose();
    _yearNotifier.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final orderId = int.tryParse(widget.orderId);
    if (orderId == null) {
      AppToast.show(message: 'Invalid order ID.', type: ToastType.error);
      return;
    }

    final mm = _selectedMonth.toString().padLeft(2, '0');
    final yy = (_selectedYear % 100).toString().padLeft(2, '0');
    final expirationDate = '$mm$yy';

    final cubit = instance<SavedCardsCubit>();
    final ok = await cubit.saveNewCard(
      orderId: orderId,
      expirationDate: expirationDate,
    );

    if (!mounted) return;

    if (ok) {
      AppToast.show(
        message: 'your card has been saved successfully',
        type: ToastType.success,
      );
      Navigator.of(context).pop(true);
    } else {
      final msg = cubit.state.errorMessage?.trim();
      AppToast.show(
        message: (msg == null || msg.isEmpty) ? 'Failed to save card. Try again.' : msg,
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;
    final years = List.generate(26, (i) => currentYear + i);

    return BlocProvider<SavedCardsCubit>.value(
      value: instance<SavedCardsCubit>(),
      child: BlocBuilder<SavedCardsCubit, SavedCardsState>(
        buildWhen: (p, c) => p.isAddingCard != c.isAddingCard,
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        color: _primary,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD0D5DD)),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF344054),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'save card',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F1F),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'confirm expiration date',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7E7E8A),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _buildMonthDropdown(_monthNames),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildYearDropdown(years),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 46,
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
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'save card',
                            style: TextStyle(
                              fontFamily: 'CircularPro',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthDropdown(List<String> monthNames) {
    return DropdownButton2<int>(
      valueListenable: _monthNotifier,
      items: List.generate(
        12,
        (i) => DropdownItem<int>(
          value: i + 1,
          height: 44,
          child: Text(
            monthNames[i],
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      onChanged: (v) {
        if (v != null) {
          setState(() => _selectedMonth = v);
          _monthNotifier.value = v;
        }
      },
      style: const TextStyle(
        fontFamily: 'CircularPro',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F1F1F),
      ),
      buttonStyleData: ButtonStyleData(
        decoration: BoxDecoration(
          color: _dropdownBg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 48,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        maxHeight: 260,
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF645D9C)),
      ),
    );
  }

  Widget _buildYearDropdown(List<int> years) {
    return DropdownButton2<int>(
      valueListenable: _yearNotifier,
      items: years
          .map(
            (y) => DropdownItem<int>(
              value: y,
              height: 44,
              child: Text(
                y.toString(),
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() => _selectedYear = v);
          _yearNotifier.value = v;
        }
      },
      style: const TextStyle(
        fontFamily: 'CircularPro',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F1F1F),
      ),
      buttonStyleData: ButtonStyleData(
        decoration: BoxDecoration(
          color: _dropdownBg,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 48,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        maxHeight: 260,
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(Icons.keyboard_arrow_down, color: Color(0xFF645D9C)),
      ),
    );
  }
}
