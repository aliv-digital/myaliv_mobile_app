import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/theme.dart';

class RoamBottomSheet extends StatefulWidget {
  const RoamBottomSheet({
    super.key,
    this.title = GuestPurchasePlanTheme.roamBottomSheetTitle,
    this.warningText = GuestPurchasePlanTheme.roamBottomSheetWarningText,
    this.startFromLabel = GuestPurchasePlanTheme.roamBottomSheetStartFromLabel,
    this.initialDate,
    required this.onBackPressed,
    required this.onActivateNowPressed,
    this.onDateApplied,
  });

  final String title;
  final String warningText;
  final String startFromLabel;
  final DateTime? initialDate;
  final VoidCallback onBackPressed;
  final VoidCallback onActivateNowPressed;
  final ValueChanged<DateTime>? onDateApplied;

  @override
  State<RoamBottomSheet> createState() => _RoamBottomSheetState();
}

class _RoamBottomSheetState extends State<RoamBottomSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.roamBottomSheetBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            GuestPurchasePlanTheme.bottomSheetTopCornerRadius,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: GuestPurchasePlanTheme.roamBottomSheetContentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header back button.
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: widget.onBackPressed,
                  borderRadius: BorderRadius.circular(
                    GuestPurchasePlanTheme.bottomSheetBackTapRadius,
                  ),
                  child: SizedBox(
                    width: GuestPurchasePlanTheme.bottomSheetBackIconSize,
                    height: GuestPurchasePlanTheme.bottomSheetBackIconSize,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: GuestPurchasePlanTheme.bottomSheetBackIconSize,
                      color: GuestPurchasePlanTheme.bottomSheetBackIconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: GuestPurchasePlanTheme.roamBottomSheetBackToTitleGap,
              ),

              // Main title.
              Text(
                widget.title,
                style: GuestPurchasePlanTheme.roamBottomSheetTitleTextStyle,
              ),
              const SizedBox(
                height: GuestPurchasePlanTheme.roamBottomSheetTitleToWarningGap,
              ),

              // Warning box.
              Container(
                padding: GuestPurchasePlanTheme.bottomSheetWarningPadding,
                decoration: BoxDecoration(
                  color: GuestPurchasePlanTheme
                      .roamBottomSheetWarningBackgroundColor,
                  borderRadius: BorderRadius.circular(
                    GuestPurchasePlanTheme.bottomSheetWarningRadius,
                  ),
                  border: Border.all(
                    color: GuestPurchasePlanTheme.warningBorder,
                    width: GuestPurchasePlanTheme.bottomSheetWarningBorderWidth,
                  ),
                ),
                child: SizedBox(
                  width: GuestPurchasePlanTheme.roamBottomSheetWarningTextWidth,
                  child: Text(
                    widget.warningText,
                    style: GuestPurchasePlanTheme.roamBottomSheetWarningTextStyle,
                  ),
                ),
              ),
              const SizedBox(
                height: GuestPurchasePlanTheme.roamBottomSheetWarningToStartFromGap,
              ),

              // Date start label.
              SizedBox(
                width: GuestPurchasePlanTheme.roamBottomSheetStartFromLabelWidth,
                child: Text(
                  widget.startFromLabel,
                  style:
                      GuestPurchasePlanTheme.roamBottomSheetStartFromLabelTextStyle,
                ),
              ),
              const SizedBox(
                height: GuestPurchasePlanTheme.roamBottomSheetStartFromToDateFieldGap,
              ),

              // Select-date field.
              InkWell(
                onTap: _openCalendarPickerSheet,
                borderRadius: BorderRadius.circular(
                  GuestPurchasePlanTheme.roamBottomSheetDateFieldRadius,
                ),
                child: Container(
                  height: GuestPurchasePlanTheme.roamBottomSheetDateFieldHeight,
                  padding: GuestPurchasePlanTheme.roamBottomSheetDateFieldPadding,
                  decoration: BoxDecoration(
                    color: GuestPurchasePlanTheme
                        .roamBottomSheetDateFieldBackgroundColor,
                    borderRadius: BorderRadius.circular(
                      GuestPurchasePlanTheme.roamBottomSheetDateFieldRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDateWithOrdinal(_selectedDate),
                          style:
                              GuestPurchasePlanTheme.roamBottomSheetDateFieldTextStyle,
                        ),
                      ),
                      SvgPicture.asset(
                        AssetConstant.calenderIconSVG,
                        width: GuestPurchasePlanTheme.roamBottomSheetDateFieldIconSize,
                        height: GuestPurchasePlanTheme.roamBottomSheetDateFieldIconSize,
                        colorFilter: ColorFilter.mode(
                          GuestPurchasePlanTheme.roamBottomSheetDateFieldIconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: GuestPurchasePlanTheme.roamBottomSheetDateFieldToOrGap,
              ),

              // OR divider.
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: GuestPurchasePlanTheme.roamBottomSheetOrDividerColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal:
                          GuestPurchasePlanTheme.roamBottomSheetOrTextHorizontalPadding,
                    ),
                    child: Text(
                      'or',
                      style: GuestPurchasePlanTheme.roamBottomSheetOrTextStyle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: GuestPurchasePlanTheme.roamBottomSheetOrDividerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: GuestPurchasePlanTheme.roamBottomSheetOrToActivateNowGap,
              ),

              // Primary CTA.
              DefaultButton(
                label: GuestPurchasePlanTheme.bottomSheetActivateNowLabel,
                isLoading: false,
                onPressed: widget.onActivateNowPressed,
                height: GuestPurchasePlanTheme.bottomSheetActionButtonHeight,
                backgroundColor: GuestPurchasePlanTheme.activateNowButton,
                textStyle:
                    GuestPurchasePlanTheme.roamBottomSheetActivateNowTextStyle,
                borderRadius: BorderRadius.circular(
                  GuestPurchasePlanTheme.bottomSheetActionButtonCornerRadius,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCalendarPickerSheet() async {
    final DateTime? pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (calendarContext) {
        return _RoamCalendarPickerSheet(
          initialDate: _selectedDate,
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      _selectedDate = pickedDate;
    });
    widget.onDateApplied?.call(pickedDate);
  }
}

class _RoamCalendarPickerSheet extends StatefulWidget {
  const _RoamCalendarPickerSheet({
    required this.initialDate,
  });

  final DateTime initialDate;

  @override
  State<_RoamCalendarPickerSheet> createState() => _RoamCalendarPickerSheetState();
}

class _RoamCalendarPickerSheetState extends State<_RoamCalendarPickerSheet> {
  late DateTime _draftSelectedDate;

  @override
  void initState() {
    super.initState();
    _draftSelectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuestPurchasePlanTheme.roamCalendarSheetBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            GuestPurchasePlanTheme.bottomSheetTopCornerRadius,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: GuestPurchasePlanTheme.roamCalendarContentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: GuestPurchasePlanTheme
                            .roamCalendarSelectedDayBackgroundColor,
                        onPrimary:
                            GuestPurchasePlanTheme.roamCalendarSelectedDayTextColor,
                        surface: GuestPurchasePlanTheme
                            .roamCalendarSheetBackgroundColor,
                        onSurface: GuestPurchasePlanTheme.roamCalendarDayTextColor,
                      ),
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor:
                        GuestPurchasePlanTheme.roamCalendarSheetBackgroundColor,
                    headerForegroundColor:
                        GuestPurchasePlanTheme.roamCalendarDayTextColor,
                    headerHeadlineStyle:
                        GuestPurchasePlanTheme.roamCalendarHeaderTextStyle,
                    weekdayStyle:
                        GuestPurchasePlanTheme.roamCalendarWeekdayTextStyle,
                    dayStyle: GuestPurchasePlanTheme.roamCalendarDayTextStyle,
                    dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return GuestPurchasePlanTheme
                              .roamCalendarSelectedDayTextColor;
                        }
                        return GuestPurchasePlanTheme.roamCalendarDayTextColor;
                      },
                    ),
                    dayBackgroundColor:
                        WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return GuestPurchasePlanTheme
                              .roamCalendarSelectedDayBackgroundColor;
                        }
                        return Colors.transparent;
                      },
                    ),
                    dayShape: const WidgetStatePropertyAll<OutlinedBorder>(
                      CircleBorder(),
                    ),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: TextButton.styleFrom(
                      foregroundColor: GuestPurchasePlanTheme.brandPurple,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: GuestPurchasePlanTheme.roamCalendarPickerVisibleHeight,
                  child: CalendarDatePicker(
                    initialDate: _draftSelectedDate,
                    firstDate: DateTime(2020, 1, 1),
                    lastDate: DateTime(2035, 12, 31),
                    onDateChanged: (DateTime nextDate) {
                      setState(() {
                        _draftSelectedDate = nextDate;
                      });
                    },
                  ),
                ),
              ),

              Container(
                height: 1,
                color: GuestPurchasePlanTheme.roamCalendarDividerColor,
              ),
              const SizedBox(
                height: GuestPurchasePlanTheme.roamCalendarDividerToActionsGap,
              ),

              Row(
                children: [
                  Expanded(
                    child: DefaultButton(
                      label: GuestPurchasePlanTheme.roamCalendarCancelLabel,
                      isLoading: false,
                      onPressed: () => Navigator.of(context).pop(),
                      height: GuestPurchasePlanTheme.roamCalendarActionButtonHeight,
                      backgroundColor: GuestPurchasePlanTheme
                          .roamCalendarCancelButtonBackgroundColor,
                      textStyle: GuestPurchasePlanTheme.roamCalendarCancelTextStyle,
                      borderRadius: BorderRadius.circular(
                        GuestPurchasePlanTheme
                            .bottomSheetActionButtonCornerRadius,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: GuestPurchasePlanTheme.roamCalendarActionButtonsGap,
                  ),
                  Expanded(
                    child: DefaultButton(
                      label: GuestPurchasePlanTheme.roamCalendarApplyLabel,
                      isLoading: false,
                      onPressed: () =>
                          Navigator.of(context).pop(_draftSelectedDate),
                      height: GuestPurchasePlanTheme.roamCalendarActionButtonHeight,
                      backgroundColor: GuestPurchasePlanTheme.activateNowButton,
                      textStyle: GuestPurchasePlanTheme.roamCalendarApplyTextStyle,
                      borderRadius: BorderRadius.circular(
                        GuestPurchasePlanTheme
                            .bottomSheetActionButtonCornerRadius,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDateWithOrdinal(DateTime date) {
  final String month = _monthName(date.month);
  final String ordinalDay = '${date.day}${_ordinalSuffix(date.day)}';
  return '$month $ordinalDay, ${date.year}';
}

String _monthName(int month) {
  const List<String> months = <String>[
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
  return months[month - 1];
}

String _ordinalSuffix(int day) {
  if (day >= 11 && day <= 13) return 'th';
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}
