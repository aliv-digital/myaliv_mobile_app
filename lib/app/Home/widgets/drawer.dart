import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../router/app_routes.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jade Turnquest',
                          style: TextStyle(
                            fontFamily: 'CircularPro',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '242.820.2246',
                          style: TextStyle(
                            fontFamily: 'CircularPro',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),

            _item(IconsaxPlusLinear.user, 'profile',context),
            _item(IconsaxPlusLinear.wallet_check, 'purchases',context),
            _item(IconsaxPlusLinear.user_add, 'refer a friend',context),
            _item(IconsaxPlusLinear.notification, 'notifications',context),
            _item(IconsaxPlusLinear.document_1, 'REV bill pay',context),
            _item(IconsaxPlusLinear.setting_5, 'settings',context),
            _item(IconsaxPlusLinear.support, 'support',context),
            _item(IconsaxPlusLinear.global, 'ALIVFibr', external: true,context),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'logout',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _item(IconData icon, String label, BuildContext context,{bool external = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontFamily: 'CircularPro')),
      trailing: external
          ? const Icon(Icons.open_in_new, size: 18)
          : const Icon(Icons.chevron_right),
      onTap: () {
        if(label == 'profile'){
          context.push(AppRoutes.profilePrepaidScreen);
        }else if(label == 'purchases'){
          context.push(AppRoutes.purchasesPrepaidScreen);
        }else if(label == 'refer a friend'){
          context.push(AppRoutes.referFriendPrepaidScreen);
        }else if(label == 'settings'){
          context.push(AppRoutes.settingsScreen);
        } else if(label == 'REV bill pay'){
          context.push(AppRoutes.revBillPayPrepaidScreen);
        }else if(label == 'notifications'){
          context.push(AppRoutes.notificationScreen);
        }
      },
    );
  }
}
