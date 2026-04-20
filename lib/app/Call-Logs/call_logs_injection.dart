import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/transactions_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/call_logs_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/services/call_logs_api_client.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/services/transactions_api_client.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/transactions_repository.dart';

/// Sets up dependency injection for Call Logs feature.
///
/// Registers:
/// - CallLogsApiClient, TransactionsApiClient (API layer)
/// - CallLogsRepository, TransactionsRepository (business logic)
/// - CallLogsCubit, TransactionsCubit (state management)
Future<void> setupCallLogsInjection() async {
  // Register Call Logs API client
  if (!instance.isRegistered<CallLogsApiClient>()) {
    instance.registerLazySingleton<CallLogsApiClient>(
      () => CallLogsApiClient(networkService: instance<NetworkService>()),
    );
  }

  // Register Call Logs repository
  if (!instance.isRegistered<CallLogsRepository>()) {
    instance.registerLazySingleton<CallLogsRepository>(
      () => CallLogsRepository(apiClient: instance<CallLogsApiClient>()),
    );
  }

  // Register Call Logs cubit as factory (new instance per screen)
  if (!instance.isRegistered<CallLogsCubit>()) {
    instance.registerFactory<CallLogsCubit>(
      () => CallLogsCubit(repository: instance<CallLogsRepository>()),
    );
  }

  // Register Transactions API client
  if (!instance.isRegistered<TransactionsApiClient>()) {
    instance.registerLazySingleton<TransactionsApiClient>(
      () => TransactionsApiClient(networkService: instance<NetworkService>()),
    );
  }

  // Register Transactions repository
  if (!instance.isRegistered<TransactionsRepository>()) {
    instance.registerLazySingleton<TransactionsRepository>(
      () => TransactionsRepository(apiClient: instance<TransactionsApiClient>()),
    );
  }

  // Register Transactions cubit as factory (new instance per screen)
  if (!instance.isRegistered<TransactionsCubit>()) {
    instance.registerFactory<TransactionsCubit>(
      () => TransactionsCubit(repository: instance<TransactionsRepository>()),
    );
  }
}
