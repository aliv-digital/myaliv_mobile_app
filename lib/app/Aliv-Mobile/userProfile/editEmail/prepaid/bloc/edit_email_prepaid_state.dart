import 'package:equatable/equatable.dart';

enum EditEmailPrepaidStatus { initial, loading, ready, submitting, success, failure }

class EditEmailPrepaidData extends Equatable {
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String email;

  const EditEmailPrepaidData({
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.email,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, gender, email];
}

class EditEmailPrepaidState extends Equatable {
  final EditEmailPrepaidStatus status;
  final EditEmailPrepaidData? data;
  final String email; // editable
  final String? errorMessage;

  const EditEmailPrepaidState({
    required this.status,
    required this.data,
    required this.email,
    required this.errorMessage,
  });

  factory EditEmailPrepaidState.initial() {
    return const EditEmailPrepaidState(
      status: EditEmailPrepaidStatus.initial,
      data: null,
      email: '',
      errorMessage: null,
    );
  }

  bool get isEmailValid {
    final v = email.trim();
    if (v.isEmpty) return false;
    // basic email check
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
  }

  EditEmailPrepaidState copyWith({
    EditEmailPrepaidStatus? status,
    EditEmailPrepaidData? data,
    String? email,
    String? errorMessage,
  }) {
    return EditEmailPrepaidState(
      status: status ?? this.status,
      data: data ?? this.data,
      email: email ?? this.email,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, email, errorMessage];
}
