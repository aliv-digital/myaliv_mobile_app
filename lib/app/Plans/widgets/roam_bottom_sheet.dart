import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/theme.dart';

class HomePlanRoamBottomSheet extends StatefulWidget {
  const HomePlanRoamBottomSheet({
    super.key,
    this.title = HomePlanTheme.roamBottomSheetTitle,
    this.warningText = HomePlanTheme.roamBottomSheetWarningText,
    this.startFromLabel = HomePlanTheme.roamBottomSheetStartFromLabel,
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
  State<HomePlanRoamBottomSheet> createState() => _RoamBottomSheetState();
}

class _RoamBottomSheetState extends State<HomePlanRoamBottomSheet> {
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
        color: HomePlanTheme.roamBottomSheetBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            HomePlanTheme.bottomSheetTopCornerRadius,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: HomePlanTheme.roamBottomSheetContentPadding,
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
                    HomePlanTheme.bottomSheetBackTapRadius,
                  ),
                  child: SizedBox(
                    width: HomePlanTheme.bottomSheetBackIconSize,
                    height: HomePlanTheme.bottomSheetBackIconSize,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: HomePlanTheme.bottomSheetBackIconSize,
                      color: HomePlanTheme.bottomSheetBackIconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: HomePlanTheme.roamBottomSheetBackToTitleGap,
              ),

              // Main title.
              Text(
                widget.title,
                style: HomePlanTheme.roamBottomSheetTitleTextStyle,
              ),
              const SizedBox(
                height: HomePlanTheme.roamBottomSheetTitleToWarningGap,
              ),

              // Warning box.
              Container(
                padding: HomePlanTheme.bottomSheetWarningPadding,
                decoration: BoxDecoration(
                  color: HomePlanTheme
                      .roamBottomSheetWarningBackgroundColor,
                  borderRadius: BorderRadius.circular(
                    HomePlanTheme.bottomSheetWarningRadius,
                  ),
                  border: Border.all(
                    color: HomePlanTheme.warningBorder,
                    width: HomePlanTheme.bottomSheetWarningBorderWidth,
                  ),
                ),
                child: SizedBox(
                  width: HomePlanTheme.roamBottomSheetWarningTextWidth,
                  child: Text(
                    widget.warningText,
                    style: HomePlanTheme.roamBottomSheetWarningTextStyle,
                  ),
                ),
              ),
              const SizedBox(
                height: HomePlanTheme.roamBottomSheetWarningToStartFromGap,
              ),

              // Date start label.
              SizedBox(
                width: HomePlanTheme.roamBottomSheetStartFromLabelWidth,
                child: Text(
                  widget.startFromLabel,
                  style:
                      HomePlanTheme.roamBottomSheetStartFromLabelTextStyle,
                ),
              ),
              const SizedBox(
                height: HomePlanTheme.roamBottomSheetStartFromToDateFieldGap,
              ),

              // Select-date field.
              InkWell(
                onTap: _openCalendarPickerSheet,
                borderRadius: BorderRadius.circular(
                  HomePlanTheme.roamBottomSheetDateFieldRadius,
                ),
                child: Container(
                  height: HomePlanTheme.roamBottomSheetDateFieldHeight,
                  padding: HomePlanTheme.roamBottomSheetDateFieldPadding,
                  decoration: BoxDecoration(
                    color: HomePlanTheme
                        .roamBottomSheetDateFieldBackgroundColor,
                    borderRadius: BorderRadius.circular(
                      HomePlanTheme.roamBottomSheetDateFieldRadius,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDateWithOrdinal(_selectedDate),
                          style:
                              HomePlanTheme.roamBottomSheetDateFieldTextStyle,
                        ),
                      ),
                      SvgPicture.asset(
                        AssetConstant.calenderIconSVG,
                        width: HomePlanTheme.roamBottomSheetDateFieldIconSize,
                        height: HomePlanTheme.roamBottomSheetDateFieldIconSize,
                        colorFilter: ColorFilter.mode(
                          HomePlanTheme.roamBottomSheetDateFieldIconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: HomePlanTheme.roamBottomSheetDateFieldToOrGap,
              ),

              // OR divider.
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: HomePlanTheme.roamBottomSheetOrDividerColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal:
                          HomePlanTheme.roamBottomSheetOrTextHorizontalPadding,
                    ),
                    child: Text(
                      'or',
                      style: HomePlanTheme.roamBottomSheetOrTextStyle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: HomePlanTheme.roamBottomSheetOrDividerColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: HomePlanTheme.roamBottomSheetOrToActivateNowGap,
              ),

              // Primary CTA.
              DefaultButton(
                label: HomePlanTheme.bottomSheetActivateNowLabel,
                isLoading: false,
                onPressed: widget.onActivateNowPressed,
                height: HomePlanTheme.bottomSheetActionButtonHeight,
                backgroundColor: HomePlanTheme.activateNowButton,
                textStyle:
                    HomePlanTheme.roamBottomSheetActivateNowTextStyle,
                borderRadius: BorderRadius.circular(
                  HomePlanTheme.bottomSheetActionButtonCornerRadius,
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
        color: HomePlanTheme.roamCalendarSheetBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            HomePlanTheme.bottomSheetTopCornerRadius,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: HomePlanTheme.roamCalendarContentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: HomePlanTheme
                            .roamCalendarSelectedDayBackgroundColor,
                        onPrimary:
                            HomePlanTheme.roamCalendarSelectedDayTextColor,
                        surface: HomePlanTheme
                            .roamCalendarSheetBackgroundColor,
                        onSurface: HomePlanTheme.roamCalendarDayTextColor,
                      ),
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor:
                        HomePlanTheme.roamCalendarSheetBackgroundColor,
                    headerForegroundColor:
                        HomePlanTheme.roamCalendarDayTextColor,
                    headerHeadlineStyle:
                        HomePlanTheme.roamCalendarHeaderTextStyle,
                    weekdayStyle:
                        HomePlanTheme.roamCalendarWeekdayTextStyle,
                    dayStyle: HomePlanTheme.roamCalendarDayTextStyle,
                    dayForegroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return HomePlanTheme
                              .roamCalendarSelectedDayTextColor;
                        }
                        return HomePlanTheme.roamCalendarDayTextColor;
                      },
                    ),
                    dayBackgroundColor:
                        WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return HomePlanTheme
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
                      foregroundColor: HomePlanTheme.brandPurple,
                    ),
                  ),
                ),
                child: SizedBox(
                  height: HomePlanTheme.roamCalendarPickerVisibleHeight,
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
                color: HomePlanTheme.roamCalendarDividerColor,
              ),
              const SizedBox(
                height: HomePlanTheme.roamCalendarDividerToActionsGap,
              ),

              Row(
                children: [
                  Expanded(
                    child: DefaultButton(
                      label: HomePlanTheme.roamCalendarCancelLabel,
                      isLoading: false,
                      onPressed: () => Navigator.of(context).pop(),
                      height: HomePlanTheme.roamCalendarActionButtonHeight,
                      backgroundColor: HomePlanTheme
                          .roamCalendarCancelButtonBackgroundColor,
                      textStyle: HomePlanTheme.roamCalendarCancelTextStyle,
                      borderRadius: BorderRadius.circular(
                        HomePlanTheme
                            .bottomSheetActionButtonCornerRadius,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: HomePlanTheme.roamCalendarActionButtonsGap,
                  ),
                  Expanded(
                    child: DefaultButton(
                      label: HomePlanTheme.roamCalendarApplyLabel,
                      isLoading: false,
                      onPressed: () =>
                          Navigator.of(context).pop(_draftSelectedDate),
                      height: HomePlanTheme.roamCalendarActionButtonHeight,
                      backgroundColor: HomePlanTheme.activateNowButton,
                      textStyle: HomePlanTheme.roamCalendarApplyTextStyle,
                      borderRadius: BorderRadius.circular(
                        HomePlanTheme
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
