import 'package:flutter/material.dart';

class MifiAltContactCard extends StatelessWidget {
  const MifiAltContactCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
