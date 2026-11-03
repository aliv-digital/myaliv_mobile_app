import 'package:flutter/material.dart';

import '../theme/login_theme.dart';

/// Shows a "Done" action above the software keyboard when the password field
/// is focused. Tapping "Done" dismisses the keyboard and triggers the sign-in
/// callback, mirroring [LoginKeyboardNextToolbar] for the phone field.
class LoginKeyboardDoneToolbar extends StatefulWidget {
  const LoginKeyboardDoneToolbar({
    super.key,
    required this.passwordFocusNode,
    required this.onDone,
    required this.child,
  });

  final FocusNode passwordFocusNode;
  final VoidCallback onDone;
  final Widget child;

  @override
  State<LoginKeyboardDoneToolbar> createState() =>
      _LoginKeyboardDoneToolbarState();
}

class _LoginKeyboardDoneToolbarState extends State<LoginKeyboardDoneToolbar> {
  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    widget.passwordFocusNode.addListener(_updateToolbar);
  }

  @override
  void didUpdateWidget(covariant LoginKeyboardDoneToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passwordFocusNode != widget.passwordFocusNode) {
      oldWidget.passwordFocusNode.removeListener(_updateToolbar);
      widget.passwordFocusNode.addListener(_updateToolbar);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateToolbar();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.passwordFocusNode.removeListener(_updateToolbar);
    super.dispose();
  }

  void _updateToolbar() {
    if (widget.passwordFocusNode.hasFocus) {
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
        if (!widget.passwordFocusNode.hasFocus || keyboardInset <= 0) {
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
                      onPressed: () {
                        widget.passwordFocusNode.unfocus();
                        widget.onDone();
                      },
                      child: Text(
                        'Done',
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
