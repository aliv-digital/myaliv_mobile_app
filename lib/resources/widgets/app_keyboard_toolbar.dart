import 'package:flutter/material.dart';

/// Reusable keyboard navigation toolbar that keeps "Next" and "Done" actions
/// visible directly above the software keyboard for multi-field forms.
///
/// When an intermediate field in [focusNodes] is focused, it displays a "Next"
/// action that shifts focus to the next field in the list.
/// When the last field in [focusNodes] is focused, it displays a "Done" action
/// that unfocuses the field and invokes [onDone], unless [showDoneButton] is false.
class AppKeyboardToolbar extends StatefulWidget {
  const AppKeyboardToolbar({
    super.key,
    required this.focusNodes,
    this.onDone,
    this.backgroundColor = Colors.white,
    this.buttonColor = const Color(0xFF645D9C),
    this.nextLabel = 'Next',
    this.doneLabel = 'Done',
    this.showDoneButton = true,
    required this.child,
  });

  /// The list of [FocusNode]s in logical traversal order.
  final List<FocusNode> focusNodes;

  /// Callback executed when the 'Done' button is pressed on the final field.
  final VoidCallback? onDone;

  /// Background color of the toolbar bar.
  final Color backgroundColor;

  /// Text color of the 'Next' and 'Done' action buttons.
  final Color buttonColor;

  /// Label for the next button (defaults to 'Next').
  final String nextLabel;

  /// Label for the done button (defaults to 'Done').
  final String doneLabel;

  /// Whether to display the toolbar when the final field in [focusNodes] is focused.
  /// When false, the toolbar automatically hides on the final field.
  final bool showDoneButton;

  /// The child widget tree (usually a Scaffold or ScrollView).
  final Widget child;

  @override
  State<AppKeyboardToolbar> createState() => _AppKeyboardToolbarState();
}

class _AppKeyboardToolbarState extends State<AppKeyboardToolbar>
    with WidgetsBindingObserver {
  final OverlayPortalController _overlayController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attachListeners(widget.focusNodes);
  }

  @override
  void didChangeMetrics() {
    if (mounted) {
      _updateToolbar();
    }
  }

  @override
  void didUpdateWidget(covariant AppKeyboardToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_areListsEqual(oldWidget.focusNodes, widget.focusNodes) ||
        oldWidget.showDoneButton != widget.showDoneButton) {
      _detachListeners(oldWidget.focusNodes);
      _attachListeners(widget.focusNodes);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateToolbar();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detachListeners(widget.focusNodes);
    super.dispose();
  }

  bool _areListsEqual(List<FocusNode> a, List<FocusNode> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _attachListeners(List<FocusNode> nodes) {
    for (final node in nodes) {
      node.addListener(_updateToolbar);
    }
  }

  void _detachListeners(List<FocusNode> nodes) {
    for (final node in nodes) {
      node.removeListener(_updateToolbar);
    }
  }

  void _updateToolbar() {
    if (!mounted) return;
    final focusedIndex = widget.focusNodes.indexWhere((node) => node.hasFocus);
    final isLast =
        focusedIndex != -1 && focusedIndex == widget.focusNodes.length - 1;
    final shouldShow = focusedIndex != -1 && (!isLast || widget.showDoneButton);

    if (shouldShow) {
      if (!_overlayController.isShowing) {
        _overlayController.show();
      }
    } else {
      if (_overlayController.isShowing) {
        _overlayController.hide();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.maybeViewInsetsOf(context);
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        final mediaInset = MediaQuery.viewInsetsOf(context).bottom;
        final view = View.of(context);
        final rawViewInset = view.viewInsets.bottom / view.devicePixelRatio;
        final keyboardInset = mediaInset > 0 ? mediaInset : rawViewInset;

        final focusedIndex = widget.focusNodes.indexWhere(
          (node) => node.hasFocus,
        );

        if (focusedIndex == -1 || keyboardInset <= 0) {
          return const SizedBox.shrink();
        }

        final isLast = focusedIndex == widget.focusNodes.length - 1;
        if (isLast && !widget.showDoneButton) {
          return const SizedBox.shrink();
        }

        final label = isLast ? widget.doneLabel : widget.nextLabel;

        void handlePress() {
          if (isLast) {
            widget.focusNodes[focusedIndex].unfocus();
            widget.onDone?.call();
          } else {
            widget.focusNodes[focusedIndex + 1].requestFocus();
          }
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: keyboardInset,
          child: ExcludeFocus(
            child: Material(
              color: widget.backgroundColor,
              elevation: 2,
              child: SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextButton(
                      onPressed: handlePress,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: widget.buttonColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: 'CircularPro',
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
