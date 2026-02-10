import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
        children: [
          _DateSection(
            date: 'July 10th',
            items: [
              NotificationItem(
                title: 'ALIV Deals are back',
                time: '08:58 PM',
                unread: true,
                showArrow: true,
                icon: SvgPicture.asset('assets/icons/ion-ios-swap.svg'),
              ),
               NotificationItem(
                title: 'Your Weekly Package added\nSuccessfully',
                time: '08:40 PM',
                unread: true,
                icon: SvgPicture.asset('assets/icons/ion-ios-wallet.svg'),
              ),
               NotificationItem(
                title: 'Incomplete Transaction',
                time: '06:58 AM',
                icon: SvgPicture.asset('assets/icons/ion-ios-wallet.svg'),
              ),
            ],
          ),
           _DateSection(
            date: 'July 5th',
            items: [
              NotificationItem(
                title: 'ALIV Deals are back',
                time: '08:58 PM',
                unread: true,
                icon: SvgPicture.asset('assets/icons/ion-ios-swap.svg'),
              ),
              NotificationItem(
                title: 'Your Weekly Package added\nSuccessfully',
                time: '08:40 PM',
                unread: true,
                icon: SvgPicture.asset('assets/icons/ion-ios-wallet.svg'),
              ),
              NotificationItem(
                title: 'Incomplete Transaction',
                time: '06:58 AM',
                icon: SvgPicture.asset('assets/icons/ion-ios-wallet.svg'),
              ),
            ],
          ),
           _DateSection(
            date: 'July 2',
            items: [
              NotificationItem(
                title: 'ALIV Deals are back',
                time: '08:58 PM',
                icon: SvgPicture.asset('assets/icons/ion-ios-swap.svg'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF645D9C),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const Text(
        'notifications',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [_MonthDropdown(), const SizedBox(width: 24)],
    );
  }
}

class _MonthPickerSheet extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final ValueChanged<DateTime> onSelected;

  const _MonthPickerSheet({
    required this.initialMonth,
    required this.initialYear,
    required this.onSelected,
  });

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int selectedMonth;
  late int selectedYear;

  static const months = [
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

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth;
    selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(height: 16),
            _yearSelector(),
            const SizedBox(height: 16),
            _monthGrid(),
            const SizedBox(height: 20),
            _confirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          widget.onSelected(DateTime(selectedYear, selectedMonth));
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF645D9C),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: const Text(
          'apply',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Select month',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _yearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(() => selectedYear--),
        ),
        Text(
          '$selectedYear',
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => setState(() => selectedYear++),
        ),
      ],
    );
  }

  Widget _monthGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: months.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (_, i) {
        final isSelected = i + 1 == selectedMonth;

        return GestureDetector(
          onTap: () => setState(() => selectedMonth = i + 1),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF645D9C)
                  : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              months[i],
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DateSection extends StatelessWidget {
  final String date;
  final List<NotificationItem> items;

  const _DateSection({required this.date, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            date,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 6),
                color: Color(0x11000000),
              ),
            ],
          ),
          child: Column(children: items),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}


class NotificationItem extends StatelessWidget {
  final String title;
  final String time;
  final bool unread;
  final bool showArrow;
  final Widget icon;

  const NotificationItem({
    super.key,
    required this.title,
    required this.time,
    required this.icon,
    this.unread = false,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F1FA),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: icon,
                  ),
                ),
                if (unread)
                  const Positioned(
                    right: -2,
                    top: -2,
                    child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: const Color(0xFF1C1C1C) /* Black-100% */,
                      fontSize: 14,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow) const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _MonthDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMonthPickerBottomSheet(
          context: context,
          initialMonth: DateTime.now().month,
          initialYear: DateTime.now().year,
          onSelected: (date) {
            debugPrint('Selected: ${date.month}/${date.year}');
          },
        );
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_today, size: 14),
            SizedBox(width: 8),
            Text(
              'July',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: const Color(0xFF222222),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  Future<void> showMonthPickerBottomSheet({
    required BuildContext context,
    required int initialMonth,
    required int initialYear,
    required ValueChanged<DateTime> onSelected,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return _MonthPickerSheet(
          initialMonth: initialMonth,
          initialYear: initialYear,
          onSelected: onSelected,
        );
      },
    );
  }
}
