import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class UpgradeCreditLimitButton extends StatelessWidget {
  const UpgradeCreditLimitButton({super.key});

  static const Color _foreground = Color(0xFFEF3A4B);
  static const Color _background = Color(0xFFF4F5FA);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          context.read<AppUiConfigCubit>().showMyLimitsView();
          context.go(AppRoutes.usage);
        },
        icon: SvgPicture.asset(
          'assets/icons/card-add.svg',
          colorFilter: const ColorFilter.mode(_foreground, BlendMode.srcIn),
        ),
        label: const Text(
          'upgrade credit limit',
          style: TextStyle(
            color: _foreground,
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}
