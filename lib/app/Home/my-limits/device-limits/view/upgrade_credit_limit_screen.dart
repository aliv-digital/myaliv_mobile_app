import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/update_limits_request.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/view/widgets/limit_amount_input_field.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/common_terms_condition.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class UpgradeCreditLimitScreen extends StatefulWidget {
  const UpgradeCreditLimitScreen({super.key});

  static const Color purple = Color(0xFF645D9C);

  @override
  State<UpgradeCreditLimitScreen> createState() =>
      _UpgradeCreditLimitScreenState();
}

class _UpgradeCreditLimitScreenState extends State<UpgradeCreditLimitScreen> {
  bool _agreed = true;

  final _localTextController = TextEditingController();
  final _localDataController = TextEditingController();
  final _localVoiceController = TextEditingController();
  final _intlRoamingController = TextEditingController();
  final _intlTalkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDeviceLimits();
  }

  @override
  void dispose() {
    _localTextController.dispose();
    _localDataController.dispose();
    _localVoiceController.dispose();
    _intlRoamingController.dispose();
    _intlTalkController.dispose();
    super.dispose();
  }

  void _loadDeviceLimits() {
    final cubit = instance<DeviceLimitsCubit>();

    if (cubit.state.hasDeviceLimits) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateControllers(cubit.state);
      });
    }

    cubit.loadDeviceLimits();
  }

  void _populateControllers(DeviceLimitsState state) {
    if (state.hasDeviceLimits) {
      final limits = state.deviceLimits!;
      setState(() {
        _localTextController.text = limits.localTextFormatted;
        _localDataController.text = limits.localDataFormatted;
        _localVoiceController.text = limits.localVoiceFormatted;
        _intlRoamingController.text = limits.internationalFormatted;
        _intlTalkController.text = limits.roamingFormatted;
      });
    }
  }

  Future<void> _updateLimits() async {
    final accountInfo = context.read<AccountInfoCubit>().state.accountInfo;
    if (accountInfo == null || accountInfo.idAcc <= 0) {
      AppToast.show(
        message: 'Account information not available',
        type: ToastType.error,
      );
      return;
    }

    final request = UpdateLimitsRequest.fromFormValues(
      localText: _localTextController.text,
      localData: _localDataController.text,
      localVoice: _localVoiceController.text,
      international: _intlRoamingController.text,
      roaming: _intlTalkController.text,
    );

    final success = await instance<DeviceLimitsCubit>().updateLimits(
      deviceAccountId: accountInfo.idAcc,
      request: request,
    );

    if (success && mounted) {
      // Refresh consumption limits (my limits) with updated data
      instance<ConsumptionLimitCubit>().loadLimits(
        deviceAccountId: accountInfo.idAcc,
        forceRefresh: true,
      );

      AppToast.show(
        message: 'success! your credit limit has been upgraded',
        type: ToastType.success,
      );
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: BlocProvider.value(
        value: instance<DeviceLimitsCubit>(),
        child: BlocListener<DeviceLimitsCubit, DeviceLimitsState>(
          listener: (context, state) {
            if (state.isLoaded) {
              _populateControllers(state);
            }
            if (state.hasError && state.errorMessage != null) {
              AppToast.show(
                message: state.errorMessage!,
                type: ToastType.error,
              );
            }
          },
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _buildBalanceHeader(),
                const SizedBox(height: 28),
                _buildLimitFields(),
                const SizedBox(height: 16),
                _buildTermsAgreement(),
                const SizedBox(height: 30),
                _buildProceedButton(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: UpgradeCreditLimitScreen.purple,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Padding(
          padding: EdgeInsets.only(left: 24.0),
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'upgrade credit limit',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 20, 8),
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.home),
            child: SvgPicture.asset(
              'assets/icons/home.svg',
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceHeader() {
    return BlocBuilder<BalanceCubit, BalanceState>(
      builder: (context, balanceState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFEAECF0)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/Wallet_Cash_550px 1.png',
                width: 36,
                height: 40,
              ),
              const SizedBox(width: 14),
              Column(
                children: [
                  Text(
                    '\$${balanceState.walletBalanceFormatted}',
                    style: const TextStyle(
                      color: Color(0xFF5045A7),
                      fontSize: 24,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'current balance due',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLimitFields() {
    return Column(
      children: [
        LimitFieldWithController(
          label: 'local text',
          controller: _localTextController,
        ),
        LimitFieldWithController(
          label: 'local data',
          controller: _localDataController,
        ),
        LimitFieldWithController(
          label: 'local talk mins',
          controller: _localVoiceController,
        ),
        LimitFieldWithController(
          label: "int'l roaming",
          controller: _intlRoamingController,
        ),
        LimitFieldWithController(
          label: "int'l talk mins",
          controller: _intlTalkController,
        ),
      ],
    );
  }

  Widget _buildTermsAgreement() {
    return TermsAgreement(
      value: _agreed,
      onChanged: (val) => setState(() => _agreed = val),
      onTermsTap: () async {
        final uri = Uri.parse('https://www.bealiv.com/terms-of-use/');
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          throw 'Could not open terms';
        }
      },
    );
  }

  Widget _buildProceedButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 42),
      child: BlocBuilder<DeviceLimitsCubit, DeviceLimitsState>(
        builder: (context, state) {
          final isUpdating = state.isUpdating;
          return SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: isUpdating || !_agreed ? null : _updateLimits,
              style: ElevatedButton.styleFrom(
                backgroundColor: UpgradeCreditLimitScreen.purple,
                disabledBackgroundColor:
                    UpgradeCreditLimitScreen.purple.withValues(alpha: 0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: isUpdating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'proceed',
                      style: TextStyle(
                        color: Color(0xFFF1F1F8),
                        fontSize: 15,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
