import 'package:flutter/material.dart';
import 'color_manager.dart';
import 'extentions/hex_color.dart';

class MyGradients {
  static Gradient grey = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [ColorManager.greyB9B9B9,ColorManager.greyB9B9B9],
  );

  static Gradient defaultGradient = LinearGradient(colors: [
    ColorManager.semiGray,
    ColorManager.primaryRedED3284
  ]);
  static Gradient homeGridItemGradient = const LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xfffef5f9), Colors.white],
  );
  static Gradient createAccount = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [HexColor.fromHex('#00C875'), HexColor.fromHex('#00C875')],
  );
  static Gradient blankBackground = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [HexColor.fromHex('#00C875'), HexColor.fromHex('#00C875')],
  );
  static Gradient biodataBackground = const LinearGradient(
    begin: Alignment(0, 0),
    end: Alignment(1, 1),
    colors: [Color(0xff3b2b7e), Color(0xffa74fff)],
  );

  static Gradient containerButtonGradient = LinearGradient(
    begin: const Alignment(1.00, 0.00),
    end: const Alignment(-1, 0),
    colors: [ColorManager.semiGray,ColorManager.primaryPurpleED3284 ],
  );

}
