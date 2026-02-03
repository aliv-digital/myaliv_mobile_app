import 'package:equatable/equatable.dart';

abstract class FaceIdSecurityEvent extends Equatable {
  const FaceIdSecurityEvent();

  @override
  List<Object?> get props => [];
}

class FaceIdSecurityStarted extends FaceIdSecurityEvent {
  const FaceIdSecurityStarted();
}

class FaceIdAgreePressed extends FaceIdSecurityEvent {
  const FaceIdAgreePressed();
}

class FaceIdSecurityNavConsumed extends FaceIdSecurityEvent {
  const FaceIdSecurityNavConsumed();
}
