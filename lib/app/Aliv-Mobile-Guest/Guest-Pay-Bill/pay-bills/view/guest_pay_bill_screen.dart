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
import '../widgets/guest_pay_bill_country_code_picker_box.dart';
import '../widgets/guest_pay_bill_inline_verify_field.dart';
import '../widgets/guest_pay_bill_primary_submit_button.dart';
import '../widgets/guest_pay_bill_read_only_box.dart';
import '../widgets/guest_pay_bill_required_label.dart';
import '../widgets/guest_pay_bill_service_dropdown.dart';

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
                          const GuestPayBillRequiredLabel(
                              text: 'select service'),
                          const SizedBox(height: _labelToFieldGap),
                          GuestPayBillServiceDropdown(
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
                                GuestPayBillCountryCodePickerBox(
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
                                GuestPayBillCountryCodePickerBox(
                                  country: state.selectedCountry,
                                  showArrow: false,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GuestPayBillInlineVerifyField(
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
                            GuestPayBillInlineVerifyField(
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
                          GuestPayBillReadOnlyBox(
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
                          GuestPayBillPrimarySubmitButton(
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
