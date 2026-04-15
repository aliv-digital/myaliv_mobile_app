import 'package:flutter/material.dart';

const Color _purple = Color(0xFF645D9C);

class MyLimitsLoadingState extends StatelessWidget {
  const MyLimitsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(color: _purple),
      ),
    );
  }
}

class MyLimitsErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const MyLimitsErrorState({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Failed to load limits',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF707070),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: _purple,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyLimitsEmptyState extends StatelessWidget {
  const MyLimitsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No limits available',
          style: TextStyle(
            color: Color(0xFF707070),
            fontSize: 14,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
