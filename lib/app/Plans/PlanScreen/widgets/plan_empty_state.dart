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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            if (showRefreshButton) ...[
              const SizedBox(height: 32),
              // Refresh button
              SizedBox(
                width: 160,
                child: DefaultButton(
                  label: 'Refresh',
                  isLoading: false,
                  onPressed: onRefresh,
                  backgroundColor: HomePlanTheme.planCardBackgroundColor,
                  textColor: const Color(0xFF6D0DB8),
                  borderSide: const BorderSide(
                    color: Color(0xFF6D0DB8),
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                  horizontal: 32,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            // Error message
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            // Retry button
            SizedBox(
              width: 160,
              child: DefaultButton(
                label: 'Try Again',
                isLoading: false,
                onPressed: onRetry,
                backgroundColor: const Color(0xFF6D0DB8),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
