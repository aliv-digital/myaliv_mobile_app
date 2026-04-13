import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_state.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/models/best_plan_model.dart';

/// Self-contained Best Plans widget
///
/// This widget handles:
/// - BlocBuilder for state management
/// - Conditional rendering (shows only when plans are available)
/// - Horizontal scrolling list of plan cards
/// - Click handling (opens plan link)
/// - Error handling
/// - Uses CachedNetworkImage for background images
///
/// Usage in HomeScreen:
/// ```dart
/// import 'package:myaliv_mobile_app/app/Home/best-plans/view/best_plans_view.dart';
///
/// // In build method:
/// BestPlansView(),
/// ```
class BestPlansView extends StatelessWidget {
  const BestPlansView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BestPlanCubit, BestPlanState>(
      builder: (context, state) {
        // Don't show widget if:
        // - No plans available
        // - Still loading
        // - State is empty
        if (!state.hasPlans || state.isLoading || state.isEmpty) {
          return const SizedBox.shrink();
        }

        final plans = state.plans;
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth * 0.75; // 3/4 screen width

        return Container(
          decoration: const BoxDecoration(color: Colors.white),
          height: 170,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 11),
            scrollDirection: Axis.horizontal,
            itemCount: plans.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final plan = plans[index];
              return SizedBox(
                width: cardWidth,
                child: _BestPlanCard(
                  plan: plan,
                  height: 170,
                  onTap: () => _handleTap(context, plan.link),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Handle tap on plan card
  ///
  /// Opens the plan link in external browser if available
  void _handleTap(BuildContext context, String? link) {
    if (link == null || link.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(link);
    if (uri == null) {
      return;
    }

    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((error) {
      // Silently fail if URL can't be opened
      debugPrint('Failed to open plan link: $error');
      return false;
    });
  }
}

/// Individual plan card with background image and text overlay
class _BestPlanCard extends StatelessWidget {
  final BestPlanModel plan;
  final double height;
  final VoidCallback? onTap;

  const _BestPlanCard({
    required this.plan,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Fallback color if image fails to load
          color: const Color(0xFF645D9C),
        ),
        child: Stack(
          children: [
            // Background image using CachedNetworkImage
            if (plan.backgroundImageUrl != null &&
                plan.backgroundImageUrl!.isNotEmpty)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: plan.backgroundImageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF645D9C),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            color: Colors.white54, size: 48),
                      ),
                    ),
                  ),
                ),
              ),

            // Text overlay (right-aligned)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 24, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price
                          Text(
                            plan.price,
                            style: const TextStyle(
                              fontFamily: 'CircularPro',
                              fontSize: 50,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.25,
                            ),
                          ),
                          const Spacer(),

                          // Plan name and sub-heading
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                plan.planName,
                                style: const TextStyle(
                                  fontFamily: 'CircularPro',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.12,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                plan.subHeading,
                                style: const TextStyle(
                                  color: Color(0xFFE5D0D0),
                                  fontSize: 13,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.07,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
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
