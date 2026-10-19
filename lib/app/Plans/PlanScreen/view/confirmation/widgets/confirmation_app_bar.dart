import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';

class ConfirmationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onBack;
  final VoidCallback onHome;

  const ConfirmationAppBar({
    super.key,
    required this.onBack,
    required this.onHome,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorManager.primaryPurple,
      elevation: 0,
      toolbarHeight: 64,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: ColorManager.primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBack,
        ),
      ),
      centerTitle: false,
      title: const Text(
        'confirmation and payment',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        InkWell(
          onTap: onHome,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: SvgPicture.asset(
              'assets/icons/home.svg',
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
