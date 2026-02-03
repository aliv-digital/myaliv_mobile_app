import 'package:flutter/material.dart';
import '../theme/settings_theme.dart';

class SettingsSectionCard extends StatelessWidget {
  final List<Widget> children;
  final bool printLine;

  const SettingsSectionCard({
    super.key,
    this.printLine = true,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SettingsTheme.cardBg,
        borderRadius: BorderRadius.circular(SettingsTheme.cardRadius),
      ),
      child: Column(
        children: _withDividers(children),
      ),
    );
  }

  List<Widget> _withDividers(List<Widget> items) {
    if (items.isEmpty) return const [];
    final result = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if(printLine == true){
        if (i != items.length - 1) {
          result.add(
            const Divider(height: 1, thickness: 1, color: SettingsTheme.divider),
          );
        }
      }else{
        result.add(
          const SizedBox(height: 5)
        );
      }
    }
    return result;
  }
}
