import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/core/model/line_status.dart';
import 'package:myaliv_mobile_app/core/utils/user_display_name.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/phone_dropdown.dart';

Color _dotColor(LineStatus status) {
  if (status.isActive) return Colors.greenAccent;
  if (status.isRestricted) return Colors.orangeAccent;
  if (status.isTerminal) return Colors.redAccent;
  return Colors.grey;
}

class HomeHeader extends StatelessWidget {
  final HomeUiConfig config;
  const HomeHeader({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
        bloc: instance<DeviceLimitsCubit>(),
        builder: (context, deviceState) {
          final lineStatus = LineStatus.fromCode(
            deviceState.allDeviceLimits.isNotEmpty
                ? deviceState.allDeviceLimits.first.deviceStatus
                : null,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/aliv_splash_logo.svg',
                    height: 46,
                    width: 112,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: _dotColor(lineStatus)),
                      const SizedBox(width: 6),
                      Text(
                        '${lineStatus.displayLabel} | ${config.userType.label}',
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
              BlocBuilder<AccountInfoCubit, AccountInfoState>(
                bloc: instance<AccountInfoCubit>(),
                buildWhen: (previous, current) =>
                    previous.accountInfo?.email != current.accountInfo?.email,
                builder: (context, accountState) {
                  final name = resolveUserDisplayName(
                    account: accountState,
                    devices: deviceState,
                  );
                  return Text(
                    'welcome back, $name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF1F1F8),
                      fontSize: 16,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              const PhoneDropdown(),
            ],
          );
        },
      ),
    );
  }
}
