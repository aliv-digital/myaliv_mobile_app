import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../resources/widgets/defaultButton.dart';
import '../../../../router/app_routes.dart';
import '../../../Aliv-Mobile-Guest/guestPurchasePlan/theme/theme.dart';
import '../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

Future<DateTime?> showStartPlanCalendarPickerSheet(
  BuildContext context, {
  required DateTime initialDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    isScrollControlled: true,
    builder: (_) => _RoamCalendarPickerSheet(initialDate: initialDate),
  );
}

class StartPlanBottomSheet extends StatefulWidget {
  final HomePlansPostPaidPlanModel plan;

  const StartPlanBottomSheet({
    super.key,
    required this.plan,
  });

  @override
  State<StartPlanBottomSheet> createState() => _StartPlanBottomSheetState();
}

class _StartPlanBottomSheetState extends State<StartPlanBottomSheet> {
  DateTime? selectedDate;

  bool isDateSelected = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x07101828),
              blurRadius: 8,
              offset: Offset(0, 8),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: Color(0x14101828),
              blurRadius: 24,
              offset: Offset(0, 20),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Icon(Icons.arrow_back),
              ),
            ),

            const Text(
              'when to start?',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _InfoBanner(),
            const SizedBox(height: 20),
            // there are already a calendar picker sheet
            _StartFromField(
              date: selectedDate,
              onTap: _openCalendarPickerSheet,
            ),
            const SizedBox(height: 20),
            _dividerOr(),
            const SizedBox(height: 20),
            (isDateSelected == true) ?
            _ActivateButton(selectedDate: selectedDate, plan: widget.plan) :
            _ActivateButton(selectedDate: null, plan: widget.plan),
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }

  Future<void> _openCalendarPickerSheet() async {
    final DateTime? pickedDate = await showStartPlanCalendarPickerSheet(
      context,
      initialDate: selectedDate ?? DateTime.now(),
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = pickedDate;
      isDateSelected = true;
    });
    if (mounted) {
      context.pop();
      // pass the selected date and also plan data to next screen
      context.push(
        '${AppRoutes.confirmation}'
        '?showBeginOn=true'
        '&beginDate=${selectedDate!.toIso8601String()}',
        extra: widget.plan,
      );
    }
  }
}

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0x1EE94408),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFFCA19B)),
      ),
      child: const Text(
        'your standalone plan can start immediately, or on a date of your choice.',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 12,
          color: Color(0xFFF30F0F),
          height: 1.38,
        ),
      ),
    );
  }
}

class _StartFromField extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _StartFromField({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'start from',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date == null ? 'Select date' : _formatDate(date!),
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 14,
                      color: Color(0xFF707070),
                    ),
                  ),
                ),
                SvgPicture.asset('assets/icons/calender.svg'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

Widget _dividerOr() {
  return Row(
    children: const [
      Expanded(child: Divider(thickness: 0.5)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'or',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 13,
            color: Color(0xFF8A8A8F),
          ),
        ),
      ),
      Expanded(child: Divider(thickness: 0.5)),
    ],
  );
}

class _ActivateButton extends StatelessWidget {
  final DateTime? selectedDate;
  final HomePlansPostPaidPlanModel plan;

  const _ActivateButton({
    required this.selectedDate,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // TODO: activation logic
          // Navigator.pop(context);
          final date = DateTime.now();
          // pass selected date
          if (selectedDate != null) {
            context.pop();
            context.push(
              '${AppRoutes.confirmation}'
              '?showBeginOn=true'
              '&beginDate=${selectedDate!.toIso8601String()}',
              extra: plan,
            );
          } else {
            context.pop();
            context.push(
              '${AppRoutes.confirmation}'
              '?showBeginOn=false'
              '&beginDate=${date.toIso8601String()}',
              extra: plan,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF645D9C),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          'activate now',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF1F1F8),
          ),
        ),
      ),
    );
  }
}

class _RoamCalendarPickerSheet extends StatefulWidget {
  const _RoamCalendarPickerSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  State<_RoamCalendarPickerSheet> createState() =>
      _RoamCalendarPickerSheetState();
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
                        onPrimary: GuestPurchasePlanTheme
                            .roamCalendarSelectedDayTextColor,
                        surface: GuestPurchasePlanTheme
                            .roamCalendarSheetBackgroundColor,
                        onSurface:
                            GuestPurchasePlanTheme.roamCalendarDayTextColor,
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
                    dayBackgroundColor: WidgetStateProperty.resolveWith<Color?>(
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
                  height:
                      GuestPurchasePlanTheme.roamCalendarPickerVisibleHeight,
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
                      height:
                          GuestPurchasePlanTheme.roamCalendarActionButtonHeight,
                      backgroundColor: GuestPurchasePlanTheme
                          .roamCalendarCancelButtonBackgroundColor,
                      textStyle:
                          GuestPurchasePlanTheme.roamCalendarCancelTextStyle,
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
                      height:
                          GuestPurchasePlanTheme.roamCalendarActionButtonHeight,
                      backgroundColor: GuestPurchasePlanTheme.activateNowButton,
                      textStyle:
                          GuestPurchasePlanTheme.roamCalendarApplyTextStyle,
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
