import 'package:flutter/material.dart';

import '../theme/forget_password_theme.dart';

/// Shows a dismiss-only action while the phone field's keyboard is visible.
class ForgetPasswordKeyboardDoneToolbar extends StatefulWidget {
  const ForgetPasswordKeyboardDoneToolbar({
    super.key,
    required this.phoneFocusNode,
    required this.child,
  });

  final FocusNode phoneFocusNode;
  final Widget child;

  @override
  State<ForgetPasswordKeyboardDoneToolbar> createState() =>
      _ForgetPasswordKeyboardDoneToolbarState();
}

class _ForgetPasswordKeyboardDoneToolbarState
    extends State<ForgetPasswordKeyboardDoneToolbar> {
  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    widget.phoneFocusNode.addListener(_updateToolbar);
  }

  @override
  void didUpdateWidget(covariant ForgetPasswordKeyboardDoneToolbar oldWidget) {
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
              color: ForgetPasswordColors.pageBackground,
              elevation: 2,
              child: SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextButton(
                      onPressed: widget.phoneFocusNode.unfocus,
                      child: Text(
                        'Done',
                        style: ForgetPasswordTheme.phoneInput.copyWith(
                          color: ForgetPasswordColors.actionLinkPurple,
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
