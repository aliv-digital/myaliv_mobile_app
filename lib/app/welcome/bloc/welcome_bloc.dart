import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import '../../Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import '../../Home/home/data/home_ui_config.dart';
import 'welcome_event.dart';
import 'welcome_state.dart';
import '../repository/welcome_repository.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  final WelcomeRepository repository;
  final AppUiConfigCubit appUiConfigCubit;

  // Constructor
  WelcomeBloc({required this.repository, required this.appUiConfigCubit})
    : super(WelcomeInitial()) {
    // Registering the event handler for WelcomeLoaded
    on<WelcomeLoaded>(_onWelcomeLoaded);
    //test
  }

  // Event handler method for WelcomeLoaded
  Future<void> _onWelcomeLoaded(
    WelcomeLoaded event,
    Emitter<WelcomeState> emit,
  ) async {
    try {
      // Simulating data loading from the repository
      final data = await repository.loadData();
      if (data.isLoaded) {
        emit(
          WelcomeLoadedState(
            isLoaded: true,
            mobileImageUrl: data.mobileImageUrl,
          ),
        ); // Successfully loaded data
      } else {
        emit(WelcomeInitial()); // Handle failure or no data
      }
    } catch (e) {
      emit(WelcomeInitial()); // Handle errors
    }
  }

  Future<void> _setLoggedInUserUiConfig() async {
    final accountInfoCubit = instance<AccountInfoCubit>();
    final account = accountInfoCubit.state.accountInfo;

    if (account == null) {
      if (kDebugMode) debugPrint('⚠️ No account info available for UI config');
      return;
    }

    if (kDebugMode) {
      debugPrint("Account Type : ${account.accountType}");
      debugPrint("Payment Option : ${account.paymentOption}");
    }

    // Re-fetch role on cold restart so restrictions survive app kills.
    final deviceLimitsCubit = instance<DeviceLimitsCubit>();
    await deviceLimitsCubit.loadDeviceLimits(forceRefresh: true);
    final primaryDevice = deviceLimitsCubit.state.deviceLimits;

    LineRole lineRole = LineRole.parent;
    if (primaryDevice != null) {
      final roleId = await instance<RoleApiClient>().fetchRoleId(
        primaryDevice.deviceId,
      );
      if (account.parentAccountId == 0) {
        lineRole = LineRole.parent;
      } else if (roleId == 4) {
        lineRole = LineRole.fullAccess;
      } else {
        lineRole = LineRole.readOnly;
      }
    }

    appUiConfigCubit.setConfig(
      HomeUiConfig(
        userType: accountInfoCubit.state.isPostpaid
            ? UserType.postpaid
            : UserType.prepaid,
        hasActivePlan: false,
        isFuturePlan: false,
        openMyLimits: false,
        lineRole: lineRole,
      ),
    );
  }

  /// Resolves destination for "ALIV Mobile" button:
  /// - If a valid JWT session exists -> go to Home
  /// - Otherwise -> go to Login
  Future<String> resolveAlivMobileRoute() async {
    final session = instance<AuthManager>().currentSession;
    if (session == null || session.refreshExpired) {
      return AppRoutes.logIn;
    }
    await _setLoggedInUserUiConfig();
    return AppRoutes.home;
  }
}
