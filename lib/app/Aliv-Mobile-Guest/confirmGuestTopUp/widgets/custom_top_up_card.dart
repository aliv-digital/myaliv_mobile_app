import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CustomTopUpCard extends StatelessWidget {
  final String title;
  final String phoneNumber;
  final double amount;

  const CustomTopUpCard({
    super.key,
    required this.title,
    required this.phoneNumber,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top-up title and phone number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TopUpConfirmTheme.customCardTitle,
                ),
                Text(
                  phoneNumber,
                  style: TopUpConfirmTheme.customCardPhone,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey),
            const SizedBox(height: 8),
            // Updated Top-up amount holder with button-like styling
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top-up amount',
                  style: TopUpConfirmTheme.customCardLabel,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TopUpConfirmTheme.customCardAmount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
