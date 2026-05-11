import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_state.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/models/best_plan_model.dart';

class AllBestPlansScreen extends StatelessWidget {
  const AllBestPlansScreen({super.key});

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: purple,
          elevation: 0,
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          title: const Text(
            'our best plans',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        body: BlocBuilder<BestPlanCubit, BestPlanState>(
          builder: (context, state) {
            // Loading state
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(purple),
                ),
              );
            }

            // Error state
            if (state.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage ?? 'Failed to load plans',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Retry loading
                          final userType =
                              context.read<BestPlanCubit>().state.plans.isNotEmpty
                                  ? context.read<BestPlanCubit>().state.plans.first.type
                                  : 'prepaid';
                          context.read<BestPlanCubit>().loadPlans(
                                userType: userType,
                                forceRefresh: true,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Empty state
            if (state.isEmpty || !state.hasPlans) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No plans available right now',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'CircularPro',
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Success state with plans
            final plans = state.plans;

            return ListView.separated(
              padding: const EdgeInsets.all(25),
              itemCount: plans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final plan = plans[index];
                return _PlanCard(
                  plan: plan,
                  onTap: () => _handleTap(context, plan.link),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Handle tap on plan card
  void _handleTap(BuildContext context, String? link) {
    if (link == null || link.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(link);
    if (uri == null) {
      return;
    }

    launchUrl(uri, mode: LaunchMode.externalApplication).catchError((error) {
      debugPrint('Failed to open plan link: $error');
      return false;
    });
  }
}

class _PlanCard extends StatelessWidget {
  final BestPlanModel plan;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.plan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 170,
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 24, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price
                          Text(
                            "\$${plan.price}",
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
