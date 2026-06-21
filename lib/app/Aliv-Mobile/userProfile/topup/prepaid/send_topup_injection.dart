import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/pay_from_wallet/pay_from_wallet_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';

Future<void> setupSendTopupInjection() async {
  instance.registerLazySingleton<SendTopupRepository>(
    () => SendTopupRepository(),
  );

  // Factory: each PayFromWalletSheet gets a fresh cubit so state
  // doesn't leak across multiple transfer attempts.
  instance.registerFactory<PayFromWalletCubit>(
    () => PayFromWalletCubit(instance<SendTopupRepository>()),
  );
}
