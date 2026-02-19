import 'dart:async';
import 'package:flutter/material.dart';


final GlobalKey<NavigatorState> rootNavigatorKey =
GlobalKey<NavigatorState>();


enum ToastType { success, error }

class AppToast {
  static OverlayEntry? _currentToast;

  static void show({
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _currentToast?.remove();

    final isSuccess = type == ToastType.success;

    final backgroundColor =
    isSuccess ? const Color(0xFF4DDBC0) : const Color(0xFFE54848);

    final textColor =
    isSuccess ? const Color(0xFF084338) : Colors.white;

    final iconColor =
    isSuccess ? const Color(0xFF094338) : Colors.white;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQueryData.fromWindow(
            WidgetsBinding.instance.window)
            .padding
            .top +
            16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Color(0x19000000),
                      blurRadius: 24,
                      offset: Offset(0, 4),
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess ? Icons.check : Icons.close,
                        size: 14,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    _currentToast = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      _currentToast?.remove();
      _currentToast = null;
    });
  }

}
