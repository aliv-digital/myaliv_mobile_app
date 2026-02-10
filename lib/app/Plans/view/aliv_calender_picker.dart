import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AlivCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onApply;

  const AlivCalendarPicker({
    super.key,
    required this.initialDate,
    required this.onApply,
  });

  @override
  State<AlivCalendarPicker> createState() => _AlivCalendarPickerState();
}

class _AlivCalendarPickerState extends State<AlivCalendarPicker> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          currentDay: DateTime.now(),

          selectedDayPredicate: (day) =>
              isSameDay(_selectedDay, day),

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },

          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            leftChevronIcon: const Icon(Icons.chevron_left),
            rightChevronIcon: const Icon(Icons.chevron_right),
            titleTextStyle: const TextStyle(
              fontFamily: 'Circular Pro',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E3A59),
            ),
          ),

          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
            weekendStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E3A59),
            ),
          ),

          calendarStyle: CalendarStyle(
            outsideDaysVisible: true,

            defaultTextStyle: const TextStyle(
              fontFamily: 'Circular Pro',
              fontWeight: FontWeight.w500,
              color: Color(0xFF2E3A59),
            ),

            outsideTextStyle: const TextStyle(
              color: Color(0xFFB0B7C3),
            ),

            selectedDecoration: const BoxDecoration(
              color: Color(0xFF645D9C),
              shape: BoxShape.circle,
            ),

            todayDecoration: const BoxDecoration(
              color: Color(0x1A645D9C),
              shape: BoxShape.circle,
            ),

            markerDecoration: const BoxDecoration(
              color: Color(0xFF645D9C),
              shape: BoxShape.circle,
            ),
          ),

          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;
              return const Positioned(
                bottom: 6,
                child: CircleAvatar(
                  radius: 2,
                  backgroundColor: Color(0xFF645D9C),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),
        const Divider(),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: Color(0xFFF1F1F8)),
                ),
                child: const Text(
                  'cancel',
                  style: TextStyle(
                    color: Color(0xFF645D9C),
                    fontFamily: 'Circular Pro',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => widget.onApply(_selectedDay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF645D9C),
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'apply',
                  style: TextStyle(
                    fontFamily: 'Circular Pro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
