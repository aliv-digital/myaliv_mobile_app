import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_picker/country_picker.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';

import '../bloc/guest_pay_bill_bloc.dart';
import '../bloc/guest_pay_bill_event.dart';
import '../bloc/guest_pay_bill_state.dart';
import '../model/guest_pay_bill_models.dart';
import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillScreen extends StatelessWidget {
  const GuestPayBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuestPayBillBloc()..add(const GuestPayBillStarted()),
      child: const _GuestPayBillView(),
    );
  }
}

class _GuestPayBillView extends StatelessWidget {
  const _GuestPayBillView();
  static const double _labelToFieldGap = 8;
  static const double _sectionGap = 16;
  static const double _submitTopGap = 30;

  void _pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        final normalizedPhoneCode =
            country.phoneCode.split(RegExp(r'[\s-]')).first;
        context.read<GuestPayBillBloc>().add(
              GuestPayBillCountryChanged(
                PayBillCountry(
                  flagEmoji: country.flagEmoji,
                  dialCode: normalizedPhoneCode,
                ),
              ),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return BlocListener<GuestPayBillBloc, GuestPayBillState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage ||
          p.submitStatus != c.submitStatus ||
          p.verifyStatus != c.verifyStatus,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        if (state.submitStatus == GuestPayBillSubmitStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment submitted')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: GuestPayBillTheme.pageBg,
        body: SafeArea(
          child: Column(
            children: [
              DefaultAppBar(
                title: 'pay bills',
                backgroundColor: GuestPayBillTheme.primary,
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: BlocBuilder<GuestPayBillBloc, GuestPayBillState>(
                  builder: (context, state) {
                    if (state.loadStatus == GuestPayBillLoadStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(23, 18, 23, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LabelRequired(text: 'select service'),
                          const SizedBox(height: _labelToFieldGap),
                          _ServiceDropdown(
                            services: state.services,
                            selected: state.selectedService,
                            onChanged: (s) => context
                                .read<GuestPayBillBloc>()
                                .add(GuestPayBillServiceChanged(s)),
                          ),
                          const SizedBox(height: _labelToFieldGap),
                          Text(
                            'please select a service to complete the bill pay transaction',
                            style: GuestPayBillTheme.helperStyle(),
                          ),
                          const SizedBox(height: _sectionGap),

                          // =========================
                          // Dynamic form by service
                          // =========================
                          if (state.isAlivPostpaid) ...[
                            Text('mobile number',
                                style: GuestPayBillTheme.labelStyle()),
                            const SizedBox(height: _labelToFieldGap),
                            Row(
                              children: [
                                _CountryCodePickerBox(
                                  country: state.selectedCountry,
                                  showArrow: true,
                                  onTap: () => _pickCountry(context),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    onChanged: (v) => context
                                        .read<GuestPayBillBloc>()
                                        .add(GuestPayBillMobileChanged(v)),
                                    decoration:
                                        GuestPayBillTheme.fieldDecoration(
                                      hint: 'eg: 2428999999',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: _sectionGap),
                            Text('confirm mobile number',
                                style: GuestPayBillTheme.labelStyle()),
                            const SizedBox(height: _labelToFieldGap),
                            Row(
                              children: [
                                _CountryCodePickerBox(
                                  country: state.selectedCountry,
                                  showArrow: false,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _InlineVerifyField(
                                    hint: 'eg: 2428999999',
                                    keyboardType: TextInputType.phone,
                                    loading: state.verifyStatus ==
                                        GuestPayBillVerifyStatus.loading,
                                    enabled: state.canVerify,
                                    onChanged: (v) => context
                                        .read<GuestPayBillBloc>()
                                        .add(GuestPayBillConfirmMobileChanged(
                                            v)),
                                    onSubmit: () => context
                                        .read<GuestPayBillBloc>()
                                        .add(const GuestPayBillVerifyPressed()),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Text(state.accountIdentifierLabel,
                                style: GuestPayBillTheme.labelStyle()),
                            const SizedBox(height: _labelToFieldGap),
                            TextField(
                              keyboardType: state.isAlivFibr
                                  ? TextInputType.text
                                  : TextInputType.number,
                              onChanged: (v) => context
                                  .read<GuestPayBillBloc>()
                                  .add(GuestPayBillAccountNumberChanged(v)),
                              decoration: GuestPayBillTheme.fieldDecoration(
                                hint: state.accountIdentifierHint,
                              ),
                            ),
                            const SizedBox(height: _sectionGap),
                            Text('name', style: GuestPayBillTheme.labelStyle()),
                            const SizedBox(height: _labelToFieldGap),
                            _InlineVerifyField(
                              hint: 'enter name',
                              keyboardType: TextInputType.text,
                              loading: state.verifyStatus ==
                                  GuestPayBillVerifyStatus.loading,
                              enabled: state.canVerify,
                              onChanged: (v) => context
                                  .read<GuestPayBillBloc>()
                                  .add(GuestPayBillNameChanged(v)),
                              onSubmit: () => context
                                  .read<GuestPayBillBloc>()
                                  .add(const GuestPayBillVerifyPressed()),
                            ),
                          ],

                          const SizedBox(height: _sectionGap),
                          Text('account status',
                              style: GuestPayBillTheme.labelStyle()),
                          const SizedBox(height: _labelToFieldGap),
                          _ReadOnlyBox(
                            text: state.accountInfo?.status ?? '------',
                          ),

                          // REV only
                          if (!state.isAlivPostpaid) ...[
                            const SizedBox(height: _sectionGap),
                            Text('account balance',
                                style: GuestPayBillTheme.labelStyle()),
                            const SizedBox(height: _labelToFieldGap),
                            Text(
                              state.accountInfo?.balance == null
                                  ? '------'
                                  : _money(state.accountInfo!.balance!),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: GuestPayBillTheme.labelText,
                              ),
                            ),
                          ],

                          const SizedBox(height: _sectionGap),
                          Text('enter a custom amount',
                              style: GuestPayBillTheme.labelStyle()),
                          const SizedBox(height: _labelToFieldGap),
                          TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onChanged: (v) => context
                                .read<GuestPayBillBloc>()
                                .add(GuestPayBillAmountChanged(v)),
                            decoration: GuestPayBillTheme.fieldDecoration(
                              hint: '\$ 0.00',
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 14, right: 6),
                                child: Center(
                                  widthFactor: 0,
                                  child: Text(
                                    '\$',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: GuestPayBillTheme.labelText,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: _submitTopGap),
                          _BigSubmitButton(
                            enabled: state.canSubmit,
                            loading: state.submitStatus ==
                                GuestPayBillSubmitStatus.loading,
                            onTap: () => context
                                .read<GuestPayBillBloc>()
                                .add(const GuestPayBillSubmitPressed()),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';
}

class _LabelRequired extends StatelessWidget {
  final String text;
  const _LabelRequired({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: GuestPayBillTheme.labelStyle()),
        const Text(
          '*',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ServiceDropdown extends StatelessWidget {
  final List<BillService> services;
  final BillService? selected;
  final ValueChanged<BillService?> onChanged;

  const _ServiceDropdown({
    required this.services,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BillService>(
          isExpanded: true,
          value: selected,
          hint: const Text(
            'ALIV Postpaid',
            style: TextStyle(
              color: GuestPayBillTheme.labelText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: services
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: GuestPayBillTheme.labelText,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _InlineVerifyField extends StatelessWidget {
  final String hint;
  final TextInputType keyboardType;
  final bool enabled;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const _InlineVerifyField({
    required this.hint,
    required this.keyboardType,
    required this.enabled,
    required this.loading,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: keyboardType,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: GuestPayBillTheme.placeholder,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _InlineSubmitButton(
            loading: loading,
            enabled: enabled,
            onTap: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _InlineSubmitButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _InlineSubmitButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Keep visual state active from initial load, but guard invalid submission.
    final bg = GuestPayBillTheme.primary;

    return SizedBox(
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: loading
            ? null
            : () {
                if (enabled) {
                  onTap();
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter required details first.'),
                  ),
                );
              },
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'submit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _CountryCodePickerBox extends StatelessWidget {
  final PayBillCountry country;
  final bool showArrow;
  final VoidCallback? onTap;

  const _CountryCodePickerBox({
    required this.country,
    required this.showArrow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: 96,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      child: Row(
        children: [
          Text(country.flagEmoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            country.dialCode,
            style: const TextStyle(
              color: GuestPayBillTheme.labelText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showArrow) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: GuestPayBillTheme.primary,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      child: child,
    );
  }
}

class _ReadOnlyBox extends StatelessWidget {
  final String text;
  const _ReadOnlyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: GuestPayBillTheme.labelText,
        ),
      ),
    );
  }
}

class _BigSubmitButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _BigSubmitButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        enabled ? GuestPayBillTheme.primary : GuestPayBillTheme.disabledBtn;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: enabled && !loading ? onTap : null,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'submit',
                style: TextStyle(
                  color: enabled ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
