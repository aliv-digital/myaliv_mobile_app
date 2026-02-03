import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/settings_theme.dart';

class SettingsNavTile extends StatelessWidget {
  final String iconAsset; // ✅ svg asset path
  final String title;
  final VoidCallback onTap;

  const SettingsNavTile({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: SettingsTheme.tileHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _IconCircle(svgAsset: iconAsset),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: SettingsTheme.tileText),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: SettingsTheme.chevron,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final String svgAsset;

  const _IconCircle({required this.svgAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: SettingsTheme.iconCircleBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
