import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/widgets/currency_amount_input.dart';
import '../theme/top_up_prepaid_theme.dart';
import '../view/auto_renew_authorization_screen.dart';

class TopUpPrepaidPlaceholderTab extends StatefulWidget {
  final String title;

  const TopUpPrepaidPlaceholderTab({super.key, required this.title});

  @override
  State<TopUpPrepaidPlaceholderTab> createState() =>
      _TopUpPrepaidPlaceholderTabState();
}

class _TopUpPrepaidPlaceholderTabState
    extends State<TopUpPrepaidPlaceholderTab> {
  bool anyTimeEnabled = true;

  int selectedAmount = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TopUpPrepaidTheme.pageBg,
      resizeToAvoidBottomInset: true, // 🔥 IMPORTANT
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                32 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= SELECT CARD =================
                    _SectionLabel('select card'),
                    //_DropdownField('visa ending in 1234'),
                    _CardDropdown(),
                    const SizedBox(height: 16),

                    // ================= ANY TIME =================
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'any time',
                            style: TextStyle(
                              fontFamily: 'CircularPro',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch(
                          value: anyTimeEnabled,
                          onChanged: (v) => setState(() => anyTimeEnabled = v),
                          activeThumbColor: TopUpPrepaidTheme.purple,
                          inactiveThumbColor: Colors.white,
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: TopUpPrepaidTheme.pillBg,
                          trackColor: WidgetStateProperty.all(
                            TopUpPrepaidTheme.lightBg,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ================= THRESHOLD =================
                    _SectionLabel('when balance falls below'),
                    _InputField(value: '\$ 10.00'),

                    const SizedBox(height: 8),
                    Text(
                      'amount must be above \$ 10.00 and below \$ 10.000',
                      style: TextStyle(
                        color: const Color(0xFF5045A7),
                        fontSize: 14,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ================= PRESET AMOUNTS =================
                    _SectionLabel('select a top up amount'),
                    const SizedBox(height: 10),

                    _AmountGrid(
                      selected: selectedAmount,
                      onSelect: (v) => setState(() => selectedAmount = v),
                    ),

                    const SizedBox(height: 16),

                    // ================= OR DIVIDER =================
                    Row(
                      children: const [
                        Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontFamily: 'CircularPro',
                              color: const Color(0xFF222222),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.56,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ================= CUSTOM AMOUNT =================
                    _SectionLabel('custom amount'),
                    TopUpFormInputField(
                      hint: 'enter a custom amount',
                      isAmountType: true,
                    ),

                    const SizedBox(height: 32),

                    // ================= APPLY =================
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const AutoRenewAuthorizationScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF645D9C),//TopUpPrepaidTheme.purple,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: Text(
                          'apply',
                          style: TopUpPrepaidTheme.buttonText(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
          height: 1.43,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String value;
  const _DropdownField(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TopUpPrepaidTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'CircularPro', fontSize: 15),
            ),
          ),
          const Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

class _CardDropdown extends StatefulWidget {
  @override
  State<_CardDropdown> createState() => _CardDropdownState();
}

class _CardDropdownState extends State<_CardDropdown> {
  String selectedCard = 'visa ending in 1234';

  final List<String> cards = [
    'visa ending in 1234',
    'mastercard ending in 5678',
    'amex ending in 9012',
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openCardSelector(context),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: TopUpPrepaidTheme.lightBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCard,
                style: const TextStyle(
                  color: const Color(0xFF707070),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  void _openCardSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: cards.map((card) {
              final isSelected = card == selectedCard;

              return ListTile(
                title: Text(
                  card,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 15,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: TopUpPrepaidTheme.purple,
                      )
                    : const Icon(
                        Icons.radio_button_off,
                        color: TopUpPrepaidTheme.lightBg,
                      ),
                onTap: () {
                  setState(() => selectedCard = card);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _AmountGrid extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _AmountGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final amounts = [10, 15, 20, 25, 30, 35];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: amounts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, i) {
        final value = amounts[i];
        final isSelected = value == selected;

        return GestureDetector(
          onTap: () => onSelect(value),
          child: Container(
            // width: 100,
            // height: 80,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: TopUpPrepaidTheme.amountBorderGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(2), // border thickness
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : TopUpPrepaidTheme.lightBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,

              // ✅ "$" + amount centered together (pixel-ish like figma)
              child: Center(
                child: Text(
                  '\$ $value.00',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    color: isSelected
                        ? Colors.black
                        : TopUpPrepaidTheme.textMuted,
                  ),
                ),
              ),
            ),
          ),

        );
      },
    );
  }
}

class _InputField extends StatelessWidget {
  final String? value;
  final String? hint;

  const _InputField({this.value, this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TopUpPrepaidTheme.lightBg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value ?? hint ?? '',
        style: TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 15,
          color: TopUpPrepaidTheme.textMuted,
        ),
      ),
    );
  }
}

class _CustomAmountInput extends StatelessWidget {
  final String hint;

  const _CustomAmountInput({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TopUpPrepaidTheme.lightBg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(
          decimal: false,
          signed: false,
        ),
        textInputAction: TextInputAction.done, // 🔥 SHOW DONE BUTTON
        onSubmitted: (_) {
          FocusScope.of(context).unfocus(); // 🔥 HIDE KEYBOARD
        },
        inputFormatters: [
          // Allows digits + one decimal point
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        style: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 15,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 15,
            color: TopUpPrepaidTheme.textMuted,
          ),
          prefixText: '\$ ',
          prefixStyle: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
