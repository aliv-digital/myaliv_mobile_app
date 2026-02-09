import 'package:flutter/material.dart';
import '../theme/add_or_edit_cards_prepaid_theme.dart';
import 'dashed_border_painter.dart';

class DashedAddCardButton extends StatelessWidget {
  final VoidCallback onTap;

  const DashedAddCardButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ make border color stronger (deep)
    final borderColor = AddOrEditCardsPrepaidTheme.dashedBorder.withOpacity(1.0);

    return InkWell(
      onTap: onTap,
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.add,
                size: 26,
                color: AddOrEditCardsPrepaidTheme.dashedBorder,
              ),
              SizedBox(width: 10),
              Text(
                'add a new card',
                style: TextStyle(
                  color: const Color(0xFF645D9C),
                  fontSize: 13,
                  fontFamily: 'Circular Pro',
                  fontWeight: FontWeight.w500,
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
