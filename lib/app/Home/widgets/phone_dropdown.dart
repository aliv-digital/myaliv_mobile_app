import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        border: Border.all(color: Colors.white54,width: 1),

      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          dropdownColor: HomeScreen.purple,
          icon: const Icon(IconsaxPlusLinear.arrow_down, color: Colors.white),
          style: const TextStyle(

            color: const Color(0xFFF1F1F8),
            fontSize: 14,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
            height: 1.14,
          ),
          items: [
            DropdownMenuItem(value: '242-801-1616', child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/Phone.svg'),
                SizedBox(width: 8,),
                const Text('242-801-1616'),
              ],
            )),
             DropdownMenuItem(value: '242-801-9999', child: Row(
              children: [
                SvgPicture.asset('assets/icons/Phone.svg'),
                SizedBox(width: 8,),
                Text('242-801-9999'),
              ],
            )),
          ],
          onChanged: (v) => setState(() => selected = v!),
        ),
      ),
    );
  }
}
