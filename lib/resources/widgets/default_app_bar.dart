import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

/// DefaultAppBar (Reusable)
/// - Back optional
/// - Right actions: skip/text button OR custom widget OR icons (home/notification)
class DefaultAppBar extends StatelessWidget {
  const DefaultAppBar({
    super.key,
    required this.title,

    // Layout
    this.height = 56,
    this.backgroundColor = const Color(0xFF645D9C),
    this.horizontalPadding = 12,
    this.titleAlignment = AppBarTitleAlignment.left,
    this.centerTitle = false,

    // Back
    this.showBackArrow = true,
    this.onBack,
    this.backIconAssetPath = AssetConstant.whiteBackArrowIconPNG,
    this.backIconSize = 24,
    this.backSplashRadius = 22,
    this.leading,

    // Right side (actions)
    this.trailing,
    this.actionText,
    this.onActionTextTap,
    this.actionTextStyle,

    // ✅ Home (NEW)
    this.showHome = false,
    this.homeIcon = Icons.home_outlined,
    this.onHomeTap,
    this.homeCount,

    // Notification
    this.showNotification = false,
    this.notificationIcon = Icons.notifications_none_rounded,
    this.onNotificationTap,
    this.notificationCount,
    this.showNotificationDotWhenZero = false,

    // Divider / shadow
    this.showBottomDivider = false,
    this.bottomDividerColor = const Color(0x1AFFFFFF),
    this.elevationShadow = false,
  });

  final String title;

  // Layout
  final double height;
  final Color backgroundColor;
  final double horizontalPadding;
  final AppBarTitleAlignment titleAlignment;
  final bool centerTitle;

  // Back / Leading
  final bool showBackArrow;
  final VoidCallback? onBack;
  final String backIconAssetPath;
  final double backIconSize;
  final double backSplashRadius;
  final Widget? leading;

  // Trailing / Actions
  final Widget? trailing;
  final String? actionText;
  final VoidCallback? onActionTextTap;
  final TextStyle? actionTextStyle;

  // ✅ Home (NEW)
  final bool showHome;
  final IconData homeIcon;
  final VoidCallback? onHomeTap;
  final int? homeCount;

  // Notification
  final bool showNotification;
  final IconData notificationIcon;
  final VoidCallback? onNotificationTap;
  final int? notificationCount;
  final bool showNotificationDotWhenZero;

  // Divider / shadow
  final bool showBottomDivider;
  final Color bottomDividerColor;
  final bool elevationShadow;

  @override
  Widget build(BuildContext context) {
    final titleStyle = const TextStyle(
      fontSize: 17,
      height: 1.25,
      fontFamily: 'CircularPro',
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Material(
      color: backgroundColor,
      elevation: elevationShadow ? 6 : 0,
      child: Container(
        height: height,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  _buildLeading(context),
                  Expanded(
                    child: Align(
                      alignment: _titleAlign(),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                        textAlign:
                            centerTitle ? TextAlign.center : TextAlign.left,
                      ),
                    ),
                  ),
                  _buildTrailing(context),
                ],
              ),
            ),
            if (showBottomDivider)
              Container(
                height: 1,
                width: double.infinity,
                color: bottomDividerColor,
              ),
          ],
        ),
      ),
    );
  }

  Alignment _titleAlign() {
    if (centerTitle || titleAlignment == AppBarTitleAlignment.center) {
      return Alignment.center;
    }
    return Alignment.centerLeft;
  }

  Widget _buildLeading(BuildContext context) {
    if (leading != null) return leading!;

    if (!showBackArrow) {
      return const SizedBox.shrink();
    }

    return IconButton(
      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      icon: Image.asset(backIconAssetPath),
      color: Colors.white,
      iconSize: backIconSize,
      splashRadius: backSplashRadius,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    if (trailing != null) {
      return SizedBox(
        width: 88,
        child: Align(
          alignment: Alignment.centerRight,
          child: trailing,
        ),
      );
    }

    final actions = <Widget>[];

    // ✅ Home (notification এর মতো)
    if (showHome) {
      actions.add(_HomeButton(
        icon: homeIcon,
        count: homeCount,
        onTap: onHomeTap,
      ));
    }

    // Notification
    if (showNotification) {
      actions.add(_NotificationButton(
        icon: notificationIcon,
        count: notificationCount,
        onTap: onNotificationTap,
        showDotWhenZero: showNotificationDotWhenZero,
      ));
    }

    // Text action (e.g., "skip")
    if (actionText != null && actionText!.trim().isNotEmpty) {
      actions.add(
        GestureDetector(
          onTap: onActionTextTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Text(
              actionText!,
              style: actionTextStyle ??
                  const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox(width: 88);
    }

    return SizedBox(
      width: 88,
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showBadge = (count ?? 0) > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (showBadge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE62B2F),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Text(
                    count! > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.showDotWhenZero,
  });

  final IconData icon;
  final int? count;
  final VoidCallback? onTap;
  final bool showDotWhenZero;

  @override
  Widget build(BuildContext context) {
    final countValue = count ?? 0;
    final showCountBadge = countValue > 0;
    final showDotBadge = countValue == 0 && showDotWhenZero;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            if (showCountBadge)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE62B2F),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Text(
                    countValue > 99 ? '99+' : '$countValue',
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (showDotBadge)
              const Positioned(
                right: 0,
                top: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFEE3434),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 8, height: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum AppBarTitleAlignment { left, center }
