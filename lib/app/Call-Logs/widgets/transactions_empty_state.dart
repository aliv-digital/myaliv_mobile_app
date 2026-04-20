import 'package:flutter/material.dart';

/// Empty state widget for transactions
class TransactionsEmptyState extends StatelessWidget {
  final String message;

  const TransactionsEmptyState({
    super.key,
    this.message = 'No transactions found for this month',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF858692),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget for transactions
class TransactionsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const TransactionsErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF858692),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF645D9C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    color: Colors.white,
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
