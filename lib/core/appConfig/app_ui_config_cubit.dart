import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/Home/home/data/home_ui_config.dart';

/// Single source of truth for prepaid/postpaid UI behavior.
///
/// Why this exists:
/// - user type should be decided once and reused everywhere
/// - router/screens/widgets should not each invent their own config
/// - OTP/login flow can update this later from real API response
class AppUiConfigCubit extends Cubit<HomeUiConfig> {
  AppUiConfigCubit()
      : super(
          const HomeUiConfig(
            userType: UserType.postpaid,
            hasActivePlan: true,
            isFuturePlan: false,
          ),
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
      ),
    );
  }

  /// Opens Usage screen with the "future plans" tab selected.
  void showFuturePlansView() {
    emit(
      state.copyWith(
        openMyLimits: false,
        isFuturePlan: true,
      ),
    );
  }

  /// Clears one-time navigation intent after the target screen uses it.
  void clearNavigationIntent() {
    if (!state.openMyLimits && !state.isFuturePlan) {
      return;
    }

    emit(
      state.copyWith(
        openMyLimits: false,
        isFuturePlan: false,
      ),
    );
  }
}
