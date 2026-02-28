import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Bottom sheet used to confirm the card expiration date before saving card.
class HomePlanPurchaseReceiptSaveCardBottomSheet extends StatefulWidget {
  const HomePlanPurchaseReceiptSaveCardBottomSheet({
    super.key,
    this.cardMask = '*1234',
    this.initialMonth = 'January',
    this.initialYear = '2025',
  });

  final String cardMask;
  final String initialMonth;
  final String initialYear;

  @override
  State<HomePlanPurchaseReceiptSaveCardBottomSheet> createState() =>
      _HomePlanPurchaseReceiptSaveCardBottomSheetState();
}

class _HomePlanPurchaseReceiptSaveCardBottomSheetState
    extends State<HomePlanPurchaseReceiptSaveCardBottomSheet> {
  // Sheet spacing from design:
  // - 16 left/right padding
  // - 24 top/bottom padding
  // - 20 vertical gaps between major sections
  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 24;
  static const double _sectionGap = 20;
  static const double _dropdownHeight = 48;
  static const double _dropdownTextLeftPadding = 16;
  static const double _dropdownRightPadding = 8;
  static const double _dropdownArrowSize = 20;

  static const List<String> _months = <String>[
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

  static const List<String> _years = <String>[
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
    '2031',
    '2032',
    '2033',
    '2034',
    '2035',
  ];

  late String _selectedMonth;
  late String _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        _verticalPadding,
        _horizontalPadding,
        _verticalPadding,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            const SizedBox(height: _sectionGap),
            Text(
              'save ${widget.cardMask} card',
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.56,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'confirm expiration date',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
                color: Color(0xFF707070),
              ),
            ),
            const SizedBox(height: _sectionGap),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildDropdownField(
                    value: _selectedMonth,
                    values: _months,
                    onChanged: (String selectedValue) {
                      setState(() {
                        _selectedMonth = selectedValue;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdownField(
                    value: _selectedYear,
                    values: _years,
                    onChanged: (String selectedValue) {
                      setState(() {
                        _selectedYear = selectedValue;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: _sectionGap),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF645D9C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  'save card',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF1F1F8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF9F5FF),
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEDEBF7),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AssetConstant.creditCardIconSVG,
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.cancel_outlined,
              size: 30,
              color: Color(0xFF212121),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: _dropdownHeight,
      padding: const EdgeInsets.only(
        left: _dropdownTextLeftPadding,
        right: _dropdownRightPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F1F9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(8),
          icon: SizedBox(
            width: _dropdownArrowSize,
            height: _dropdownArrowSize,
            child: SvgPicture.asset(
              AssetConstant.downBluArrowSVG,
              fit: BoxFit.contain,
            ),
          ),
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF737373),
          ),
          items: values.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (String? selected) {
            if (selected == null) {
              return;
            }

            onChanged(selected);
          },
        ),
      ),
    );
  }
}
