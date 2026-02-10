import 'dart:io';
import 'package:flutter/material.dart';

class KeyboardDoneOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    if (!Platform.isIOS || _entry != null) return;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    _entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: bottomInset,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F2),
              border: Border(
                top: BorderSide(color: Color(0xFFD0D0D0)),
              ),
            ),
            child: Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    hide();
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
