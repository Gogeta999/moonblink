import 'package:equatable/equatable.dart';
import 'package:moonblink/models/transaction.dart';

abstract class UserTransactionState extends Equatable{
  const UserTransactionState();
}

class UserTransactionInitial extends UserTransactionState {
  @override
  List<Object> get props => [];
}

class UserTransactionFailure extends UserTransactionState {
  final error;

  const UserTransactionFailure({this.error});

  @override
  List<Object> get props => [];
}

class UserTransactionNoData extends UserTransactionState {
  @override
  List<Object> get props => [];
}

class UserTransactionSuccess extends UserTransactionState {
  final List<Transaction> data;
  final bool hasReachedMax;
  final int page;

  const UserTransactionSuccess({this.data, this.hasReachedMax, this.page});

  UserTransactionSuccess copyWith({List<Transaction> data, bool hasReachedMax, int page}) {
    return UserTransactionSuccess(
        data: data ?? this.data,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        page: page ?? this.page
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'UserTransactionSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}
