import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/repository/change_password_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';

class _MockPasswordRepo extends Mock
    implements ChangePasswordPrepaidRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  late Map<String, String> storage;

  setUp(() {
    storage = {
      'auth.login_api_phone': '2428999999',
      'auth.login_display_phone': '(242)-899-9999',
      'auth.login_password': 'OldPassword123!',
      'auth.save_my_password': 'true',
    };

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
          if (call.method == 'read') {
            final key = call.arguments['key'] as String;
            return storage[key];
          }
          if (call.method == 'write') {
            final key = call.arguments['key'] as String;
            final value = call.arguments['value'] as String;
            storage[key] = value;
            return null;
          }
          if (call.method == 'delete') {
            final key = call.arguments['key'] as String;
            storage.remove(key);
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  group('CredentialStore password update', () {
    test(
      'updatePassword updates stored password and preserves phone and pref',
      () async {
        final store = CredentialStore();

        final before = await store.load();
        expect(before?.password, 'OldPassword123!');
        expect(before?.apiPhone, '2428999999');
        expect(before?.displayPhone, '(242)-899-9999');
        expect(await store.loadSaveMyPasswordPref(), isTrue);

        await store.updatePassword('NewPassword456!');

        final after = await store.load();
        expect(after?.password, 'NewPassword456!');
        expect(after?.apiPhone, '2428999999');
        expect(after?.displayPhone, '(242)-899-9999');
        expect(await store.loadSaveMyPasswordPref(), isTrue);
        expect(storage['auth.login_password'], 'NewPassword456!');
      },
    );

    test(
      'updatePassword populates phone when none was previously stored',
      () async {
        storage.clear();
        final store = CredentialStore();

        await store.updatePassword(
          'FreshPassword789!',
          apiPhone: '2428111111',
          displayPhone: '2428111111',
        );

        final creds = await store.load();
        expect(creds?.password, 'FreshPassword789!');
        expect(creds?.apiPhone, '2428111111');
        expect(creds?.displayPhone, '2428111111');
      },
    );
  });

  group(
    'ChangePasswordPrepaidBloc updates CredentialStore on password change',
    () {
      late _MockPasswordRepo repo;

      setUp(() {
        repo = _MockPasswordRepo();
      });

      test(
        'successful password submit updates CredentialStore password',
        () async {
          when(
            () => repo.changePassword(newPassword: any(named: 'newPassword')),
          ).thenAnswer((_) async => true);

          final bloc = ChangePasswordPrepaidBloc(
            repo,
            phoneNumber: '2428999999',
            verifyAction: (id) async => ActionVerifiedResult(
              attemptId: id,
              paymentMethod: ProtectedAccountAction.changePassword,
              canConsume: () => true,
            ),
            cancelVerification: () {},
            isAuthorizationCurrent: () => true,
          );

          bloc.add(const ChangePasswordPrepaidStarted());
          await Future<void>.delayed(Duration.zero);

          bloc.add(
            const ChangePasswordPrepaidNewChanged('UpdatedPassword123!'),
          );
          bloc.add(
            const ChangePasswordPrepaidConfirmChanged('UpdatedPassword123!'),
          );
          await Future<void>.delayed(Duration.zero);

          bloc.add(const ChangePasswordPrepaidSubmitPressed());
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);

          expect(bloc.state.status, ChangePasswordPrepaidStatus.success);
          expect(storage['auth.login_password'], 'UpdatedPassword123!');

          final creds = await CredentialStore().load();
          expect(creds?.password, 'UpdatedPassword123!');
          expect(creds?.apiPhone, '2428999999');

          await bloc.close();
        },
      );

      test(
        'failed password submit does not update CredentialStore password',
        () async {
          when(
            () => repo.changePassword(newPassword: any(named: 'newPassword')),
          ).thenAnswer((_) async => false);

          final bloc = ChangePasswordPrepaidBloc(
            repo,
            phoneNumber: '2428999999',
            verifyAction: (id) async => ActionVerifiedResult(
              attemptId: id,
              paymentMethod: ProtectedAccountAction.changePassword,
              canConsume: () => true,
            ),
            cancelVerification: () {},
            isAuthorizationCurrent: () => true,
          );

          bloc.add(const ChangePasswordPrepaidStarted());
          await Future<void>.delayed(Duration.zero);

          bloc.add(const ChangePasswordPrepaidNewChanged('FailedPassword123!'));
          bloc.add(
            const ChangePasswordPrepaidConfirmChanged('FailedPassword123!'),
          );
          await Future<void>.delayed(Duration.zero);

          bloc.add(const ChangePasswordPrepaidSubmitPressed());
          await Future<void>.delayed(Duration.zero);
          await Future<void>.delayed(Duration.zero);

          expect(bloc.state.status, ChangePasswordPrepaidStatus.failure);
          expect(storage['auth.login_password'], 'OldPassword123!');

          await bloc.close();
        },
      );
    },
  );
}
