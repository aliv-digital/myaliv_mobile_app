import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../router/app_routes.dart';
import 'bottom_tab_icon.dart';
import 'drawer.dart';

final GlobalKey<ScaffoldState> bottomShellKey =
GlobalKey<ScaffoldState>();


class BottomShell extends StatelessWidget {
  final Widget child;
  const BottomShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.usage)) return 1;
    if (location.startsWith(AppRoutes.plans)) return 2;
    if (location.startsWith(AppRoutes.menu)) return 3;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      drawer: const AppMenuDrawer(),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.home);
                break;
              case 1:
                context.go(AppRoutes.usage);
                break;
              case 2:
                context.go(AppRoutes.plans);
                break;
              case 3:
                // context.go(AppRoutes.menu);
              // 🔥 OPEN DRAWER INSTEAD OF ROUTE
                bottomShellKey.currentState?.openDrawer();
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF6C63A6),
          unselectedItemColor: const Color(0xFFB0AEDA),
          selectedLabelStyle: const TextStyle(
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'CircularPro',
          ),
          items: [
            BottomNavigationBarItem(
              icon: BottomTabIcon(
                asset: 'assets/icons/home.svg',
                isActive: currentIndex == 0,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: BottomTabIcon(
                asset: 'assets/icons/usage.svg',
                isActive: currentIndex == 1,
              ),
              label: 'Usage',
            ),
            BottomNavigationBarItem(
              icon: BottomTabIcon(
                asset: 'assets/icons/ListStar.svg',
                isActive: currentIndex == 2,
              ),
              label: 'Plans',
            ),
            BottomNavigationBarItem(
              icon: BottomTabIcon(
                asset: 'assets/icons/menu.svg',
                isActive: currentIndex == 3,
              ),
              label: 'Menu',
            ),
          ],
        ),
      ),
    );
  }
}
