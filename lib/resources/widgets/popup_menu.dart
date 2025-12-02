import 'package:flutter/material.dart';
import '../color_manager.dart';

class PopUpMenu extends StatelessWidget {
  final List<PopupMenuEntry> menuList;
  final Widget? icon;
  const PopUpMenu({Key? key, required this.menuList, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      position: PopupMenuPosition.under,
      offset: const Offset(20, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      surfaceTintColor: ColorManager.globalBackgroundFAF9FB,
      color: ColorManager.globalBackgroundFAF9FB,
      elevation: 1,
      itemBuilder: ((context) => menuList),
      icon: icon,
      iconSize: 40,
    );
  }
}
