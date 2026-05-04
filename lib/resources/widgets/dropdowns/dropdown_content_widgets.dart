import 'package:flutter/material.dart';

const _dropdownBg = Color(0xFFF1F1F8);
const _selectedAccent = Color(0xFF645D9C);

const dropdownContentTextStyle = TextStyle(
  color: Color(0xFF707070),
  fontSize: 14,
  fontFamily: 'CircularPro',
  fontWeight: FontWeight.w500,
);

class DropdownContainer extends StatelessWidget {
  final Widget child;

  const DropdownContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _dropdownBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

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

class DropdownEmptyContent extends StatelessWidget {
  const DropdownEmptyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('no saved cards', style: dropdownContentTextStyle);
  }
}

class DropdownSelectedCardContent extends StatelessWidget {
  final String displayText;

  const DropdownSelectedCardContent({super.key, required this.displayText});

  @override
  Widget build(BuildContext context) {
    return Text(displayText, style: dropdownContentTextStyle);
  }
}

const dropdownSelectedAccent = _selectedAccent;
