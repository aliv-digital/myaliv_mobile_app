import 'package:flutter/material.dart';
import '../theme/add_or_edit_cards_prepaid_theme.dart';
import 'dashed_border_painter.dart';

class DashedAddCardButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const DashedAddCardButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ make border color stronger (deep)
    final borderColor = AddOrEditCardsPrepaidTheme.dashedBorder.withOpacity(1.0);

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(999),
      child: CustomPaint(
        painter: DeepDashedRRectPainter(
          color: borderColor,
          // ✅ make it bold + visible
          strokeWidth: 4.8,
          haloWidth: 3.2,          // ✅ halo makes dash pop
          haloOpacity: 0.18,       // ✅ subtle glow, not ugly
          radius: 999,
          dash: 5,                // ✅ longer dash = more visible
          gap: 8,                  // ✅ clearer gap
        ),
        child: Container(
          width: double.infinity,
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AddOrEditCardsPrepaidTheme.pageBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AddOrEditCardsPrepaidTheme.primary,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 26,
                      color: AddOrEditCardsPrepaidTheme.dashedBorder,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'add a new card',
                      style: TextStyle(
                        color: Color(0xFF645D9C),
                        fontSize: 15,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                        height: 1.54,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
