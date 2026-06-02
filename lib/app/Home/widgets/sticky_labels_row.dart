import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sticky labels row drawn above a horizontally scrolling cards list.
///
/// [activeLabel] is pinned to [leadingPad]. [roamingLabel]'s natural position
/// tracks the first roaming card (so it scrolls left with the cards). When
/// the roaming label's natural position would overlap the active label, the
/// active label is pushed left and clipped — iOS section-header style.
///
/// Geometry inputs ([leadingPad], [labelGap], [roamingStartX]) come from the
/// parent so this widget stays a pure presentation component.
class StickyLabelsRow extends StatelessWidget {
  const StickyLabelsRow({
    super.key,
    required this.scrollController,
    required this.leadingPad,
    required this.labelGap,
    required this.activeLabel,
    required this.roamingLabel,
    required this.roamingStartX,
    required this.style,
  });

  final ScrollController scrollController;
  final double leadingPad;
  final double labelGap;
  final String activeLabel;
  final String? roamingLabel;
  final double roamingStartX;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final activeWidth = _measureWidth(activeLabel);
    final height = math.max(
      _measureHeight(activeLabel),
      _measureHeight(roamingLabel ?? ''),
    );

    if (height == 0) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: AnimatedBuilder(
        animation: scrollController,
        builder: (context, _) {
          final offset =
              scrollController.hasClients ? scrollController.offset : 0.0;

          final roamingNaturalX = leadingPad + roamingStartX - offset;
          final roamingX = roamingLabel == null
              ? double.infinity
              : math.max(leadingPad, roamingNaturalX);

          double activeX = leadingPad;
          if (roamingLabel != null) {
            final pushedX = roamingNaturalX - activeWidth - labelGap;
            if (pushedX < leadingPad) {
              activeX = pushedX;
            }
          }

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (activeLabel.isNotEmpty)
                Positioned(
                  left: activeX,
                  top: 0,
                  child: Text(
                    activeLabel,
                    style: style,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              if (roamingLabel != null)
                Positioned(
                  left: roamingX,
                  top: 0,
                  child: Text(
                    roamingLabel!,
                    style: style,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _measureWidth(String text) {
    if (text.isEmpty) return 0;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

  double _measureHeight(String text) {
    if (text.isEmpty) return 0;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.height;
  }
}
