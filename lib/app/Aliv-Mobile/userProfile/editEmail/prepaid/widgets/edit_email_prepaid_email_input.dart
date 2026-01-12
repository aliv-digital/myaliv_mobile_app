import 'package:flutter/material.dart';
import '../theme/edit_email_prepaid_theme.dart';

class EditEmailPrepaidEmailInput extends StatefulWidget {
  final String initialValue;
  final bool enabled;
  final ValueChanged<String> onChanged;

  const EditEmailPrepaidEmailInput({
    super.key,
    required this.initialValue,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<EditEmailPrepaidEmailInput> createState() => _EditEmailPrepaidEmailInputState();
}

class _EditEmailPrepaidEmailInputState extends State<EditEmailPrepaidEmailInput> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant EditEmailPrepaidEmailInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _c.text != widget.initialValue) {
      _c.text = widget.initialValue;
      _c.selection = TextSelection.collapsed(offset: _c.text.length);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: EditEmailPrepaidTheme.inputBg,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.only(left: 8,right: 8,top: 8,bottom: 8),
      alignment: Alignment.center,
      child: TextField(
        controller: _c,
        enabled: widget.enabled,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          height: 1.43,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: '',
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
