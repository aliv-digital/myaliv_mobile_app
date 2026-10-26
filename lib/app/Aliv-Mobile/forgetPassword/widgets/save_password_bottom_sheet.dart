import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Prompts the user to cache their newly-reset password in `CredentialStore`
/// for faster biometric sign-in next time.
///
/// Returns `true` when the user taps "save password"; `false` otherwise.
class SavePasswordBottomSheet extends StatelessWidget {
  const SavePasswordBottomSheet._();

  static const Color _primary = Color(0xFF645D9C);
  static const Color _iconBadgeBg = Color(0xFFF2F0FA);
  static const Color _textPrimary = Color(0xFF121212);
  static const Color _textSecondary = Color(0xFF707070);
  static const Color _closeIcon = Color(0xFF121212);

  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      // Attach to the root navigator so the sheet survives the GoRouter
      // route change to home that happens immediately after this call.
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const SavePasswordBottomSheet._(),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48.0,
                  height: 48.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _iconBadgeBg,
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: SvgPicture.asset('assets/icons/featured_icon.svg'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: _closeIcon,
                    fontWeight: FontWeight.bold,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: _closeIcon, width: 2.0),
                    shape: const CircleBorder(
                      side: BorderSide(color: _closeIcon),
                    ),
                    padding: const EdgeInsets.all(6),
                    minimumSize: const Size(32, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'save your password?',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                height: 1.56,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'would you like to save your password for faster sign-in next '
              'time?',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: const BorderSide(color: Color(0xFFF1F1F8)),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'not now',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'save password',
                        style: TextStyle(
                          color: Color(0xFFF1F1F8),
                          fontSize: 15,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
