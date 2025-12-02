import 'package:flutter/material.dart';

import '../color_manager.dart';

Widget sizeVer(double height) {
  return SizedBox(height: height,);
}

Widget sizeHor(double width) {
  return SizedBox(width: width);
}

Widget verticalDivider({ EdgeInsets? padding}){
  return Padding(
    padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 24.0, vertical: 20),
    child: Container(
      color: ColorManager.fieldPlaceholder8A8A8A,
      height: 1,
    ),
  );
}

Widget horizontalDivider({ EdgeInsets? padding, double? width,Color? color}){
  return Padding(
    padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 24.0, vertical: 20),
    child: Container(
      color: color ?? ColorManager.fieldPlaceholder8A8A8A,
      height: 1,width: width ?? 70,
    ),
  );
}