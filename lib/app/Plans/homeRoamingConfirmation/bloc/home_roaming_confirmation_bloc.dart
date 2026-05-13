import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../repository/home_roaming_confirmation_repository.dart';
import 'home_roaming_confirmation_event.dart';
import 'home_roaming_confirmation_state.dart';

class HomeRoamingConfirmationBloc
    extends Bloc<HomeRoamingConfirmationEvent, HomeRoamingConfirmationState> {
  final HomeRoamingConfirmationRepository repository;
  final AccountInfoCubit accountInfoCubit;

  HomeRoamingConfirmationBloc({
    required this.repository,
    required this.accountInfoCubit,
  }) : super(HomeRoamingConfirmationState.initial()) {
    on<HomeRoamingConfirmationStarted>(_onStarted);
    on<HomeRoamingConfirmationRemoveItemPressed>(_onRemoveItem);
    on<HomeRoamingConfirmationBeginDateChanged>(_onBeginDateChanged);
    on<HomeRoamingConfirmationPromoCodeChanged>(_onPromoCodeChanged);
    on<HomeRoamingConfirmationPromoApplyPressed>(_onPromoApply);
    on<HomeRoamingConfirmationTermsPressed>(_onTerms);
    on<HomeRoamingConfirmationTermsCheckboxToggled>(_onTermsCheckboxToggled);
    on<HomeRoamingConfirmationPayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
    HomeRoamingConfirmationStarted event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: HomeRoamingConfirmationStatus.loading,
        routeArgs: event.args,
      ),
    );

    try {
      final data = await repository.load(args: event.args);
      emit(
        state.copyWith(
          status: HomeRoamingConfirmationStatus.ready,
          routeArgs: event.args,
          data: data,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeRoamingConfirmationStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onRemoveItem(
    HomeRoamingConfirmationRemoveItemPressed event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    final data = state.data;
    if (data == null) return;

    final updatedItems = data.items.where((x) => x.id != event.itemId).toList();

    final totals = HomeRoamingConfirmationPurchaseTotals(
      subTotal: updatedItems.fold<double>(0, (s, x) => s + x.price),
      vat: data.totals.vat,
    );

    emit(
      state.copyWith(
        data: HomeRoamingConfirmationData(
          phoneNumber: data.phoneNumber,
          headerTitle: data.headerTitle,
          beginsOnDateText: data.beginsOnDateText,
          items: updatedItems,
          totals: totals,
        ),
      ),
    );
  }

  void _onBeginDateChanged(
    HomeRoamingConfirmationBeginDateChanged event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    final routeArgs = state.routeArgs;
    final data = state.data;
    if (routeArgs == null || data == null) return;

    final updatedArgs = routeArgs.copyWith(beginDate: event.beginDate);
    final updatedData = repository.updateBeginDate(
      data: data,
      beginDate: event.beginDate,
    );

    emit(
      state.copyWith(
        status: HomeRoamingConfirmationStatus.ready,
        routeArgs: updatedArgs,
        data: updatedData,
      ),
    );
  }

  void _onPromoCodeChanged(
    HomeRoamingConfirmationPromoCodeChanged event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    emit(
      state.copyWith(
        promoCode: event.value,
        promoStatus: HomeRoamingConfirmationPromoStatus.idle,
        promoErrorMessage: '',
        promoResponse: null,
      ),
    );
  }

  Future<void> _onPromoApply(
    HomeRoamingConfirmationPromoApplyPressed event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) async {
    if (!state.canApplyPromo) return;

    final promoCode = state.promoCode.trim();

    emit(
      state.copyWith(
        promoCode: promoCode,
        promoStatus: HomeRoamingConfirmationPromoStatus.applying,
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

      debugPrint('HomeRoamingConfirmationBloc: promo code=$promoCode');

      final response = await repository.applyPromo(
        code: promoCode,
        deviceAcId: deviceAccountId,
      );

      debugPrint('HomeRoamingConfirmationBloc: apply promo response=$response');
      debugPrint(
        'HomeRoamingConfirmationBloc: isApplied=${response.isApplied}',
      );

      emit(
        state.copyWith(
          promoStatus: response.isApplied
              ? HomeRoamingConfirmationPromoStatus.applied
              : HomeRoamingConfirmationPromoStatus.failure,
          promoErrorMessage: '',
          promoResponse: response,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          promoStatus: HomeRoamingConfirmationPromoStatus.failure,
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
    HomeRoamingConfirmationTermsPressed event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    emit(state.copyWith(openTermsRequestId: state.openTermsRequestId + 1));
  }

  void _onTermsCheckboxToggled(
    HomeRoamingConfirmationTermsCheckboxToggled event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: event.isChecked));
  }

  void _onPayNow(
    HomeRoamingConfirmationPayNowPressed event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    if (!state.isTermsChecked) return;

    // Future: call API to create payment intent etc.
    emit(state.copyWith(payNowRequestId: state.payNowRequestId + 1));
  }
}
