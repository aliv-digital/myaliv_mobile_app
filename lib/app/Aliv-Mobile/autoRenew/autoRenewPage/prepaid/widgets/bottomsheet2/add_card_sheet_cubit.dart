import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AddCardSheetStatus { idle, loading, success, failure }

class AddCardSheetState extends Equatable {
  final List<String> months;
  final List<int> years;

  final String selectedMonth;
  final int selectedYear;

  final AddCardSheetStatus status;
  final String? errorMessage;

  const AddCardSheetState({
    required this.months,
    required this.years,
    required this.selectedMonth,
    required this.selectedYear,
    required this.status,
    required this.errorMessage,
  });

  factory AddCardSheetState.initial() => const AddCardSheetState(
    months: [],
    years: [],
    selectedMonth: 'January',
    selectedYear: 2025,
    status: AddCardSheetStatus.idle,
    errorMessage: null,
  );

  bool get canSubmit => status != AddCardSheetStatus.loading;

  AddCardSheetState copyWith({
    List<String>? months,
    List<int>? years,
    String? selectedMonth,
    int? selectedYear,
    AddCardSheetStatus? status,
    String? errorMessage,
  }) {
    return AddCardSheetState(
      months: months ?? this.months,
      years: years ?? this.years,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    months,
    years,
    selectedMonth,
    selectedYear,
    status,
    errorMessage,
  ];
}

class AddCardSheetCubit extends Cubit<AddCardSheetState> {
  AddCardSheetCubit() : super(AddCardSheetState.initial());

  void init() {
    final months = const [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    final now = DateTime.now();
    final years = List<int>.generate(12, (i) => now.year + i); // next 12 years

    emit(state.copyWith(
      months: months,
      years: years,
      selectedMonth: months.first,
      selectedYear: years.first,
      status: AddCardSheetStatus.idle,
      errorMessage: null,
    ));
  }

  void monthChanged(String value) {
    emit(state.copyWith(selectedMonth: value, errorMessage: null));
  }

  void yearChanged(int value) {
    emit(state.copyWith(selectedYear: value, errorMessage: null));
  }

  Future<void> savePressed() async {
    if (state.status == AddCardSheetStatus.loading) return;

    emit(state.copyWith(status: AddCardSheetStatus.loading, errorMessage: null));

    try {
      // ✅ API integrate later:
      // await repo.saveCard(month: state.selectedMonth, year: state.selectedYear);

      await Future<void>.delayed(const Duration(milliseconds: 450));
      emit(state.copyWith(status: AddCardSheetStatus.success));
    } catch (_) {
      emit(state.copyWith(
        status: AddCardSheetStatus.failure,
        errorMessage: 'Failed to save card. Try again.',
      ));
    }
  }
}
