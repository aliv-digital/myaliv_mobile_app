import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/resources/size_manager.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

class StartFuturePlanBottomSheet extends StatelessWidget {
  const StartFuturePlanBottomSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const StartFuturePlanBottomSheet(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.textColorF6F4F8,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSize.s28),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppPadding.p16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Back',
                  icon: Icon(
                    Icons.arrow_back,
                    color: ColorManager.primaryBlack,
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(height: AppSize.s12),
              Text(
                'are you sure you want to start this plan now?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ColorManager.primaryBlack,
                  fontFamily: 'CircularPro',
                  fontSize: AppSize.s16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: AppSize.s20),
              DefaultButton(
                label: 'ok',
                isLoading: false,
                fontSize: AppSize.s14,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
