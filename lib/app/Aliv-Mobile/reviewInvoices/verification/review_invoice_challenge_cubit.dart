import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';

import 'review_invoice_verification_repository.dart';

enum ReviewInvoiceChallengeStatus { initial, loading, success, failure }

class ReviewInvoiceChallengeState extends Equatable {
  const ReviewInvoiceChallengeState({
    this.status = ReviewInvoiceChallengeStatus.initial,
    this.challenge,
    this.errorMessage,
  });

  final ReviewInvoiceChallengeStatus status;
  final CallLogsChallenge? challenge;
  final String? errorMessage;

  bool get isLoading => status == ReviewInvoiceChallengeStatus.loading;

  ReviewInvoiceChallengeState copyWith({
    ReviewInvoiceChallengeStatus? status,
    CallLogsChallenge? challenge,
    String? errorMessage,
  }) {
    return ReviewInvoiceChallengeState(
      status: status ?? this.status,
      challenge: challenge ?? this.challenge,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, challenge, errorMessage];
}

class ReviewInvoiceChallengeCubit extends Cubit<ReviewInvoiceChallengeState> {
  ReviewInvoiceChallengeCubit({
    required ReviewInvoiceVerificationRepository repository,
  }) : _repository = repository,
       super(const ReviewInvoiceChallengeState());

  final ReviewInvoiceVerificationRepository _repository;

  Future<void> requestChallenge() async {
    if (state.status != ReviewInvoiceChallengeStatus.initial || isClosed) {
      return;
    }
    emit(
      const ReviewInvoiceChallengeState(
        status: ReviewInvoiceChallengeStatus.loading,
      ),
    );
    try {
      final challenge = await _repository.requestChallenge();
      if (!isClosed) {
        emit(
          ReviewInvoiceChallengeState(
            status: ReviewInvoiceChallengeStatus.success,
            challenge: challenge,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          ReviewInvoiceChallengeState(
            status: ReviewInvoiceChallengeStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }
}
