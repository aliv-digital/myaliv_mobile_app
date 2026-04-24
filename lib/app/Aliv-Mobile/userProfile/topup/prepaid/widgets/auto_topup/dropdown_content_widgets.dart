import 'package:flutter/material.dart';
import '../../theme/top_up_prepaid_theme.dart';

/// Text style used for dropdown content.
const dropdownContentTextStyle = TextStyle(
  color: Color(0xFF707070),
  fontSize: 14,
  fontFamily: 'CircularPro',
  fontWeight: FontWeight.w500,
);

/// Container widget for the dropdown button.
class DropdownContainer extends StatelessWidget {
  final Widget child;

  const DropdownContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TopUpPrepaidTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// Loading state content for the dropdown.
class DropdownLoadingContent extends StatelessWidget {
  const DropdownLoadingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('loading cards...', style: dropdownContentTextStyle),
      ],
    );
  }
}

/// Error state content for the dropdown.
class DropdownErrorContent extends StatelessWidget {
  const DropdownErrorContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'failed to load cards',
      style: TextStyle(
        color: Color(0xFFE53935),
        fontSize: 14,
        fontFamily: 'CircularPro',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Empty state content for the dropdown.
class DropdownEmptyContent extends StatelessWidget {
  const DropdownEmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('no saved cards', style: dropdownContentTextStyle);
  }
}

/// Selected card content for the dropdown.
class DropdownSelectedCardContent extends StatelessWidget {
  final String displayText;

  const DropdownSelectedCardContent({super.key, required this.displayText});

  @override
  Widget build(BuildContext context) {
    return Text(displayText, style: dropdownContentTextStyle);
  }
}
