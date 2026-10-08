import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/cubit/review_invoice_postpaid_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/cubit/review_invoice_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/models/invoice_item.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/review_invoice_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_pdf_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_challenge_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_verification_repository.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _Pdf extends Mock implements InvoicePdfService {}

class _Repo extends Mock implements ReviewInvoicePostpaidRepository {}

class _Online extends InternetConnection {
  _Online() : super.createInstance();
  @override
  Future<bool> get hasInternetAccess async => true;
}

class _DiskPdf extends InvoicePdfService {
  _DiskPdf(this.directory);
  final Directory directory;
  @override
  Future<String> getCachePath(int invoiceId) async =>
      '${directory.path}/invoice_$invoiceId.pdf';
}

InvoiceItem _invoice() => InvoiceItem(
  invoiceId: 42,
  accountId: 1,
  invoiceNo: 'synthetic',
  invoicePath: 'fallback.pdf',
  files: ['primary.pdf'],
  amount: 10,
  invoiceDate: DateTime(2026),
  dueDate: DateTime(2026, 1, 15),
);

void main() {
  test('challenge state equality, copyWith and loading getter', () {
    const initial = ReviewInvoiceChallengeState();
    expect(initial, const ReviewInvoiceChallengeState());
    expect(initial.isLoading, isFalse);
    final loading = initial.copyWith(
      status: ReviewInvoiceChallengeStatus.loading,
    );
    expect(loading.isLoading, isTrue);
    expect(loading, isNot(initial));
    final failure = loading.copyWith(
      status: ReviewInvoiceChallengeStatus.failure,
      errorMessage: 'synthetic failure',
    );
    expect(failure.errorMessage, 'synthetic failure');
    expect(
      failure
          .copyWith(status: ReviewInvoiceChallengeStatus.initial)
          .errorMessage,
      isNull,
    );
  });
  test('existing model parses amount variants, dates and primary PDF path', () {
    for (final amount in [10, 10.0, '10.0']) {
      final model = InvoiceItem.fromJson({
        'InvoiceID': 42,
        'InvoiceAmount': amount,
        'InvoiceDate': '2026-01-01 04:00:00',
        'Files': ['primary.pdf'],
      });
      expect(model.amount, 10);
      expect(model.invoiceDate, DateTime(2026, 1, 1, 4));
      expect(model.primaryFilePath, 'primary.pdf');
    }
  });

  test(
    'existing invoice API paths and authenticated GET requests stay unchanged',
    () async {
      final network = _Network();
      when(
        () => network.request<String>(Api.invoices, method: HttpMethod.get),
      ).thenAnswer(
        (_) async => Response<String>(
          requestOptions: RequestOptions(path: Api.invoices),
          data: '[]',
        ),
      );
      const filename = r'folder\some file.pdf';
      final pdfUrl = Api.invoicePdf(42, filename);
      when(
        () => network.request<String>(pdfUrl, method: HttpMethod.get),
      ).thenAnswer(
        (_) async => Response<String>(
          requestOptions: RequestOptions(path: pdfUrl),
          data: jsonEncode({'InvoiceFile': 'cGRm'}),
        ),
      );
      final api = InvoiceApiClient(networkService: network);
      expect(await api.fetchInvoices(), '[]');
      expect(
        await api.fetchInvoicePdf(invoiceId: 42, filename: filename),
        'cGRm',
      );
      expect(Uri.parse(pdfUrl).queryParameters['filename'], filename);
      verify(
        () => network.request<String>(Api.invoices, method: HttpMethod.get),
      ).called(1);
      verify(
        () => network.request<String>(pdfUrl, method: HttpMethod.get),
      ).called(1);
    },
  );

  test(
    'existing repository sorts newest first and passes PDF through decoder/cache',
    () async {
      final network = _Network();
      final pdf = _Pdf();
      when(
        () => network.request<String>(Api.invoices, method: HttpMethod.get),
      ).thenAnswer(
        (_) async => Response<String>(
          requestOptions: RequestOptions(path: Api.invoices),
          data: jsonEncode([
            {'InvoiceID': 1, 'InvoiceDate': '2026-01-01'},
            {'InvoiceID': 2, 'InvoiceDate': '2026-02-01'},
          ]),
        ),
      );
      final url = Api.invoicePdf(42, 'primary.pdf');
      when(
        () => network.request<String>(url, method: HttpMethod.get),
      ).thenAnswer(
        (_) async => Response<String>(
          requestOptions: RequestOptions(path: url),
          data: '{"InvoiceFile":"cGRm"}',
        ),
      );
      when(
        () => pdf.decodeAndSavePdf('cGRm', 42),
      ).thenAnswer((_) async => '/tmp/synthetic.pdf');
      final repo = ReviewInvoicePostpaidRepositoryImpl(
        apiClient: InvoiceApiClient(networkService: network),
        pdfService: pdf,
      );
      expect((await repo.fetchInvoices()).map((i) => i.invoiceId), [2, 1]);
      expect(
        await repo.downloadInvoicePdf(
          invoiceId: 42,
          filename: 'primary.pdf',
          invoiceNo: 'synthetic',
        ),
        '/tmp/synthetic.pdf',
      );
      verify(() => pdf.decodeAndSavePdf('cGRm', 42)).called(1);
    },
  );

  test(
    'real PDF decoder writes expected bytes and recognizes the cached file',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'invoice-otp-test-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final service = _DiskPdf(directory);
      expect(await service.isCached(42), isFalse);
      final bytes = utf8.encode('%PDF-1.7 synthetic test content');
      final encoded = base64Encode(bytes);
      final path = await service.decodeAndSavePdf(
        '${encoded.substring(0, 4)}\n${encoded.substring(4)}',
        42,
      );
      expect(await File(path).readAsBytes(), bytes);
      expect(await service.isCached(42), isTrue);
    },
  );

  for (final cached in [false, true]) {
    for (final action in ['open', 'share', 'save']) {
      test(
        'existing $action ${cached ? 'cached' : 'downloaded'} PDF uses the correct path',
        () async {
          final pdf = _Pdf();
          final repo = _Repo();
          when(() => pdf.isCached(42)).thenAnswer((_) async => cached);
          when(
            () => pdf.getCachePath(42),
          ).thenAnswer((_) async => '/tmp/cached.pdf');
          when(
            () => repo.downloadInvoicePdf(
              invoiceId: 42,
              filename: 'primary.pdf',
              invoiceNo: 'synthetic',
            ),
          ).thenAnswer((_) async => '/tmp/downloaded.pdf');
          when(() => pdf.openPdf(any())).thenAnswer((_) async => true);
          when(() => pdf.sharePdf(any(), any())).thenAnswer((_) async {});
          when(
            () => pdf.savePdfToDownloads(any(), any()),
          ).thenAnswer((_) async => true);
          final cubit = ReviewInvoicePostpaidCubit(
            repository: repo,
            pdfService: pdf,
          );
          addTearDown(cubit.close);
          final invoice = _invoice();
          switch (action) {
            case 'open':
              await cubit.downloadAndOpenPdf(invoice);
            case 'share':
              await cubit.sharePdf(invoice);
            case 'save':
              await cubit.savePdfToDownloads(invoice);
          }
          final path = cached ? '/tmp/cached.pdf' : '/tmp/downloaded.pdf';
          switch (action) {
            case 'open':
              verify(() => pdf.openPdf(path)).called(1);
            case 'share':
              verify(() => pdf.sharePdf(path, 'synthetic')).called(1);
            case 'save':
              verify(() => pdf.savePdfToDownloads(path, 'synthetic')).called(1);
          }
          if (cached) {
            verifyNever(
              () => repo.downloadInvoicePdf(
                invoiceId: 42,
                filename: 'primary.pdf',
                invoiceNo: 'synthetic',
              ),
            );
          } else {
            verify(
              () => repo.downloadInvoicePdf(
                invoiceId: 42,
                filename: 'primary.pdf',
                invoiceNo: 'synthetic',
              ),
            ).called(1);
          }
          expect(cubit.state.isDownloading, isFalse);
        },
      );
    }
  }

  test(
    'existing load failure, Retry and empty response states remain unchanged',
    () async {
      final repo = _Repo();
      final cubit = ReviewInvoicePostpaidCubit(
        repository: repo,
        pdfService: _Pdf(),
      );
      addTearDown(cubit.close);
      when(repo.fetchInvoices).thenThrow(Exception('synthetic error'));
      await cubit.loadInvoices();
      expect(cubit.state.status, ReviewInvoiceStatus.failure);
      expect(cubit.state.errorMessage, 'Failed to load invoices');
      when(repo.fetchInvoices).thenAnswer((_) async => []);
      await cubit.loadInvoices();
      expect(cubit.state.status, ReviewInvoiceStatus.success);
      expect(cubit.state.invoices, isEmpty);
    },
  );

  test(
    'existing download failure clears loading and retains its error handling',
    () async {
      final pdf = _Pdf();
      final repo = _Repo();
      when(() => pdf.isCached(42)).thenAnswer((_) async => false);
      when(
        () => repo.downloadInvoicePdf(
          invoiceId: 42,
          filename: 'primary.pdf',
          invoiceNo: 'synthetic',
        ),
      ).thenThrow(Exception('synthetic error'));
      final cubit = ReviewInvoicePostpaidCubit(
        repository: repo,
        pdfService: pdf,
      );
      addTearDown(cubit.close);
      await cubit.downloadAndOpenPdf(_invoice());
      expect(cubit.state.isDownloading, isFalse);
      expect(cubit.state.downloadError, 'Failed to download invoice');
      cubit.clearDownloadError();
      expect(cubit.state.downloadError, isNull);
    },
  );

  test(
    'challenge reset separates old and new in-flight contexts; stale completion cannot clear the new one',
    () async {
      final network = _Network();
      final auth = _Auth();
      when(() => auth.currentSession).thenReturn(
        TokenSession(
          accessToken: 'synthetic-access',
          refreshToken: 'synthetic-refresh',
          accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshExpiresAt: DateTime.now().add(const Duration(days: 1)),
        ),
      );
      final old = Completer<Response<dynamic>>();
      final newer = Completer<Response<dynamic>>();
      var requests = 0;
      when(
        () => network.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) => ++requests == 1 ? old.future : newer.future);
      final repository = ReviewInvoiceVerificationRepository(
        networkService: network,
        authManager: auth,
        internetConnection: _Online(),
        phoneNumberProvider: () async => '2425550100',
      );
      final first = repository.requestChallenge();
      await Future<void>.delayed(Duration.zero);
      repository.reset();
      final second = repository.requestChallenge();
      await Future<void>.delayed(Duration.zero);
      old.complete(
        Response<dynamic>(
          requestOptions: RequestOptions(path: Api.challengeOtpUrl),
          data: {'mfa_token': 'synthetic-old'},
        ),
      );
      await first;
      expect(identical(repository.requestChallenge(), second), isTrue);
      expect(requests, 2);
      newer.complete(
        Response<dynamic>(
          requestOptions: RequestOptions(path: Api.challengeOtpUrl),
          data: {'mfa_token': 'synthetic-new'},
        ),
      );
      expect((await second).mfaToken, 'synthetic-new');
    },
  );

  test(
    'missing MFA blocks gate Cubit; retry uses a fresh challenge after failure',
    () async {
      final network = _Network();
      final auth = _Auth();
      when(() => auth.currentSession).thenReturn(
        TokenSession(
          accessToken: 'synthetic-access',
          refreshToken: 'synthetic-refresh',
          accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshExpiresAt: DateTime.now().add(const Duration(days: 1)),
        ),
      );
      var requests = 0;
      when(
        () => network.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: Api.challengeOtpUrl),
          data: ++requests == 1 ? {} : {'mfa_token': 'synthetic-retry'},
        ),
      );
      final repository = ReviewInvoiceVerificationRepository(
        networkService: network,
        authManager: auth,
        internetConnection: _Online(),
        phoneNumberProvider: () async => '2425550100',
      );
      final first = ReviewInvoiceChallengeCubit(repository: repository);
      await first.requestChallenge();
      expect(first.state.status, ReviewInvoiceChallengeStatus.failure);
      final retry = ReviewInvoiceChallengeCubit(repository: repository);
      await retry.requestChallenge();
      expect(retry.state.challenge?.mfaToken, 'synthetic-retry');
      await first.close();
      await retry.close();
    },
  );
}
