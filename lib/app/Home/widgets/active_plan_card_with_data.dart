import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_skeleton.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/auto_renew_actions.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

/// Temporary HOME-006 preview: opt in with --dart-define=debugForcePlanExpiryWarning=true.
/// Release/profile builds always use the real expiry. Banner styling is shared.
const bool debugForcePlanExpiryWarning =
    kDebugMode && bool.fromEnvironment('debugForcePlanExpiryWarning');

/// Active plan card connected to PlansCubit for real-time data.
///
/// This widget displays the active plan with renew button inside the card,
/// matching the original design from PrepaidActivePlanCard.
class PrepaidActivePlanCardWithData extends StatelessWidget {
  final bool showRenewButton;
  final bool isFromHome;

  const PrepaidActivePlanCardWithData({
    super.key,
    this.showRenewButton = true,
    this.isFromHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) {
        return previous.status != current.status ||
            previous.earliestAddOnsPrimaryPlan !=
                current.earliestAddOnsPrimaryPlan ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        final redCreditCard = isFromHome
            ? AssetConstant.homeRedCardSVG
            : AssetConstant.redCreditCardSVG;
        final cardHeight = showRenewButton ? 216.0 : 166.0;
        final cardPadding = showRenewButton
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 13)
            : const EdgeInsets.fromLTRB(16, 13, 16, 26);

        final card = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: cardHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: _CreditCardBackground(assetPath: redCreditCard),
                ),
                Padding(
                  padding: cardPadding,
                  child: (state.isLoading || state.isInitial)
                      ? ActivePlanCardSkeleton(showRenewButton: showRenewButton)
                      : _buildContent(state.earliestAddOnsPrimaryPlan),
                ),
              ],
            ),
          ),
        );

        if (!showRenewButton) return card;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: isFromHome
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!state.isLoading &&
                        !state.isInitial &&
                        state.earliestAddOnsPrimaryPlan != null)
                      _PlanExpiryWarning(
                        plan: state.earliestAddOnsPrimaryPlan!,
                      ),
                    card,
                  ],
                )
              : card,
        );
      },
    );
  }

  Widget _buildContent(BasePlanModel? activePlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TopRow(),
        Text(
          activePlan?.planName.trim().isNotEmpty == true
              ? activePlan!.planName
              : 'no active plan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _DatesRow(
          activeDate: (activePlan?.startDateTime).formatDdMmYyOrDash(),
          expireDate: (activePlan?.endDateTime).formatDdMmYyOrDash(),
          expireTime: (activePlan?.endDateTime).formatHmAOrEmpty(),
        ),
        if (showRenewButton) ...[
          const SizedBox(height: 14),
          // Hide renew button when auto-renew is ON
          BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
            bloc: instance<DeviceLimitsCubit>(),
            buildWhen: (previous, current) =>
                previous.autoRenew != current.autoRenew,
            builder: (context, limitsState) {
              if (limitsState.autoRenew) {
                return const SizedBox.shrink();
              }
              return const _RenewPlanButton();
            },
          ),
        ],
      ],
    );
  }
}

/// HOME-006 is local to prepaid Home; shared plan validity stays unchanged.
class _PlanExpiryWarning extends StatefulWidget {
  const _PlanExpiryWarning({required this.plan});

  final BasePlanModel plan;

  @override
  State<_PlanExpiryWarning> createState() => _PlanExpiryWarningState();
}

class _PlanExpiryWarningState extends State<_PlanExpiryWarning> {
  static const _warningWindow = Duration(days: 3);
  Timer? _updateTimer;

  // In-memory, presentation-only expiry; the plan and its card are untouched.
  late final DateTime? _debugExpiry = debugForcePlanExpiryWarning
      ? DateTime.now().add(const Duration(days: 2))
      : null;

  DateTime? get _warningExpiry => _debugExpiry ?? widget.plan.endDateTime;

  @override
  void initState() {
    super.initState();
    _scheduleUpdate();
  }

  @override
  void didUpdateWidget(covariant _PlanExpiryWarning oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      _scheduleUpdate();
    }
  }

  void _scheduleUpdate() {
    _updateTimer?.cancel();
    final now = DateTime.now();
    final end = _warningExpiry;
    if (end == null || !end.isAfter(now)) {
      return;
    }

    // Update only at a visibility boundary, without polling or fetching plans.
    final boundaries = [
      widget.plan.startDateTime,
      end.subtract(_warningWindow),
      end,
    ].whereType<DateTime>().where((date) => date.isAfter(now)).toList()..sort();
    _updateTimer = Timer(boundaries.first.difference(now), () {
      if (mounted) {
        setState(_scheduleUpdate);
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final now = DateTime.now();
    final start = plan.startDateTime;
    final end = _warningExpiry;
    if (end == null || (start != null && start.isAfter(now))) {
      return const SizedBox.shrink();
    }

    // HOME-007 uses the same banner when the displayed prepaid plan expires.
    final isExpired = !end.isAfter(now);
    if (!isExpired &&
        (end.difference(now) > _warningWindow ||
            plan.planName.trim().isEmpty)) {
      return const SizedBox.shrink();
    }
    final message = isExpired
        ? 'your plan expired on ${end.formatDdMmYy()}. renew or buy a new plan to keep using data.'
        : 'your ${plan.planName} plan expires on ${end.formatDdMmYy()}. renew to stay connected.';
    final actionText = isExpired ? 'purchase a new plan' : 'renew your plan';

    // Real and debug expiry values share the same production banner UI.
    final red = ColorManager.primaryRedFF0000;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: HomePlanTheme.warningBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: red, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: red,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      if (isExpired) {
                        // Reuse the purchase destination from NoActivePlanCard.
                        context.go(AppRoutes.plans);
                      } else {
                        _openPlanRenewal(context);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          actionText,
                          style: TextStyle(
                            color: red,
                            fontSize: 12,
                            fontFamily: 'CircularPro',
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                            decoration: TextDecoration.underline,
                            decorationColor: red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: red, size: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditCardBackground extends StatelessWidget {
  const _CreditCardBackground({required this.assetPath});

  final String assetPath;

  static const double _svgWidth = 372;
  static const double _svgHeight = 182;
  static const double _homeSvgHeight = 232;
  static const double _cardLeft = 8;
  static const double _cardTop = 6;
  static const double _cardWidth = 340;
  static const double _cardHeight = 150;
  static const double _homeCardHeight = 200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The SVG canvas includes Figma shadow gutters; crop to the card rect.
        final isHomeRedCard = assetPath == AssetConstant.homeRedCardSVG;
        final svgHeight = isHomeRedCard ? _homeSvgHeight : _svgHeight;
        final cardHeight = isHomeRedCard ? _homeCardHeight : _cardHeight;
        final backgroundWidth = constraints.maxWidth * _svgWidth / _cardWidth;
        final backgroundHeight = constraints.maxHeight * svgHeight / cardHeight;
        final leftOffset = constraints.maxWidth * _cardLeft / _cardWidth;
        final topOffset = constraints.maxHeight * _cardTop / cardHeight;

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: backgroundWidth,
            maxHeight: backgroundHeight,
            child: Transform.translate(
              offset: Offset(-leftOffset, -topOffset),
              child: SizedBox(
                width: backgroundWidth,
                height: backgroundHeight,
                child: SvgPicture.asset(assetPath, fit: BoxFit.fill),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Top row with "active plan" label and auto-renew toggle
class _TopRow extends StatelessWidget {
  const _TopRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Auto-renew toggle using DeviceLimitsCubit
        BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
          bloc: instance<DeviceLimitsCubit>(),
          buildWhen: (previous, current) =>
              previous.autoRenew != current.autoRenew ||
              previous.isTogglingAutoRenew != current.isTogglingAutoRenew,
          builder: (context, state) {
            return _AutoRenewToggle(
              value: state.autoRenew,
              isLoading: state.isTogglingAutoRenew,
            );
          },
        ),
      ],
    );
  }
}

/// Auto-renew toggle (interactive)
class _AutoRenewToggle extends StatefulWidget {
  const _AutoRenewToggle({required this.value, this.isLoading = false});

  final bool value;
  final bool isLoading;

  @override
  State<_AutoRenewToggle> createState() => _AutoRenewToggleState();
}

class _AutoRenewToggleState extends State<_AutoRenewToggle> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  @override
  void didUpdateWidget(covariant _AutoRenewToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      isOn = widget.value;
    }
  }

  Future<void> _handleTap() async {
    // Don't allow tap while loading
    if (widget.isLoading) return;

    // Optimistically flip the visual; the cubit will reconcile via didUpdateWidget.
    setState(() => isOn = !isOn);

    await handleAutoRenewToggle(context, currentValue: widget.value);

    // Reconcile against the latest authoritative value once the action settles.
    if (mounted) {
      setState(() => isOn = widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _handleTap,
      child: Opacity(
        opacity: widget.isLoading ? 0.6 : 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 24.0,
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFDCDCDC), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                textDirection: isOn ? TextDirection.ltr : TextDirection.rtl,
                children: [
                  if (widget.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.5),
                      child: SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF645D9C),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Text(
                        isOn ? 'on' : 'off',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          color: isOn ? Colors.black : const Color(0xFF707070),
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: isOn
                          ? const Color(0xFF645D9C)
                          : const Color(0xFF707070),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOn ? Icons.check : Icons.close,
                      size: 15.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'auto renew',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w400,
                fontVariations: <FontVariation>[FontVariation('wght', 450)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dates row showing active and expire dates
class _DatesRow extends StatelessWidget {
  const _DatesRow({
    required this.activeDate,
    required this.expireDate,
    this.expireTime = '',
  });

  final String activeDate;
  final String expireDate;
  final String expireTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DateBlock(title: 'active', value: activeDate),
        const Spacer(),
        _DateBlock(
          title: 'expire',
          value: expireDate,
          subtitle: expireTime,
          alignRight: true,
        ),
      ],
    );
  }
}

/// Date block (active/expire)
class _DateBlock extends StatelessWidget {
  const _DateBlock({
    required this.title,
    required this.value,
    this.subtitle = '',
    this.alignRight = false,
  });

  final String title;
  final String value;
  final String subtitle;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            letterSpacing: 2.25,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Existing renewal flow shared by the active-card button and warning link.
void _openPlanRenewal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (_) => const AutoRenewBottomSheet(),
  );
}

/// Renew button for active plan card.
class _RenewPlanButton extends StatelessWidget {
  const _RenewPlanButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _openPlanRenewal(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF3F4FA),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/card-add.svg',
              width: 18,
              height: 18,
              colorFilter: const ColorFilter.mode(
                Color(0xFFEF3A4B),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'renew your plan',
              style: TextStyle(
                color: Color(0xFFEF3A4B),
                fontSize: 15,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
