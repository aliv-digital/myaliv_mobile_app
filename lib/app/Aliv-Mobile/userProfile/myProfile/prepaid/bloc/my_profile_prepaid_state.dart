import 'package:equatable/equatable.dart';
import '../model/my_profile_prepaid_model.dart';

enum MyProfilePrepaidStatus { initial, loading, success, failure }

enum MyProfilePrepaidNavAction {
  none,
  back,
  home,
  editEmail,
  changePassword,
}

class MyProfilePrepaidState extends Equatable {
  final MyProfilePrepaidStatus status;
  final MyProfilePrepaidModel? data;
  final String? errorMessage;

  // navigation/action signal
  final MyProfilePrepaidNavAction navAction;
  final int navRequestId;

  const MyProfilePrepaidState({
    required this.status,
    required this.data,
    required this.errorMessage,
    required this.navAction,
    required this.navRequestId,
  });

  factory MyProfilePrepaidState.initial() {
    return const MyProfilePrepaidState(
      status: MyProfilePrepaidStatus.initial,
      data: null,
      errorMessage: null,
      navAction: MyProfilePrepaidNavAction.none,
      navRequestId: 0,
    );
  }

  MyProfilePrepaidState copyWith({
    MyProfilePrepaidStatus? status,
    MyProfilePrepaidModel? data,
    String? errorMessage,
    MyProfilePrepaidNavAction? navAction,
    int? navRequestId,
  }) {
    return MyProfilePrepaidState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
      navAction: navAction ?? this.navAction,
      navRequestId: navRequestId ?? this.navRequestId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    data,
    errorMessage,
    navAction,
    navRequestId,
  ];
}
