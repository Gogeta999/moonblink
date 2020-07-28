import 'package:equatable/equatable.dart';

abstract class UserTransactionEvent extends Equatable{
  const UserTransactionEvent();

  @override
  List<Object> get props => [];
}

class UserTransactionFetched extends UserTransactionEvent {}

class UserTransactionRefreshed extends UserTransactionEvent {}