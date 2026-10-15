import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/bloc/create_password_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/bloc/create_password_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/bloc/create_password_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/repository/create_password_repository.dart';

class _Repository extends Mock implements CreatePasswordRepository {}

void main() {
  late _Repository repository;
  late CreatePasswordBloc bloc;

  setUp(() {
    repository = _Repository();
    bloc = CreatePasswordBloc(repository: repository);
    when(
      () => repository.createPassword(password: any(named: 'password')),
    ).thenAnswer((_) async {});
  });

  tearDown(() => bloc.close());

  Future<CreatePasswordState> change(CreatePasswordEvent event) {
    final next = bloc.stream.first;
    bloc.add(event);
    return next;
  }

  test('untouched fields have no inline error', () {
    expect(bloc.state.passwordError, isNull);
    expect(bloc.state.confirmPasswordError, isNull);
    expect(bloc.state.canSubmit, isFalse);
    verifyZeroInteractions(repository);
  });

  test('minimum length is checked first on every password edit', () async {
    for (final password in ['A', 'Abc123', 'Abc1234', '   ']) {
      final state = await change(PasswordChanged(password));
      expect(state.passwordError, 'Password must be 8 characters long');
      expect(state.confirmPasswordError, isNull);
      expect(state.canSubmit, isFalse);
    }
    verifyZeroInteractions(repository);
  });

  test(
    'length feedback disappears at eight and sixty-four characters',
    () async {
      await change(const PasswordChanged('short'));
      expect(
        (await change(const PasswordChanged('Abc12345'))).passwordError,
        isNull,
      );
      expect(
        (await change(PasswordChanged('a' * 65))).passwordError,
        'Password must be 64 characters or fewer.',
      );
      expect(bloc.state.canSubmit, isFalse);
      expect((await change(PasswordChanged('a' * 64))).passwordError, isNull);
    },
  );

  test('deleting an edited password shows minimum-length feedback', () async {
    await change(const PasswordChanged('Abc12345'));
    expect(
      (await change(const PasswordChanged(''))).passwordError,
      'Password must be 8 characters long',
    );
  });

  test(
    'confirmation is quiet until edited, then follows either field',
    () async {
      await change(const PasswordChanged('Abc12345'));
      await change(const PasswordChanged('Abc123456'));
      expect(bloc.state.confirmPasswordError, isNull);
      expect(
        (await change(
          const ConfirmPasswordChanged('Abc1234'),
        )).confirmPasswordError,
        'Passwords do not match.',
      );
      expect(
        (await change(
          const ConfirmPasswordChanged('Abc123456'),
        )).confirmPasswordError,
        isNull,
      );
      expect(bloc.state.canSubmit, isTrue);
      expect(
        (await change(const PasswordChanged('Abc12345'))).confirmPasswordError,
        'Passwords do not match.',
      );
      expect(
        (await change(const PasswordChanged('Abc123456'))).confirmPasswordError,
        isNull,
      );
    },
  );

  test('clearing an edited confirmation still revalidates mismatch', () async {
    await change(const PasswordChanged('Abc12345'));
    await change(const ConfirmPasswordChanged('Abc12345'));
    expect(
      (await change(const ConfirmPasswordChanged(''))).confirmPasswordError,
      'Passwords do not match.',
    );
  });

  test(
    'visibility changes preserve interaction flags and inline errors',
    () async {
      await change(const PasswordChanged('short'));
      await change(const ConfirmPasswordChanged('other'));
      await change(const TogglePasswordVisibility());
      await change(const ToggleConfirmPasswordVisibility());
      expect(bloc.state.obscurePassword, isFalse);
      expect(bloc.state.obscureConfirm, isFalse);
      expect(bloc.state.passwordError, 'Password must be 8 characters long');
      expect(bloc.state.confirmPasswordError, 'Passwords do not match.');
      expect(bloc.state.hasEditedPassword, isTrue);
      expect(bloc.state.hasEditedConfirmation, isTrue);
    },
  );

  test('interaction flags participate in state equality and copyWith', () {
    const initial = CreatePasswordState();
    final edited = initial.copyWith(
      hasEditedPassword: true,
      hasEditedConfirmation: true,
    );
    expect(edited, isNot(initial));
    expect(edited.copyWith(), edited);
    expect(edited.copyWith(hasEditedPassword: false).passwordError, isNull);
    expect(edited.hasEditedConfirmation, isTrue);
  });

  for (final password in [
    'abcdefgh',
    '12345678',
    '!!!!!!!!',
    'Abc12345',
    'a' * 64,
    '  Abc12345  ',
  ]) {
    test(
      'existing policy accepts matching password ${password.length} / ${password.trim().length} / ${password[0]}',
      () async {
        await change(PasswordChanged(password));
        await change(ConfirmPasswordChanged(password.trim()));
        expect(bloc.state.passwordError, isNull);
        expect(bloc.state.confirmPasswordError, isNull);
        expect(bloc.state.canSubmit, isTrue);
        final success = bloc.stream.firstWhere(
          (s) => s.status == CreatePasswordStatus.success,
        );
        bloc.add(const SubmitCreatePassword());
        await success;
        verify(
          () => repository.createPassword(password: password.trim()),
        ).called(1);
      },
    );
  }
}
