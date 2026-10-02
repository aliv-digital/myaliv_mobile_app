import 'package:flutter/material.dart';

import '../theme/login_theme.dart';

/// Keeps the phone field's Next action visible above the software keyboard.
class LoginKeyboardNextToolbar extends StatefulWidget {
  const LoginKeyboardNextToolbar({
    super.key,
    required this.phoneFocusNode,
    required this.onNext,
    required this.child,
  });

  final FocusNode phoneFocusNode;
  final VoidCallback onNext;
  final Widget child;

  @override
  State<LoginKeyboardNextToolbar> createState() =>
      _LoginKeyboardNextToolbarState();
}

class _LoginKeyboardNextToolbarState extends State<LoginKeyboardNextToolbar> {
  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    widget.phoneFocusNode.addListener(_updateToolbar);
  }

  @override
  void didUpdateWidget(covariant LoginKeyboardNextToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneFocusNode != widget.phoneFocusNode) {
      oldWidget.phoneFocusNode.removeListener(_updateToolbar);
      widget.phoneFocusNode.addListener(_updateToolbar);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateToolbar();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.phoneFocusNode.removeListener(_updateToolbar);
    super.dispose();
  }

  void _updateToolbar() {
    if (widget.phoneFocusNode.hasFocus) {
      _overlayController.show();
    } else {
      _overlayController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
        if (!widget.phoneFocusNode.hasFocus || keyboardInset <= 0) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: keyboardInset,
          child: ExcludeFocus(
            child: Material(
              color: AuthModuleColors.pageBackground,
              elevation: 2,
              child: SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextButton(
                      onPressed: widget.onNext,
                      child: Text(
                        'Next',
                        style: AuthModuleTextStyles.fieldValue.copyWith(
                          color: AuthModuleColors.alivPurple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
