import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/support_models.dart';
import '../repository/support_repository.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  final SupportRepository repository;
  bool _isFaqOpening = false;

  SupportBloc({required this.repository}) : super(SupportState.initial()) {
    on<SupportStarted>(_onStarted);
    on<SupportMenuItemPressed>(_onMenuItemPressed);
    on<SupportCallPressed>(_onCallPressed);
    on<SupportLaunchHandled>(_onLaunchHandled);
  }

  void _onStarted(SupportStarted event, Emitter<SupportState> emit) {
    emit(
      state.copyWith(
        status: SupportStatus.ready,
        menuItems: repository.fetchMenuItems(),
        quickHelp: repository.fetchQuickHelpInfo(),
        chatMessages: repository.fetchChatMessages(),
      ),
    );
  }

  Future<void> _onMenuItemPressed(
    SupportMenuItemPressed event,
    Emitter<SupportState> emit,
  ) async {
    switch (event.item.action) {
      case SupportMenuAction.chatBot:
        _emitNavigation(emit, SupportNavigationTarget.chatBot);
        break;

      case SupportMenuAction.storeLocator:
        _emitLaunch(
          emit,
          uri: repository.storeLocatorUri,
          failureMessage: 'Could not open store locator',
        );
        break;

      case SupportMenuAction.callSupport:
        _emitNavigation(emit, SupportNavigationTarget.quickHelp);
        break;

      case SupportMenuAction.whatsapp:
        _emitLaunch(
          emit,
          uri: repository.whatsappUri,
          failureMessage: 'Could not launch WhatsApp',
        );
        break;

      case SupportMenuAction.faq:
        if (_isFaqOpening) {
          return;
        }

        _isFaqOpening = true;
        emit(state.copyWith(isFaqOpening: true));

        try {
          final Uri faqUri = await repository.fetchFaqUri();
          _emitLaunch(emit, uri: faqUri, failureMessage: 'Could not open FAQ');
        } catch (_) {
          _emitFailureLaunch(emit, failureMessage: 'Could not open FAQ');
        }
        break;
    }
  }

  void _onCallPressed(SupportCallPressed event, Emitter<SupportState> emit) {
    _emitLaunch(
      emit,
      uri: repository.callSupportUri,
      failureMessage: 'Could not launch dialer',
    );
  }

  void _onLaunchHandled(
    SupportLaunchHandled event,
    Emitter<SupportState> emit,
  ) {
    _isFaqOpening = false;
    emit(state.copyWith(isFaqOpening: false));
  }

  void _emitNavigation(
    Emitter<SupportState> emit,
    SupportNavigationTarget target,
  ) {
    final int nextId = state.actionSequence + 1;
    emit(
      state.copyWith(
        actionSequence: nextId,
        navigationRequest: SupportNavigationRequest(id: nextId, target: target),
      ),
    );
  }

  void _emitLaunch(
    Emitter<SupportState> emit, {
    required Uri uri,
    required String failureMessage,
  }) {
    final int nextId = state.actionSequence + 1;
    emit(
      state.copyWith(
        actionSequence: nextId,
        launchRequest: SupportLaunchRequest(
          id: nextId,
          uri: uri,
          failureMessage: failureMessage,
        ),
      ),
    );
  }

  void _emitFailureLaunch(
    Emitter<SupportState> emit, {
    required String failureMessage,
  }) {
    final int nextId = state.actionSequence + 1;
    emit(
      state.copyWith(
        actionSequence: nextId,
        launchRequest: SupportLaunchRequest(
          id: nextId,
          uri: Uri.parse('https://www.bealiv.com'),
          failureMessage: failureMessage,
        ),
      ),
    );
  }
}
