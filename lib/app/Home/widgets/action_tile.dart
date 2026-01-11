import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../home/home_screen.dart';

class ActionTile extends StatelessWidget {
  final String iconPath;
  final String label;

  const ActionTile(this.iconPath, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(iconPath, color: HomeScreen.purple),
          SvgPicture.asset(
            iconPath,
            width: 16,
            height: 16,
            // color: HomeScreen.purple,
          ),

          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'CircularPro', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
