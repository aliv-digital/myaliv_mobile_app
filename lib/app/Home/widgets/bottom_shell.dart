import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import '../../../router/app_routes.dart';
import 'bottom_tab_icon.dart';
import 'drawer.dart';

class BottomShell extends StatefulWidget {
  final Widget child;
  final bool interceptSystemBack;
  const BottomShell({
    super.key,
    required this.child,
    this.interceptSystemBack = true,
  });

  @override
  State<BottomShell> createState() => _BottomShellState();
}

class _BottomShellState extends State<BottomShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _indexFromLocation(String location, {required bool isRestricted}) {
    if (location.startsWith(AppRoutes.usage) ||
        location.startsWith(AppRoutes.myPlans)) {
      return 1;
    }
    if (!isRestricted && location.startsWith(AppRoutes.plans)) return 2;
    if (location.startsWith(AppRoutes.menu)) return isRestricted ? 2 : 3;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final isRestricted = context.watch<AppUiConfigCubit>().state.isRestricted;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(
      location,
      isRestricted: isRestricted,
    );

    final scaffold = Scaffold(
      key: _scaffoldKey,
      body: widget.child,
      drawer: const AppMenuDrawer(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(0, -4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
            ),
            child: BottomNavigationBar(
              elevation: 0,
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 0) {
                  context.go(AppRoutes.home);
                  return;
                }
                if (index == 1) {
                  context.go(AppRoutes.usage);
                  return;
                }
                if (!isRestricted && index == 2) {
                  context.go(AppRoutes.plans);
                  return;
                }
                // Menu (index 2 when restricted, 3 otherwise) opens drawer.
                _scaffoldKey.currentState?.openDrawer();
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF645D9C),
              unselectedItemColor: const Color(0xFFB0AEDA),
              selectedLabelStyle: const TextStyle(
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(fontFamily: 'CircularPro'),
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
                    asset: currentIndex == 1
                        ? 'assets/icons/usage_active.svg'
                        : 'assets/icons/usage.svg',
                    isActive: currentIndex == 1,
                  ),
                  label: 'Usage',
                ),
                if (!isRestricted)
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
                    isActive: false,
                  ),
                  label: 'Menu',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!widget.interceptSystemBack) {
      return scaffold;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.of(context).pop();
          return;
        }
        context.go(AppRoutes.welcome);
      },
      child: scaffold,
    );
  }
}
