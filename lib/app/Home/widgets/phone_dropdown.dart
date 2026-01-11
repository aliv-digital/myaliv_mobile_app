import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../home/home_screen.dart';

class PhoneDropdown extends StatefulWidget {
  const PhoneDropdown();

  @override
  State<PhoneDropdown> createState() => _PhoneDropdownState();
}

class _PhoneDropdownState extends State<PhoneDropdown> {
  String selected = '242-801-1616';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width ,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white54),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          dropdownColor: HomeScreen.purple,
          icon: const Icon(IconsaxPlusLinear.arrow_down, color: Colors.white),
          style: const TextStyle(
            fontFamily: 'CircularPro',
            color: Colors.white,
          ),
          items: const [
            DropdownMenuItem(value: '242-801-1616', child: Text('242-801-1616')),
            DropdownMenuItem(value: '242-801-9999', child: Text('242-801-9999')),
          ],
          onChanged: (v) => setState(() => selected = v!),
        ),
      ),
    );
  }
}
