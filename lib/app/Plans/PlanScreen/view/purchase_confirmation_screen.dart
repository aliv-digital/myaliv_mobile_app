import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

//change
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/pay_from_wallet.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_promo_response_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'confirmation/utils/confirmation_formatters.dart';
import 'confirmation/widgets/confirmation_app_bar.dart';
import 'confirmation/widgets/confirmation_begin_on_card.dart';
import 'confirmation/widgets/confirmation_bottom_bar.dart';
import 'confirmation/widgets/confirmation_breakdown.dart';
import 'confirmation/widgets/confirmation_plan_card.dart';
import 'confirmation/widgets/confirmation_terms_checkbox.dart';

enum _ConfirmationPromoStatus { idle, applying, applied, failure }

class ConfirmationScreen extends StatefulWidget {
  final bool showBeginOn;
  final DateTime? beginDate;
  final HomePlansPostPaidPlanModel? plan;
  final double? topUpAmount;
  final String? recipientPhone;

  const ConfirmationScreen({
    super.key,
    this.showBeginOn = false,
    this.beginDate,
    this.plan,
    this.topUpAmount,
    this.recipientPhone,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  HomePlansPostPaidPlanModel? _selectedPostpaidPlan;
  DateTime? _selectedBeginDate;
  late final NetworkService _networkService = instance<NetworkService>();
  bool _termsAccepted = true;
  String _promoCode = '';
  _ConfirmationPromoStatus _promoStatus = _ConfirmationPromoStatus.idle;
  String _promoErrorMessage = '';
  HomePlanPromoResponse? _promoResponse;

  bool get _canApplyPromo =>
      _promoCode.trim().isNotEmpty &&
      _promoStatus != _ConfirmationPromoStatus.applying;

  @override
  void initState() {
    if (kDebugMode) {
      const star =
          "****************************************************************************************************";
      debugPrint(star);
      debugPrint(
        "we are in ConfirmationScreen() | purchase_confirmation_screen.dart ",
      );
      debugPrint(
        "location : app/PlanScreen/view/purchase_confirmation_screen.dart",
      );
      debugPrint(star);
    }
    super.initState();
    _selectedPostpaidPlan = widget.plan;
    _selectedBeginDate = widget.beginDate;
  }

  @override
  void didUpdateWidget(covariant ConfirmationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan != widget.plan) {
      _selectedPostpaidPlan = widget.plan;
    }
    if (oldWidget.beginDate != widget.beginDate) {
      _selectedBeginDate = widget.beginDate;
    }
  }

  void _continuePressed() {
    /*
     * This confirmation screen is shared by top-up and plan-purchase flows.
     * It uses the route data to decide which payment action should run:
     *
     * 1. A top-up amount without a recipient means the user is topping up
     *    their own number, so continue to the existing top-up payment screen.
     * 2. A top-up amount with a recipient means the user is topping up another
     *    prepaid number. If the user is postpaid, continue to the full payment
     *    method screen before plan validation because this is not a plan purchase.
     * 3. Any remaining postpaid transaction is treated as a plan purchase and
     *    sent to _openPostpaidPaymentMethod(), which validates the selected plan.
     * 4. Any remaining transaction with a top-up amount uses the existing wallet
     *    sheet; without top-up data, it continues to the guest payment method.
     *
     * This order prevents a postpaid user's other-number top-up from being
     * mistaken for a plan purchase and showing "No postpaid plan selected."
     */
    final config = context.read<AppUiConfigCubit>().state;
    final hasTopUpAmount = widget.topUpAmount != null;
    final hasRecipientPhone = widget.recipientPhone != null;

    final isMyNumberTopUp = hasTopUpAmount && !hasRecipientPhone;
    final isPostpaidOtherNumberTopUp = config.isPostpaid && hasTopUpAmount && hasRecipientPhone;
    if (isMyNumberTopUp) {
      final amountParam = widget.topUpAmount!.toStringAsFixed(2);
      context.push(
        '${AppRoutes.topUpPaymentPrepaidScreen}'
        '?amount=$amountParam'
        '&recipientPhone=${widget.recipientPhone}',
      );
      return;
    }
    // A postpaid user can top up another prepaid number without selecting a
    // postpaid plan. Handle that specific transaction before plan validation
    // and pass its recipient to the full payment-method screen.
    if (isPostpaidOtherNumberTopUp) {
      final amountParam = widget.topUpAmount!.toStringAsFixed(2);
      final recipientParam = Uri.encodeQueryComponent(widget.recipientPhone!);
      if(kDebugMode){
        debugPrint("amount : $amountParam");
        debugPrint("receiver's phone : $recipientParam");
      }
      context.push(
        '${AppRoutes.topUpPaymentPrepaidScreen}'
        '?amount=$amountParam'
        '&recipientPhone=$recipientParam',
      );
      return;
    }
    if (config.isPostpaid) {
      if (kDebugMode) {
        debugPrint("purchase now clicked | purchase_confirmation_screen.dart");
        debugPrint(
          "location : app/Plans/PlanScreen/View/purchase_confirmation_screen.dart",
        );
      }
      _openPostpaidPaymentMethod();
      return;
    }
    if (widget.topUpAmount != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PayFromWalletSheet(
          amount: widget.topUpAmount!,
          phoneNumber: widget.recipientPhone,
        ),
      );
      return;
    }
    context.push(AppRoutes.guestPaymentMethodScreen);
  }

  void _openPostpaidPaymentMethod() {
    final plan = _selectedPostpaidPlan;
    if (plan == null) {
      AppToast.show(
        message: 'No postpaid plan selected.',
        type: ToastType.error,
      );
      return;
    }

    context.push(
      AppRoutes.homePlansPaymentMethodScreen,
      extra: HomePlansPaymentMethodRouteArgs(
        subscriberType: HomePlansSubscriberType.postpaid,
        phoneNumber: _accountPhoneNumber(),
        amount: plan.planAmountWithVat,
        vatNote: plan.vatAmount > 0 ? 'vat inclusive' : 'no vat applied',
        forceNow: !widget.showBeginOn,
        selectedBeginDate: widget.showBeginOn ? _selectedBeginDate : null,
        selectedItems: <HomePlansPaymentSelectedItem>[
          HomePlansPaymentSelectedItem(
            id: plan.planId,
            label: _postpaidPlanTypeLabel(plan.planType),
            title: plan.planName,
            subtitle: _postpaidPlanBeginsText(),
            price: plan.planAmount,
            planType: HomePlansPaymentPlanType.fromCode(plan.planType),
          ),
        ],
      ),
    );
  }

  String _accountPhoneNumber() {
    final accountInfo = context.read<AccountInfoCubit>().state.accountInfo;
    return _firstNonEmpty(<String?>[
      accountInfo?.primaryPhoneNumber,
      accountInfo?.phoneNumber,
    ]);
  }

  String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  String _postpaidPlanTypeLabel(String planTypeCode) {
    switch (planTypeCode.trim().toUpperCase()) {
      case 'A':
        return 'standalone';
      case 'S':
        return 'secondary plan';
      case 'P':
        return 'primary plan';
      default:
        return 'plan';
    }
  }

  String _postpaidPlanBeginsText() {
    if (!widget.showBeginOn || _selectedBeginDate == null) {
      return 'begins immediately';
    }

    final date = _selectedBeginDate!;
    return 'begins ${date.month}/${date.day}/${date.year}';
  }

  void _onPromoCodeChanged(String value) {
    setState(() {
      _promoCode = value;
      _promoStatus = _ConfirmationPromoStatus.idle;
      _promoErrorMessage = '';
      _promoResponse = null;
    });
  }

  Future<void> _applyPromo() async {
    if (!_canApplyPromo) return;

    FocusScope.of(context).unfocus();
    final promoCode = _promoCode.trim();

    setState(() {
      _promoCode = promoCode;
      _promoStatus = _ConfirmationPromoStatus.applying;
      _promoErrorMessage = '';
      _promoResponse = null;
    });

    try {
      final accountInfo = instance<AccountInfoCubit>().state.accountInfo;
      final deviceAccountId = accountInfo?.idAcc ?? 0;

      if (deviceAccountId <= 0) {
        throw Exception('Device account ID not found.');
      }

      debugPrint('ConfirmationScreen: promo code=$promoCode');

      final response = await _requestPromo(
        code: promoCode,
        deviceAcId: deviceAccountId,
      );

      debugPrint('ConfirmationScreen: apply promo response=$response');
      debugPrint('is Applied : ${response.isApplied}');

      if (!mounted) return;

      setState(() {
        _promoStatus = response.isApplied
            ? _ConfirmationPromoStatus.applied
            : _ConfirmationPromoStatus.failure;
        _promoErrorMessage = '';
        _promoResponse = response;
      });

      _showPromoResultToast();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _promoStatus = _ConfirmationPromoStatus.failure;
        _promoErrorMessage = _extractErrorMessage(e);
      });

      _showPromoResultToast();
    }
  }

  Future<HomePlanPromoResponse> _requestPromo({
    required String code,
    required int deviceAcId,
  }) async {
    final promoCode = code.trim();

    if (promoCode.isEmpty) {
      throw Exception('Promo code is required.');
    }

    if (deviceAcId <= 0) {
      throw Exception('Device account ID not found.');
    }

    final url = Api.applyPromoCodeUrl(
      deviceAccountId: deviceAcId,
      promoCode: promoCode,
    );

    debugPrint('ConfirmationScreen: applying promo from $url');

    try {
      final response = await _networkService.request<dynamic>(
        url,
        method: HttpMethod.get,
      );

      debugPrint(
        'ConfirmationScreen: apply promo status=${response.statusCode}',
      );
      debugPrint('response body : ${response.data}');

      return HomePlanPromoResponse.fromDynamic(response.data);
    } on NetworkException catch (error) {
      throw Exception(_promoNetworkErrorMessage(error));
    } catch (error) {
      throw Exception('Failed to apply promo code: $error');
    }
  }

  String _promoNetworkErrorMessage(NetworkException error) {
    if (error is NoInternetException || error is HostUnreachableException) {
      return error.message;
    }

    if (error is TimeoutException) {
      return 'Request timeout. Please try again.';
    }

    if (error is SessionExpiredException || error.statusCode == 401) {
      return 'Session expired. Please log in again.';
    }

    final message = error.message.trim();
    if (message.isNotEmpty && message != 'An error occurred') {
      return message;
    }

    return 'Failed to apply promo code.';
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    return raw.trim().isEmpty ? 'Failed to apply promo code.' : raw.trim();
  }

  void _showPromoResultToast() {
    switch (_promoStatus) {
      case _ConfirmationPromoStatus.applied:
        AppToast.show(
          message: _promoToastMessage(
            fallback: 'Promo code applied successfully.',
          ),
          type: ToastType.success,
        );
        break;
      case _ConfirmationPromoStatus.failure:
        AppToast.show(
          message: _promoToastMessage(fallback: 'Invalid promo code.'),
          type: ToastType.error,
        );
        break;
      case _ConfirmationPromoStatus.idle:
      case _ConfirmationPromoStatus.applying:
        break;
    }
  }

  String _promoToastMessage({required String fallback}) {
    if (_promoStatus == _ConfirmationPromoStatus.failure) {
      final errorMessage = _promoErrorMessage.trim();
      if (errorMessage.isNotEmpty) {
        return errorMessage;
      }
    }

    final responseDescription =
        _promoResponse?.textAtPath('Definition.PromoCodeDesc') ?? '';
    if (responseDescription.trim().isNotEmpty) {
      return responseDescription.trim();
    }

    final responseName =
        _promoResponse?.textAtPath('Definition.PromoCodeName') ?? '';
    if (responseName.trim().isNotEmpty) {
      return responseName.trim();
    }

    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isSendTopUp = widget.topUpAmount != null;
    final isMyNumberTopUp = isSendTopUp && widget.recipientPhone == null;
    final topUpAmountText = formatConfirmationCurrency(widget.topUpAmount ?? 0);
    final subTotal = _selectedPostpaidPlan?.planAmount ?? 18.18;
    final vat = _selectedPostpaidPlan?.vatAmount ?? 0.0;
    final total = _selectedPostpaidPlan?.planAmountWithVat ?? 20.00;
    final subTotalText = isSendTopUp
        ? topUpAmountText
        : formatConfirmationCurrency(subTotal);
    final totalText = isSendTopUp
        ? topUpAmountText
        : formatConfirmationCurrency(total);
    final vatLabel = isSendTopUp || vat <= 0
        ? 'no vat applied'
        : ' vat inclusive';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F2FA),
      appBar: ConfirmationAppBar(
        onBack: () => Navigator.of(context).maybePop(),
        onHome: () => context.go(AppRoutes.home),
      ),
        bottomNavigationBar: ConfirmationBottomBar(
          totalText: totalText,
          vatLabel: vatLabel,
          enabled: _termsAccepted,
          onContinue: _continuePressed,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConfirmationPlanCard(
                  date: _selectedBeginDate,
                  showBeginOn: widget.showBeginOn,
                  plan: _selectedPostpaidPlan,
                  topUpAmount: widget.topUpAmount,
                  recipientPhone: widget.recipientPhone,
                ),
                const SizedBox(height: 16),
                if (widget.showBeginOn && _selectedBeginDate != null)
                  ConfirmationBeginOnCard(
                    date: _selectedBeginDate!,
                    onDateChanged: (date) =>
                        setState(() => _selectedBeginDate = date),
                  ),
                const SizedBox(height: 16),
                ConfirmationTermsCheckbox(
                  isChecked: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v),
                ),
                const SizedBox(height: 16),
                ConfirmationBreakdown(
                  subTotalText: subTotalText,
                  vatText: formatConfirmationCurrency(vat),
                  totalText: totalText,
                  promoValue: isMyNumberTopUp ? null : _promoCode,
                  promoEnabled:
                      _promoStatus != _ConfirmationPromoStatus.applying,
                  isPromoActionLoading:
                      _promoStatus == _ConfirmationPromoStatus.applying,
                  onPromoChanged: _onPromoCodeChanged,
                  onPromoApply: _applyPromo,
                ),
              ],
            ),
          ),
        ),
    );
  }
}
