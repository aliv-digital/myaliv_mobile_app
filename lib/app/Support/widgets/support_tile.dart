import 'package:flutter/material.dart';

class SupportTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SupportTile({
    super.key,
    required this.title,
    this.onTap,
  });

  static const Color divider = Color(0xFFE1E1E1);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: divider, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1C),
                  letterSpacing: -0.26,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF1C1C1C),
            ),
          ],
        ),
      ),
    );
  }
}
