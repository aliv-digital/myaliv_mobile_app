import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/core/utils/user_display_name.dart';

import '../utils/confirmation_formatters.dart';

class ConfirmationPlanCardMyNumberContent extends StatelessWidget {
  final double topUpAmount;

  const ConfirmationPlanCardMyNumberContent({
    super.key,
    required this.topUpAmount,
  });

  @override
  Widget build(BuildContext context) {
    final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
    final fullName = resolveUserDisplayName();
    final ownPhone = formatConfirmationPhone(
      accountInfo?.primaryPhoneNumber ??
          accountInfo?.altPhoneNumber ??
          accountInfo?.phoneNumber ??
          '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ownPhone,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
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
              const Expanded(
                child: Text(
                  'top-up',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
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
