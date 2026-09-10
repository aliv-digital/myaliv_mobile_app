import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton shimmer shown while the payment gateway is loading.
///
/// Mimics the shape of a typical PowerTranz card-payment page so the
/// transition from shimmer → real content feels natural rather than jarring.
class PaymentShimmerWidget extends StatelessWidget {
  const PaymentShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Provider logo / header bar
              _shimmerBox(width: 140, height: 36, radius: 8),
              const SizedBox(height: 32),

              // Section title
              _shimmerBox(width: 120, height: 14, radius: 4),
              const SizedBox(height: 16),

              // Card number field
              _shimmerBox(width: double.infinity, height: 52, radius: 10),
              const SizedBox(height: 14),

              // Expiry + CVV row
              Row(
                children: [
                  Expanded(child: _shimmerBox(width: double.infinity, height: 52, radius: 10)),
                  const SizedBox(width: 12),
                  Expanded(child: _shimmerBox(width: double.infinity, height: 52, radius: 10)),
                ],
              ),
              const SizedBox(height: 14),

              // Cardholder name field
              _shimmerBox(width: double.infinity, height: 52, radius: 10),
              const SizedBox(height: 32),

              // Divider
              _shimmerBox(width: double.infinity, height: 1, radius: 0),
              const SizedBox(height: 24),

              // Order summary label
              _shimmerBox(width: 100, height: 14, radius: 4),
              const SizedBox(height: 14),

              // Amount row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(width: 80, height: 14, radius: 4),
                  _shimmerBox(width: 60, height: 14, radius: 4),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(width: 60, height: 12, radius: 4),
                  _shimmerBox(width: 50, height: 12, radius: 4),
                ],
              ),
              const SizedBox(height: 32),

              // Pay button
              _shimmerBox(width: double.infinity, height: 50, radius: 10),
              const SizedBox(height: 16),

              // Security badges row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _shimmerBox(width: 60, height: 24, radius: 4),
                  const SizedBox(width: 12),
                  _shimmerBox(width: 60, height: 24, radius: 4),
                  const SizedBox(width: 12),
                  _shimmerBox(width: 60, height: 24, radius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
