import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/user_profile_receipt_repository.dart';
import 'user_profile_receipt_event.dart';
import 'user_profile_receipt_state.dart';

class UserProfileReceiptBloc
    extends Bloc<UserProfileReceiptEvent, UserProfileReceiptState> {
  final UserProfileReceiptRepository repository;

  UserProfileReceiptBloc({required this.repository})
    : super(UserProfileReceiptState.initial()) {
    on<UserProfileReceiptStarted>(_onStarted);
    on<UserProfileReceiptBackHomePressed>(_onBackHomePressed);
  }

  void _onStarted(
    UserProfileReceiptStarted event,
    Emitter<UserProfileReceiptState> emit,
  ) {
    emit(
      state.copyWith(
        status: UserProfileReceiptStatus.ready,
        data: repository.buildReceipt(event.args),
      ),
    );
  }

  void _onBackHomePressed(
    UserProfileReceiptBackHomePressed event,
    Emitter<UserProfileReceiptState> emit,
  ) {
    emit(state.copyWith(backHomeRequestId: state.backHomeRequestId + 1));
  }
}
