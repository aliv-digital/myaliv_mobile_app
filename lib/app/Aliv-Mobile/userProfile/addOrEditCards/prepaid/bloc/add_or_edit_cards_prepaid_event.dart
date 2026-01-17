import 'package:equatable/equatable.dart';

abstract class AddOrEditCardsPrepaidEvent extends Equatable {
  const AddOrEditCardsPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class AddOrEditCardsPrepaidStarted extends AddOrEditCardsPrepaidEvent {
  const AddOrEditCardsPrepaidStarted();
}

class AddOrEditCardsPrepaidDeletePressed extends AddOrEditCardsPrepaidEvent {
  final String cardId;
  const AddOrEditCardsPrepaidDeletePressed(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class AddOrEditCardsPrepaidAddNewCardPressed extends AddOrEditCardsPrepaidEvent {
  const AddOrEditCardsPrepaidAddNewCardPressed();
}

class AddOrEditCardsPrepaidHomePressed extends AddOrEditCardsPrepaidEvent {
  const AddOrEditCardsPrepaidHomePressed();
}

class AddOrEditCardsPrepaidNavigationConsumed extends AddOrEditCardsPrepaidEvent {
  const AddOrEditCardsPrepaidNavigationConsumed();
}

/// ✅ BottomSheet থেকে month/year সিলেক্ট করে "save card" চাপলে এই event যাবে
class AddOrEditCardsPrepaidSaveCardPressed extends AddOrEditCardsPrepaidEvent {
  final int month;
  final int year;

  const AddOrEditCardsPrepaidSaveCardPressed({
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [month, year];
}
