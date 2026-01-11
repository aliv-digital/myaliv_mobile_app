import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  static const Color purple = Color(0xFF6C63A6);

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

            _item(IconsaxPlusLinear.user, 'profile'),
            _item(IconsaxPlusLinear.wallet_check, 'purchases'),
            _item(IconsaxPlusLinear.user_add, 'refer a friend'),
            _item(IconsaxPlusLinear.notification, 'notifications'),
            _item(IconsaxPlusLinear.document_1, 'REV bill pay'),
            _item(IconsaxPlusLinear.setting_5, 'settings'),
            _item(IconsaxPlusLinear.support, 'support'),
            _item(IconsaxPlusLinear.global, 'ALIVFibr', external: true),

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

  Widget _item(IconData icon, String label, {bool external = false}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontFamily: 'CircularPro')),
      trailing: external
          ? const Icon(Icons.open_in_new, size: 18)
          : const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
