import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionTile extends StatelessWidget {
  final String iconPath;
  final String label;

  const ActionTile(this.iconPath, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      // height: 68,width: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 34,
            height: 34,
            // color: HomeScreen.purple,
          ),

          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: const Color(0xFF222222),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
              height: 1.10,
              letterSpacing: 0.06,
            ),
          ),
          // const SizedBox(height: 7),
        ],
      ),
    );
  }
}
