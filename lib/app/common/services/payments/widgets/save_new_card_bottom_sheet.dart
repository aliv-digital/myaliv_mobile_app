import 'package:core/core.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

import '../theme/save_card_sheet_theme.dart';
import 'save_card_sheet_content.dart';

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

  /// Shows the expiry picker UI and returns the selected date as a "MMYY"
  /// string when the user confirms, or null when dismissed.
  /// The caller is responsible for the POST /CreditCard/savenew call.
  ///
  /// [rejectPastExpiry] (CARD-002) blocks an already-expired month/year with
  /// an inline error; it is opt-in so other callers keep their behaviour.
  static Future<String?> showForExpiryCapture(
    BuildContext context, {
    bool rejectPastExpiry = false,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _SaveNewCardExpiryPicker(rejectPastExpiry: rejectPastExpiry),
    );
  }

  @override
  State<SaveNewCardBottomSheet> createState() => _SaveNewCardBottomSheetState();
}

class _SaveNewCardBottomSheetState extends State<SaveNewCardBottomSheet> {
  static const List<String> _monthNames = [
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
        message: (msg == null || msg.isEmpty)
            ? 'Failed to save card. Try again.'
            : msg,
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
          return SaveCardSheetContent(
            monthDropdown: _buildMonthDropdown(_monthNames),
            yearDropdown: _buildYearDropdown(years),
            onSave: _onSave,
            isSaving: state.isAddingCard,
          );
        },
      ),
    );
  }

  Widget _buildMonthDropdown(List<String> monthNames) {
    return SaveCardExpiryDropdown(
      valueListenable: _monthNotifier,
      items: List.generate(
        12,
        (i) => DropdownItem<int>(
          value: i + 1,
          height: 44,
          child: Text(monthNames[i], style: SaveCardSheetTheme.fieldText),
        ),
      ),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedMonth = value);
          _monthNotifier.value = value;
        }
      },
    );
  }

  Widget _buildYearDropdown(List<int> years) {
    return SaveCardExpiryDropdown(
      valueListenable: _yearNotifier,
      items: years
          .map(
            (year) => DropdownItem<int>(
              value: year,
              height: 44,
              child: Text(year.toString(), style: SaveCardSheetTheme.fieldText),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedYear = value);
          _yearNotifier.value = value;
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Expiry-capture-only variant — same UI, no API call.
// Returns the selected "MMYY" string via Navigator.pop when confirmed.
// ---------------------------------------------------------------------------

class _SaveNewCardExpiryPicker extends StatefulWidget {
  const _SaveNewCardExpiryPicker({this.rejectPastExpiry = false});

  final bool rejectPastExpiry;

  @override
  State<_SaveNewCardExpiryPicker> createState() =>
      _SaveNewCardExpiryPickerState();
}

class _SaveNewCardExpiryPickerState extends State<_SaveNewCardExpiryPicker> {
  static const List<String> _monthNames = [
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

  late int _selectedMonth;
  late int _selectedYear;
  late final ValueNotifier<int> _monthNotifier;
  late final ValueNotifier<int> _yearNotifier;

  /// CARD-002: set when confirm is tapped with an expired month/year.
  bool _showExpiryError = false;

  /// A card stays valid through the end of its expiry month.
  bool get _isPastExpiry {
    final now = DateTime.now();
    return _selectedYear < now.year ||
        (_selectedYear == now.year && _selectedMonth < now.month);
  }

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

  void _onConfirm() {
    if (widget.rejectPastExpiry && _isPastExpiry) {
      setState(() => _showExpiryError = true);
      return;
    }
    final mm = _selectedMonth.toString().padLeft(2, '0');
    final yy = (_selectedYear % 100).toString().padLeft(2, '0');
    Navigator.of(context).pop('$mm$yy');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final years = List.generate(26, (i) => now.year + i);

    return SaveCardSheetContent(
      monthDropdown: _buildMonthDropdown(),
      yearDropdown: _buildYearDropdown(years),
      onSave: _onConfirm,
      errorMessage: _showExpiryError && _isPastExpiry
          ? 'enter a valid expiry date'
          : null,
    );
  }

  Widget _buildMonthDropdown() {
    return SaveCardExpiryDropdown(
      valueListenable: _monthNotifier,
      items: List.generate(
        12,
        (i) => DropdownItem<int>(
          value: i + 1,
          height: 44,
          child: Text(_monthNames[i], style: SaveCardSheetTheme.fieldText),
        ),
      ),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedMonth = value);
          _monthNotifier.value = value;
        }
      },
    );
  }

  Widget _buildYearDropdown(List<int> years) {
    return SaveCardExpiryDropdown(
      valueListenable: _yearNotifier,
      items: years
          .map(
            (year) => DropdownItem<int>(
              value: year,
              height: 44,
              child: Text(year.toString(), style: SaveCardSheetTheme.fieldText),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedYear = value);
          _yearNotifier.value = value;
        }
      },
    );
  }
}
