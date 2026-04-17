import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../router/app_routes.dart';
import '../model/logout_bottom_sheet.dart';

/// Extract name from email (substring before @)
String _nameFromEmail(String email) {
  if (email.isEmpty || !email.contains('@')) return 'User';
  return email.split('@').first;
}

/// Format phone number as XXX-XXX-XXXX
String _formatPhone(String phone) {
  if (phone.isEmpty) return '';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  if (digits.length == 11 && digits.startsWith('1')) {
    return '${digits.substring(1, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
  }
  return phone;
}

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.7,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
                      bloc: instance<DeviceLimitsCubit>(),
                      builder: (context, state) {
                        final email = instance<AccountInfoCubit>().state.accountInfo?.email ?? '';
                        final fullName = state.fullName ?? _nameFromEmail(email);
                        final phone = _formatPhone(state.deviceLimits?.tn ?? '');

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Color(0xFF1C1C1C),
                                fontSize: 24,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phone,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF1C1C1C),
                                fontSize: 14,
                                fontFamily: 'CircularPro',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        'assets/icons/ic_back_bold.svg',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // const Divider(),
            SizedBox(height: 22),

            _item('assets/icons/profile.svg', 'profile', context),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Divider(height: 1, color: HexColor.fromHex('#E1E1E1')),
            ),
            _item('assets/icons/purchase.svg', 'purchases', context),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Divider(height: 1, color: HexColor.fromHex('#E1E1E1')),
            ),
            _item('assets/icons/refer.svg', 'refer a friend', context),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Divider(height: 1, color: HexColor.fromHex('#E1E1E1')),
            ),
            // _item('assets/icons/notification.svg', 'notifications', context),
            _item('assets/icons/bill.svg', 'REV bill pay', context),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Divider(height: 1, color: HexColor.fromHex('#E1E1E1')),
            ),
            _item('assets/icons/settings.svg', 'settings', context),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Divider(height: 1, color: HexColor.fromHex('#E1E1E1')),
            ),
            _item('assets/icons/support.svg', 'support', context),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Divider(height: 1, color: HexColor.fromHex('#E1E1E1')),
            ),
            _item(
              'assets/icons/magnet.svg',
              'ALIVFibr',
              external: true,
              context,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16),
              child: Divider(height: 1, color: HexColor.fromHex('#E1E1E1')),
            ),

            SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 260,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop(); // close drawer
                    // await Future.delayed(const Duration(milliseconds: 50));
                    //
                    // context.go(AppRoutes.welcome);
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => const LogoutBottomSheet(),
                    );
                  },
                  icon: SvgPicture.asset('assets/icons/logout.svg'),
                  label: const Text(
                    'logout',
                    style: TextStyle(
                      color: Colors.white /* White-100% */,
                      fontSize: 15,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.26,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    String icon,
    String label,
    BuildContext context, {
    bool external = false,
  }) {
    return ListTile(
      leading: (label == 'purchases')
          ? SvgPicture.asset(icon, height: 12, width: 12)
          : SvgPicture.asset(icon, height: 18, width: 18),
      title: Text(label, style: const TextStyle(fontFamily: 'CircularPro')),

      trailing: label == 'refer a friend'
          ? null
          : label == 'notifications'
          ? null
          : label == 'REV bill pay'
          ? null
          : external
          ? const Icon(Icons.open_in_new, size: 18)
          : const Icon(Icons.chevron_right),
      onTap: () async {
        if (label == 'profile') {
          Navigator.of(context).pop(); // close drawer
          await Future.delayed(const Duration(milliseconds: 50));
          context.push(AppRoutes.profilePrepaidScreen);
        } else if (label == 'purchases') {
          Navigator.of(context).pop(); // close drawer
          await Future.delayed(const Duration(milliseconds: 50));
          context.push(AppRoutes.purchasesPrepaidScreen);
        } else if (label == 'refer a friend') {
          Navigator.of(context).pop(); // close drawer
          await Future.delayed(const Duration(milliseconds: 50));
          context.push(AppRoutes.referFriendPrepaidScreen);
        } else if (label == 'settings') {
          Navigator.of(context).pop(); // close drawer
          await Future.delayed(const Duration(milliseconds: 50));
          context.push(AppRoutes.settingsScreen);
        } else if (label == 'REV bill pay') {
          Navigator.of(context).pop(); // close drawer
          await Future.delayed(const Duration(milliseconds: 50));
          context.push(AppRoutes.revBillPayPrepaidScreen);
        } else if (label == 'notifications') {
          Navigator.of(context).pop(); // close drawer
          await Future.delayed(const Duration(milliseconds: 50));
          context.push(AppRoutes.notificationScreen);
        } else if (label == 'support') {
          Navigator.of(context).pop(); // close drawer
          await Future.delayed(const Duration(milliseconds: 50));
          context.push(AppRoutes.supportScreen);
        } else if (label == 'ALIVFibr') {
          Navigator.of(context).pop(); // close drawer)

          final uri = Uri.parse(
            'https://portal.alivfibr.com/myfibr/login.aspx',
          );

          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw 'Could not open store locator';
          }
        } else {}
      },
    );
  }
}
