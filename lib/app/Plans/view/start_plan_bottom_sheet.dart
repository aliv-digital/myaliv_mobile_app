import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StartPlanBottomSheet extends StatefulWidget {
  const StartPlanBottomSheet({super.key});

  @override
  State<StartPlanBottomSheet> createState() => _StartPlanBottomSheetState();
}

class _StartPlanBottomSheetState extends State<StartPlanBottomSheet> {
  DateTime? selectedDate;

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
            _StartFromField(date: selectedDate, onTap: _pickDate),
            const SizedBox(height: 24),
            _DividerOr(),
            const SizedBox(height: 24),
            _ActivateButton(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
}

Widget _Header(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      const SizedBox(width: 8),
      const Text(
        'when to start?',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
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
          color: const Color(0xFFF30F0F),
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

Widget _DividerOr() {
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
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // TODO: activation logic
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF645D9C),
          shape: const StadiumBorder(),
        ),
        child: const Text(
          'activate now',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 13,
            color: Color(0xFFF1F1F8),
          ),
        ),
      ),
    );
  }
}
