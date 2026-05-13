import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';

/// Empty state widget shown when no plans are available
/// Includes a refresh button to retry loading
class PlanEmptyState extends StatelessWidget {
  const PlanEmptyState({
    super.key,
    required this.message,
    required this.onRefresh,
    this.showRefreshButton = true,
  });

  final String message;
  final VoidCallback onRefresh;
  final bool showRefreshButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                if (showRefreshButton) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    child: DefaultButton(
                      label: 'refresh',
                      isLoading: false,
                      onPressed: onRefresh,
                      backgroundColor: HomePlanTheme.planCardBackgroundColor,
                      textColor: const Color(0xFF645D9C),
                      borderSide: const BorderSide(
                        color: Color(0xFF645D9C),
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown on the add-ons tab when the user has no active primary plan.
/// Add-ons can't be purchased without one — CTA switches the tab strip
/// back to a primary-plan tab.
class AddOnsNoPrimaryPlanState extends StatelessWidget {
  const AddOnsNoPrimaryPlanState({
    super.key,
    required this.onPurchasePlan,
  });

  final VoidCallback onPurchasePlan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'you have no active primary plan, to purchase an add-on you must purchase a primary plan click purchase!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onPurchasePlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF645D9C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'purchase plan',
                    style: TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget for plan screen
class PlanErrorState extends StatelessWidget {
  const PlanErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 160,
                  child: DefaultButton(
                    label: 'try again',
                    isLoading: false,
                    onPressed: onRetry,
                    backgroundColor: const Color(0xFF645D9C),
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
