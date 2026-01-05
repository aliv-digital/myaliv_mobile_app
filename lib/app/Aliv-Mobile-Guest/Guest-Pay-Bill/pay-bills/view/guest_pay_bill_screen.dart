import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(
          backgroundColor: GuestPayBillTheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'pay bills',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<GuestPayBillBloc, GuestPayBillState>(
            builder: (context, state) {
              if (state.loadStatus == GuestPayBillLoadStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabelRequired(text: 'select service'),
                    const SizedBox(height: 8),
                    _ServiceDropdown(
                      services: state.services,
                      selected: state.selectedService,
                      onChanged: (s) => context
                          .read<GuestPayBillBloc>()
                          .add(GuestPayBillServiceChanged(s)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'please select a service to complete the bill pay transaction',
                      style: GuestPayBillTheme.helperStyle(),
                    ),
                    const SizedBox(height: 16),

                    // =========================
                    // Dynamic form by service
                    // =========================
                    if (state.isAlivPostpaid) ...[
                      Text('mobile number', style: GuestPayBillTheme.labelStyle()),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (v) => context
                            .read<GuestPayBillBloc>()
                            .add(GuestPayBillMobileChanged(v)),
                        decoration: GuestPayBillTheme.fieldDecoration(
                          hint: 'eg: 242-899-9999',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('confirm mobile number',
                          style: GuestPayBillTheme.labelStyle()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.phone,
                              onChanged: (v) => context
                                  .read<GuestPayBillBloc>()
                                  .add(GuestPayBillConfirmMobileChanged(v)),
                              decoration: GuestPayBillTheme.fieldDecoration(
                                hint: 'eg: 242-899-9999',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MiniSubmitButton(
                            loading: state.verifyStatus ==
                                GuestPayBillVerifyStatus.loading,
                            enabled: state.canVerify,
                            onTap: () => context
                                .read<GuestPayBillBloc>()
                                .add(const GuestPayBillVerifyPressed()),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text('account number',
                          style: GuestPayBillTheme.labelStyle()),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (v) => context
                            .read<GuestPayBillBloc>()
                            .add(GuestPayBillAccountNumberChanged(v)),
                        decoration: GuestPayBillTheme.fieldDecoration(
                          hint: 'enter number',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('name', style: GuestPayBillTheme.labelStyle()),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) => context
                                  .read<GuestPayBillBloc>()
                                  .add(GuestPayBillNameChanged(v)),
                              decoration: GuestPayBillTheme.fieldDecoration(
                                hint: 'enter name',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _MiniSubmitButton(
                            loading: state.verifyStatus ==
                                GuestPayBillVerifyStatus.loading,
                            enabled: state.canVerify,
                            onTap: () => context
                                .read<GuestPayBillBloc>()
                                .add(const GuestPayBillVerifyPressed()),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),
                    Text('account status', style: GuestPayBillTheme.labelStyle()),
                    const SizedBox(height: 8),
                    _ReadOnlyBox(
                      text: state.accountInfo?.status ?? '------',
                    ),

                    // REV only
                    if (!state.isAlivPostpaid) ...[
                      const SizedBox(height: 16),
                      Text('account balance',
                          style: GuestPayBillTheme.labelStyle()),
                      const SizedBox(height: 8),
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

                    const SizedBox(height: 16),
                    Text('enter a custom amount',
                        style: GuestPayBillTheme.labelStyle()),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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

                    const SizedBox(height: 22),
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

class _MiniSubmitButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _MiniSubmitButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
    enabled ? GuestPayBillTheme.primary : GuestPayBillTheme.disabledBtn;

    return SizedBox(
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: enabled && !loading ? onTap : null,
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
