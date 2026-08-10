import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/Home/home/data/home_ui_config.dart';

/// Single source of truth for prepaid/postpaid UI behavior.
///
/// Why this exists:
/// - user type should be decided once and reused everywhere
/// - router/screens/widgets should not each invent their own config
/// - OTP/login flow can update this later from real API response
class AppUiConfigCubit extends Cubit<HomeUiConfig> {
  AppUiConfigCubit({HomeUiConfig? initialConfig})
      : super(initialConfig ?? _defaultConfig);

  /// Sensible default for guest / first-run: prepaid (the more common
  /// case, and the prepaid tabs render harmlessly for edge cases).
  ///
  /// For cold-start with an existing session, callers should pass an
  /// [initialConfig] derived from the persisted `AccountInfoCubit`
  /// state — otherwise a postpaid user briefly sees prepaid tabs (or
  /// vice versa) until [setConfig] runs.
  static const _defaultConfig = HomeUiConfig(
    userType: UserType.prepaid,
    hasActivePlan: false,
    isFuturePlan: false,
    isCurrentPlan: false,
  );

  /// Replaces the whole config at once.
  void setConfig(HomeUiConfig config) {
    emit(config);
  }

  /// Updates only the user type and keeps other flags unchanged.
  void setUserType(UserType userType) {
    emit(state.copyWith(userType: userType));
  }

  /// Updates active plan status without touching other flags.
  void setHasActivePlan(bool hasActivePlan) {
    emit(state.copyWith(hasActivePlan: hasActivePlan));
  }

  /// Opens Usage screen with the "my limits" tab selected.
  void showMyLimitsView() {
    emit(
      state.copyWith(
        openMyLimits: true,
        isFuturePlan: false,
        isCurrentPlan: false,
      ),
    );
  }

  /// Opens Usage screen with the "future plans" tab selected.
  void showFuturePlansView() {
    emit(
      state.copyWith(
        openMyLimits: false,
        isFuturePlan: true,
        isCurrentPlan: false,
      ),
    );
  }

  /// Opens Usage screen with the "current plans" tab selected.
  void showCurrentPlansView() {
    emit(
      state.copyWith(
        openMyLimits: false,
        isFuturePlan: false,
        isCurrentPlan: true,
      ),
    );
  }

  /// Clears one-time navigation intent after the target screen uses it.
  void clearNavigationIntent() {
    if (!state.openMyLimits && !state.isFuturePlan && !state.isCurrentPlan) {
      return;
    }

    emit(
      state.copyWith(
        openMyLimits: false,
        isFuturePlan: false,
        isCurrentPlan: false,
      ),
    );
  }
}
