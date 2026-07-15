import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown.dart';

/// Extract name from email (substring before @)
String _nameFromEmail(String email) {
  if (email.isEmpty || !email.contains('@')) return 'User';
  return email.split('@').first;
}

class HomeHeader extends StatelessWidget {
  final HomeUiConfig config;
  const HomeHeader({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/aliv_splash_logo.svg',
                height: 46,width: 112,
                // width: 24,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    config.isPrepaid ? 'active | prepaid' : 'active | postpaid',
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

            ],
          ),
          const SizedBox(height: 25),
          BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
            bloc: instance<DeviceLimitsCubit>(),
            builder: (context, deviceState) {
              return BlocBuilder<AccountInfoCubit, AccountInfoState>(
                bloc: instance<AccountInfoCubit>(),
                buildWhen: (previous, current) =>
                    previous.accountInfo?.email != current.accountInfo?.email,
                builder: (context, accountState) {
                  final email = accountState.accountInfo?.email ?? '';
                  final name = accountState.fullName ?? deviceState.fullName ?? _nameFromEmail(email);
                  return Text(
                    'welcome back, $name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFF1F1F8),
                      fontSize: 16,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 6),
          const PhoneDropdown(),
        ],
      ),
    );
  }
}
