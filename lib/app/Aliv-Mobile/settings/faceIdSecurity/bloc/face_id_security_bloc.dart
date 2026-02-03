import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/face_id_security_repository.dart';
import 'face_id_security_event.dart';
import 'face_id_security_state.dart';

class FaceIdSecurityBloc extends Bloc<FaceIdSecurityEvent, FaceIdSecurityState> {
  FaceIdSecurityBloc({
    required FaceIdSecurityRepository repository,
  })  : _repository = repository,
        super(FaceIdSecurityState.initial()) {
    on<FaceIdSecurityStarted>(_onStarted);
    on<FaceIdAgreePressed>(_onAgreePressed);
    on<FaceIdSecurityNavConsumed>(_onNavConsumed);
  }

  final FaceIdSecurityRepository _repository;

  Future<void> _onStarted(
      FaceIdSecurityStarted event,
      Emitter<FaceIdSecurityState> emit,
      ) async {
    emit(state.copyWith(status: FaceIdSecurityStatus.loading, errorMessage: null));
    try {
      final content = await _repository.fetchContent();
      emit(state.copyWith(status: FaceIdSecurityStatus.ready, content: content));
    } catch (e) {
      emit(state.copyWith(status: FaceIdSecurityStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onAgreePressed(
      FaceIdAgreePressed event,
      Emitter<FaceIdSecurityState> emit,
      ) {
    emit(state.copyWith(navTarget: FaceIdSecurityNavTarget.back));
  }

  void _onNavConsumed(
      FaceIdSecurityNavConsumed event,
      Emitter<FaceIdSecurityState> emit,
      ) {
    emit(state.copyWith(navTarget: FaceIdSecurityNavTarget.none));
  }
}
