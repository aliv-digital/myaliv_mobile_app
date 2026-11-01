import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/cubit/gift_data_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/model/gift_data_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/gift_data_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/confirm_gift_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_data_form_body.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/widgets/gift_data_status_views.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class GiftDataScreen extends StatelessWidget {
  const GiftDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GiftDataCubit(
        repository: instance<GiftDataRepository>(),
        accountInfoCubit: instance<AccountInfoCubit>(),
      )..load(),
      child: const _GiftDataView(),
    );
  }
}

class _GiftDataView extends StatefulWidget {
  const _GiftDataView();

  @override
  State<_GiftDataView> createState() => _GiftDataViewState();
}

class _GiftDataViewState extends State<_GiftDataView> {
  final _recipientController = TextEditingController();
  final _confirmRecipientController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _confirmRecipientController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final cubit = context.read<GiftDataCubit>();
    final s = cubit.state;
    if (!s.isFormValid) return;
    await ConfirmGiftBottomSheet.show(
      context,
      amountLabel: s.selectedAmount!.label,
      availableLabel: formatMb(s.remainingAfterGiftMb ?? 0),
      recipient: s.recipient,
      onConfirm: () async {
        final ref = await cubit.submit();
        if (ref == null && cubit.state.errorMessage != null) {
          AppToast.show(
            message: cubit.state.errorMessage!,
            type: ToastType.error,
          );
        }
        return ref != null;
      },
    );
  }

  void _onSubmitSuccess(BuildContext context, GiftDataState state) {
    final now = DateTime.now();
    context.pushReplacement(
      AppRoutes.giftDataReceipt,
      extra: <String, dynamic>{
        'recipientNumber': state.recipient,
        'orderReference': state.orderReference ?? '',
        'dateText': DateFormat('MMM d, yyyy').format(now),
        'timeText': DateFormat('h:mm a').format(now).toLowerCase(),
        'totalDataLabel': formatMb(state.availableToShowMb ?? 0),
        'remainingDataLabel': formatMb(state.remainingAfterGiftMb ?? 0),
        'dataGiftedLabel': state.selectedAmount?.label ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GiftDataCubit, GiftDataState>(
          listenWhen: (p, c) => !p.isRecipientComplete && c.isRecipientComplete,
          listener: (ctx, _) => FocusScope.of(ctx).unfocus(),
        ),
        BlocListener<GiftDataCubit, GiftDataState>(
          listenWhen: (p, c) =>
              p.recipientErrorMessage != c.recipientErrorMessage &&
              c.recipientErrorMessage != null,
          listener: (_, s) => AppToast.show(
            message: s.recipientErrorMessage!,
            type: ToastType.error,
          ),
        ),
        BlocListener<GiftDataCubit, GiftDataState>(
          listenWhen: (p, c) =>
              p.status != c.status && c.status == GiftDataStatus.success,
          listener: _onSubmitSuccess,
        ),
      ],
      child: Scaffold(
        backgroundColor: GiftDataTheme.pageBg,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              DefaultAppBar(title: 'gift data', showBackArrow: true),
              Expanded(
                child: BlocBuilder<GiftDataCubit, GiftDataState>(
                  builder: (ctx, state) => switch (state.status) {
                    GiftDataStatus.initial || GiftDataStatus.loading =>
                      const Center(child: CircularProgressIndicator()),
                    GiftDataStatus.failure => GiftDataErrorView(
                      message: state.errorMessage ?? 'something went wrong',
                      onRetry: () => ctx.read<GiftDataCubit>().load(),
                    ),
                    GiftDataStatus.ineligible => GiftDataIneligibleView(
                      reason: state.ineligibleReason,
                    ),
                    _ => GiftDataFormBody(
                      state: state,
                      recipientController: _recipientController,
                      confirmRecipientController: _confirmRecipientController,
                      onContinue: _handleContinue,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
