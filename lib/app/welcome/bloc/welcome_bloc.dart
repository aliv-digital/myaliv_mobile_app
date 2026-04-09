import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
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
  WelcomeBloc({
    required this.repository,
    required this.appUiConfigCubit,
  }) : super(WelcomeInitial()) {
    // Registering the event handler for WelcomeLoaded
    on<WelcomeLoaded>(_onWelcomeLoaded);
    //test
  }

  // Event handler method for WelcomeLoaded
  Future<void> _onWelcomeLoaded(
      WelcomeLoaded event, Emitter<WelcomeState> emit) async {
    try {
      // Simulating data loading from the repository
      final isLoaded = await repository.loadData();
      if (isLoaded) {
        emit(WelcomeLoadedState(isLoaded: true)); // Successfully loaded data
      } else {
        emit(WelcomeInitial()); // Handle failure or no data
      }
    } catch (e) {
      emit(WelcomeInitial()); // Handle errors
    }
  }

  Future<void> _setLoggedInUserUiConfig() async {
    // Get account info from AccountInfoCubit (HydratedBloc)
    final accountInfoCubit = instance<AccountInfoCubit>();
    final account = accountInfoCubit.state.accountInfo;

    if (account == null) {
      if (kDebugMode) {
        debugPrint('⚠️ No account info available for UI config');
      }
      return;
    }

    final accountType = account.accountType;
    final paymentOption = account.paymentOption;

    if (kDebugMode) {
      debugPrint("Account Type : $accountType");
      debugPrint("Payment Option : $paymentOption");
    }

    appUiConfigCubit.setConfig(
      HomeUiConfig(
        userType: paymentOption == "PrePay" ? UserType.prepaid : UserType.postpaid,
        hasActivePlan: true,
        isFuturePlan: false,
        openMyLimits: false,
      ),
    );
  }

  /// Resolves destination for "ALIV Mobile" button:
  /// - If ticket exists in local storage -> go to Home
  /// - If ticket is missing -> go to Login
  Future<String> resolveAlivMobileRoute() async {
    final savedTicket = (await LocalStorage.getTicket())?.trim() ?? '';
    if (savedTicket.isEmpty) {
      return AppRoutes.logIn;
    } else {
      await _setLoggedInUserUiConfig();
      return AppRoutes.home;
    }
  }
}
