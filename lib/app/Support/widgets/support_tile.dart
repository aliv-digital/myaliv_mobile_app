import 'package:flutter/material.dart';

class SupportTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final bool isLoading;
  final String loadingLabel;

  const SupportTile({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
    this.loadingLabel = 'opening browser...',
  });

  static const Color divider = Color(0xFFE1E1E1);
  static const Color _loadingColor = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: divider, width: 1)),
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
            if (isLoading)
              _SupportTileLoadingIndicator(
                color: _loadingColor,
                label: loadingLabel,
              )
            else
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

class _SupportTileLoadingIndicator extends StatelessWidget {
  final Color color;
  final String label;

  const _SupportTileLoadingIndicator({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 132),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
