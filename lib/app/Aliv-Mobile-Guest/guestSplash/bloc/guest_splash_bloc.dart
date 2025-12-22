import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:country_picker/country_picker.dart';

import '../model/guest_purchase_plan_input.dart';
import 'guest_splash_event.dart';
import 'guest_splash_state.dart';
import '../repository/guest_splash_repository.dart';


class GuestSplashBloc extends Bloc<GuestSplashEvent, GuestSplashState> {
  final GuestSplashRepository repository;

  GuestSplashBloc(this.repository) : super(GuestSplashInitial()) {
    on<GuestSplashLoaded>(_onGuestSplashLoaded);

    // ✅ Bottom sheet handlers
    on<GuestSplashPurchasePlanInit>(_onPurchasePlanInit);
    on<GuestSplashPurchasePlanCountryChanged>(_onPurchaseCountryChanged);
    on<GuestSplashPurchasePlanPhoneChanged>(_onPurchasePhoneChanged);
    on<GuestSplashPurchasePlanConfirmPhoneChanged>(_onPurchaseConfirmPhoneChanged);
    on<GuestSplashPurchasePlanSubmitted>(_onPurchaseSubmitted);
    on<GuestSplashPurchasePlanReset>(_onPurchaseReset);
  }

  Future<void> _onGuestSplashLoaded(
      GuestSplashLoaded event,
      Emitter<GuestSplashState> emit,
      ) async {
    try {
      final isLoaded = await repository.loadData();
      if (isLoaded) {
        emit(GuestSplashLoadedState(isLoaded: true));
      } else {
        emit(GuestSplashInitial());
      }
    } catch (e) {
      emit(GuestSplashInitial());
    }
  }

  void _onPurchasePlanInit(
      GuestSplashPurchasePlanInit event,
      Emitter<GuestSplashState> emit,
      ) {
    final s = state;
    if (s is! GuestSplashLoadedState) return;

    emit(
      s.copyWith(
        purchaseCountry: event.initialCountry ?? s.purchaseCountry,
        purchasePhone: '',
        purchaseConfirmPhone: '',
        purchaseStatus: GuestSplashPurchasePlanStatus.idle,
        clearPurchaseErrorMessage: true,
        clearPurchaseResult: true,
      ),
    );
  }

  void _onPurchaseCountryChanged(
      GuestSplashPurchasePlanCountryChanged event,
      Emitter<GuestSplashState> emit,
      ) {
    final s = state;
    if (s is! GuestSplashLoadedState) return;

    emit(
      s.copyWith(
        purchaseCountry: event.country,
        purchaseStatus: GuestSplashPurchasePlanStatus.idle,
        clearPurchaseErrorMessage: true,
        clearPurchaseResult: true,
      ),
    );
  }

  void _onPurchasePhoneChanged(
      GuestSplashPurchasePlanPhoneChanged event,
      Emitter<GuestSplashState> emit,
      ) {
    final s = state;
    if (s is! GuestSplashLoadedState) return;

    emit(
      s.copyWith(
        purchasePhone: event.phone,
        purchaseStatus: GuestSplashPurchasePlanStatus.idle,
        clearPurchaseErrorMessage: true,
        clearPurchaseResult: true,
      ),
    );
  }

  void _onPurchaseConfirmPhoneChanged(
      GuestSplashPurchasePlanConfirmPhoneChanged event,
      Emitter<GuestSplashState> emit,
      ) {
    final s = state;
    if (s is! GuestSplashLoadedState) return;

    emit(
      s.copyWith(
        purchaseConfirmPhone: event.phone,
        purchaseStatus: GuestSplashPurchasePlanStatus.idle,
        clearPurchaseErrorMessage: true,
        clearPurchaseResult: true,
      ),
    );
  }

  void _onPurchaseSubmitted(
      GuestSplashPurchasePlanSubmitted event,
      Emitter<GuestSplashState> emit,
      ) {
    final s = state;
    if (s is! GuestSplashLoadedState) return;

    final c = s.purchaseCountry;
    final p1 = s.purchasePhone.trim();
    final p2 = s.purchaseConfirmPhone.trim();

    if (c == null) {
      emit(s.copyWith(purchaseStatus: GuestSplashPurchasePlanStatus.failure, purchaseErrorMessage: 'Select a country'));
      return;
    }
    if (p1.isEmpty) {
      emit(s.copyWith(purchaseStatus: GuestSplashPurchasePlanStatus.failure, purchaseErrorMessage: 'Enter mobile number'));
      return;
    }
    if (p2.isEmpty) {
      emit(s.copyWith(
          purchaseStatus: GuestSplashPurchasePlanStatus.failure, purchaseErrorMessage: 'Confirm mobile number'));
      return;
    }
    if (p1 != p2) {
      emit(s.copyWith(purchaseStatus: GuestSplashPurchasePlanStatus.failure, purchaseErrorMessage: 'Numbers do not match'));
      return;
    }

    final result = GuestSplashPurchasePlanInput(
      countryCode: c.countryCode,
      dialCode: c.phoneCode,
      phone: p1,
      confirmPhone: p2,
    );

    emit(
      s.copyWith(
        purchaseStatus: GuestSplashPurchasePlanStatus.success,
        clearPurchaseErrorMessage: true,
        purchaseResult: result,
      ),
    );
  }

  void _onPurchaseReset(
      GuestSplashPurchasePlanReset event,
      Emitter<GuestSplashState> emit,
      ) {
    final s = state;
    if (s is! GuestSplashLoadedState) return;

    emit(
      s.copyWith(
        purchaseStatus: GuestSplashPurchasePlanStatus.idle,
        clearPurchaseErrorMessage: true,
        clearPurchaseResult: true,
      ),
    );
  }
}
