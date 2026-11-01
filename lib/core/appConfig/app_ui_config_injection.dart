import 'package:get_it/get_it.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

final _instance = GetIt.instance;

/// Register the app-wide [AppUiConfigCubit] singleton.
///
/// Must run before any feature that resolves it via DI — notably
/// `ActiveDevice.id()` (`lib/core/appConfig/active_device.dart`) which other
/// per-device features consult to decide the target device id.
Future<void> setupAppUiConfigInjection() async {
  _instance.registerLazySingleton<AppUiConfigCubit>(() => AppUiConfigCubit());
}
