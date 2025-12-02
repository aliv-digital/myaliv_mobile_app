import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../gradients.dart';
import '../shadows.dart';

class ContainerDecoration{

  /// container decoration style 1
  static ShapeDecoration gradientDecoration = ShapeDecoration(
    gradient: MyGradients.containerButtonGradient,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
  );

  /// container decoration style 1
  static BoxDecoration profileContainerDecoration =BoxDecoration(
    boxShadow: [MyShadows.gridItemShadow],
    borderRadius: BorderRadius.circular(8),
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [ColorManager.redGradFEF5F9, Colors.white],
    ),
  );


}