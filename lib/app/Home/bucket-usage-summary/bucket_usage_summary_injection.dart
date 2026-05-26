import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/bucket_usage_summary_repository.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/services/bucket_usage_summary_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/repository/services/bucket_usage_summary_parser_service.dart';

/// Registers the bucket usage summary feature dependencies.
Future<void> setupBucketUsageSummaryInjection() async {
  instance.registerLazySingleton<BucketUsageSummaryApiService>(
    () => BucketUsageSummaryApiService(
      networkService: instance<NetworkService>(),
    ),
  );

  instance.registerLazySingleton<BucketUsageSummaryParserService>(
    () => BucketUsageSummaryParserService(),
  );

  instance.registerLazySingleton<BucketUsageSummaryRepository>(
    () => BucketUsageSummaryRepositoryImpl(
      apiService: instance<BucketUsageSummaryApiService>(),
      parserService: instance<BucketUsageSummaryParserService>(),
    ),
  );

  instance.registerLazySingleton<BucketUsageSummaryCubit>(
    () => BucketUsageSummaryCubit(instance<BucketUsageSummaryRepository>()),
  );
}
