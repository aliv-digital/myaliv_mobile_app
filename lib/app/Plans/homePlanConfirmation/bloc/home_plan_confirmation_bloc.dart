import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import '../models/home_plan_confirmation_models.dart';
import '../repository/home_plan_confirmation_repository.dart';
import 'home_plan_confirmation_event.dart';
import 'home_plan_confirmation_state.dart';

class HomePlanConfirmationBloc
    extends Bloc<HomePlanConfirmationEvent, HomePlanConfirmationState> {
  final HomePlanConfirmationRepository repository;
  final AccountInfoCubit accountInfoCubit;

  HomePlanConfirmationBloc({
    required this.repository,
    required this.accountInfoCubit,
  }) : super(HomePlanConfirmationState.initial()) {
    on<HomePlanConfirmationStarted>(_onStarted);
    on<HomePlanConfirmationRemoveItemPressed>(_onRemoveItem);
    on<HomePlanConfirmationPromoCodeChanged>(_onPromoCodeChanged);
    on<HomePlanConfirmationPromoApplyPressed>(_onPromoApply);
    on<HomePlanConfirmationTermsPressed>(_onTerms);
    on<HomePlanConfirmationTermsCheckboxToggled>(_onTermsCheckboxToggled);
    on<HomePlanConfirmationPayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
    HomePlanConfirmationStarted event,
    Emitter<HomePlanConfirmationState> emit,
  ) async {
    emit(state.copyWith(status: HomePlanConfirmationStatus.loading));

    try {
      final data = await repository.load(args: event.args);
      emit(
        state.copyWith(
          status: HomePlanConfirmationStatus.ready,
          data: data,
          isTermsChecked: event.args.defaultTermsChecked,
          forceNow: event.args.forceNow,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomePlanConfirmationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onRemoveItem(
    HomePlanConfirmationRemoveItemPressed event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    final data = state.data;
    if (data == null) return;

    final updatedItems = data.items.where((x) => x.id != event.itemId).toList();

    final totals = PurchaseTotals(
      subTotal: updatedItems.fold<double>(0, (s, x) => s + x.price),
      vat: data.totals.vat,
    );

    emit(
      state.copyWith(
        data: HomePlanConfirmationData(
          phoneNumber: data.phoneNumber,
          headerTitle: data.headerTitle,
          beginsOnDateText: data.beginsOnDateText,
          items: updatedItems,
          totals: totals,
        ),
      ),
    );
  }

  void _onPromoCodeChanged(
    HomePlanConfirmationPromoCodeChanged event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    emit(
      state.copyWith(
        promoCode: event.value,
        promoStatus: HomePlanConfirmationPromoStatus.idle,
        promoErrorMessage: '',
        promoResponse: null,
      ),
    );
  }

  Future<void> _onPromoApply(
    HomePlanConfirmationPromoApplyPressed event,
    Emitter<HomePlanConfirmationState> emit,
  ) async {
    if (!state.canApplyPromo) return;

    final promoCode = state.promoCode.trim();

    emit(
      state.copyWith(
        promoCode: promoCode,
        promoStatus: HomePlanConfirmationPromoStatus.applying,
        promoErrorMessage: '',
        promoResponse: null,
      ),
    );

    try {
      final accountInfo = accountInfoCubit.state.accountInfo;
      final deviceAccountId = accountInfo?.idAcc ?? 0;

      if (deviceAccountId <= 0) {
        throw Exception('Device account ID not found.');
      }

      debugPrint('HomePlanConfirmationBloc: promo code=$promoCode');

      final response = await repository.applyPromo(
        code: promoCode,
        deviceAcId: deviceAccountId,
      );

      debugPrint('HomePlanConfirmationBloc: apply promo response=$response');

      debugPrint('is Applied : ${response.isApplied}');

      emit(
        state.copyWith(
          promoStatus: response.isApplied
              ? HomePlanConfirmationPromoStatus.applied
              : HomePlanConfirmationPromoStatus.failure,
          promoErrorMessage: '',
          promoResponse: response,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          promoStatus: HomePlanConfirmationPromoStatus.failure,
          promoErrorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    return raw.trim().isEmpty ? 'Failed to apply promo code.' : raw.trim();
  }

  void _onTerms(
    HomePlanConfirmationTermsPressed event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    emit(state.copyWith(openTermsRequestId: state.openTermsRequestId + 1));
  }

  void _onTermsCheckboxToggled(
    HomePlanConfirmationTermsCheckboxToggled event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: event.isChecked));
  }

  void _onPayNow(
    HomePlanConfirmationPayNowPressed event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    if (!state.isTermsChecked) return;

    // Future: call API to create payment intent etc.
    emit(state.copyWith(payNowRequestId: state.payNowRequestId + 1));
  }
}
