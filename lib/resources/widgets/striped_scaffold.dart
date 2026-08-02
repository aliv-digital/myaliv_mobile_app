import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';

/// Standard app scaffold that pins the 5-color bottom stripe strip flush
/// against the system nav bar and paints the empty area above it in the
/// shared page background (#F4F6FB by default).
///
/// Use this instead of building `Scaffold` + `BottomStripes` manually so every
/// screen keeps the same look below the last piece of content.
class StripedScaffold extends StatelessWidget {
  const StripedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor = defaultBackgroundColor,
    this.resizeToAvoidBottomInset,
    this.drawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.stripesReserveSpace = false,
  });

  static const Color defaultBackgroundColor = Color(0xFFF4F6FB);

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final Widget? drawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;

  /// When true, reserves stripe-height padding at the bottom of `body` so
  /// scrollable content does not slide behind the stripes. Leave false when
  /// the body already handles its own bottom padding or intentionally paints
  /// behind the stripes.
  final bool stripesReserveSpace;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final showStripes = !keyboardOpen;

    final reservedBottom =
        (stripesReserveSpace && showStripes) ? BottomStripes.kHeight : 0.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: reservedBottom),
              child: body,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Offstage(
              offstage: !showStripes,
              child: const BottomStripes(),
            ),
          ),
        ],
      ),
    );
  }
}
