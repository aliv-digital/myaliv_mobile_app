import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/settings_theme.dart';

class SettingsToggleTile extends StatelessWidget {
  final String iconAsset; // svg asset path
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleTile({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SettingsTheme.tileHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            _IconCircle(svgAsset: iconAsset),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: SettingsTheme.tileText.copyWith(
                  fontSize: 16, // figma-like bigger
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _FigmaToggle(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final String svgAsset;

  const _IconCircle({required this.svgAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        child: SvgPicture.asset(
          svgAsset,
          width: 18,
          height: 18,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Pixel-perfect toggle (matches provided figma screenshot)
// class _FigmaToggle extends StatelessWidget {
//   const _FigmaToggle({
//     required this.value,
//     required this.onChanged,
//   });
//
//   final bool value;
//   final ValueChanged<bool> onChanged;
//
//   static const double _w = 70;
//   static const double _h = 34;
//   static const double _pad = 3;
//   static const double _knob = 28;
//
//   @override
//   Widget build(BuildContext context) {
//     final trackColor = value ? SettingsTheme.appBarBg : Colors.white;
//     final borderColor = value ? Colors.transparent : const Color(0xFFE5E7EB);
//
//     return GestureDetector(
//       behavior: HitTestBehavior.opaque,
//       child: SvgPicture.asset('assets/icons/Toggle=Off.svg'));
//     //   AnimatedContainer(
//     //     duration: const Duration(milliseconds: 180),
//     //     curve: Curves.easeOut,
//     //     width: _w,
//     //     height: _h,
//     //     padding: const EdgeInsets.all(_pad),
//     //     decoration: BoxDecoration(
//     //       color: trackColor,
//     //       borderRadius: BorderRadius.circular(100),
//     //       border: Border.all(color: borderColor, width: 1.2),
//     //     ),
//     //     child: Stack(
//     //       children: [
//     //         // OFF label (only when off)
//     //         AnimatedOpacity(
//     //           duration: const Duration(milliseconds: 150),
//     //           opacity: value ? 0 : 1,
//     //           child: const Align(
//     //             alignment: Alignment.centerRight,
//     //             child: Padding(
//     //               padding: EdgeInsets.only(right: 10),
//     //               child: Text(
//     //                 'Off',
//     //                 style: TextStyle(
//     //                   fontFamily: SettingsTheme.fontFamily,
//     //                   fontSize: 12,
//     //                   fontWeight: FontWeight.w600,
//     //                   color: Color(0xFF9CA3AF),
//     //                   height: 1.0,
//     //                 ),
//     //               ),
//     //             ),
//     //           ),
//     //         ),
//     //
//     //         // Knob
//     //         AnimatedAlign(
//     //           duration: const Duration(milliseconds: 180),
//     //           curve: Curves.easeOut,
//     //           alignment: value ? Alignment.centerRight : Alignment.centerLeft,
//     //           child: Container(
//     //             width: _knob,
//     //             height: _knob,
//     //             decoration: BoxDecoration(
//     //               color: Colors.white,
//     //               borderRadius: BorderRadius.circular(999),
//     //               boxShadow: const [
//     //                 BoxShadow(
//     //                   blurRadius: 10,
//     //                   offset: Offset(0, 3),
//     //                   color: Color(0x26000000),
//     //                 ),
//     //               ],
//     //             ),
//     //           ),
//     //         ),
//     //       ],
//     //     ),
//     //   ),
//     // );
//   }
// }


class _FigmaToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FigmaToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const double _width = 55;
  static const double _height = 28;
  static const double _knobSize = 24;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _width,
        height: _height,
        padding: EdgeInsets.only(
          left: value ? 10 : 3,
          right: value ? 3 : 10,
        ),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF645D9C) : Colors.white,
          borderRadius: BorderRadius.circular(35.71),
          border: value
              ? null
              : Border.all(
            width: 0.71,
            color: const Color(0xFFE2E2E2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: value
              ? [
            /// ON TEXT
            const SizedBox(
              width: 12,
              child: Text(
                'On',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE4E0FF),
                  fontSize: 8,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            /// KNOB
            _knob(),
          ]
              : [
            /// KNOB
            _knob(withShadow: true),

            /// OFF TEXT
            const SizedBox(
              width: 14,
              child: Text(
                'Off',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 8,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _knob({bool withShadow = false}) {
    return Container(
      width: _knobSize,
      height: _knobSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: withShadow
            ? [
          const BoxShadow(
            color: Color(0x25000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          )
        ]
            : null,
      ),
    );
  }
}

