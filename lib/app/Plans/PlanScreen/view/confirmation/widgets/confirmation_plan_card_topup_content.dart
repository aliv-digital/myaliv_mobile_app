import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';

import '../utils/confirmation_formatters.dart';

class ConfirmationPlanCardTopupContent extends StatelessWidget {
  final DateTime? date;
  final bool? showBeginOn;
  final double topUpAmount;

  const ConfirmationPlanCardTopupContent({
    super.key,
    this.date,
    this.showBeginOn,
    required this.topUpAmount,
  });

  @override
  Widget build(BuildContext context) {
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    final deviceFullName = instance<DeviceLimitsCubit>().state.fullName;
    final fullName = deviceFullName ?? nameFromEmail(accountInfo?.email);
    final phone = formatConfirmationPhone(accountInfo?.phoneNumber ?? '');
    final hasBeginDate = showBeginOn == true && date != null;
    final beginText = hasBeginDate
        ? 'begins ${DateFormat('dd-MM-yy').format(date!)}'
        : 'begins immediately';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'top-up',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                fullName,
                style: const TextStyle(
                  color: Color(0xFF121212),
                  fontSize: 16,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFCDC8F9)),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'top-up prepaid number',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      beginText,
                      style: const TextStyle(
                        color: Color(0xFF707070),
                        fontSize: 10,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F6),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  formatConfirmationCurrency(topUpAmount),
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 21),
            ],
          ),
        ),
      ],
    );
  }
}
