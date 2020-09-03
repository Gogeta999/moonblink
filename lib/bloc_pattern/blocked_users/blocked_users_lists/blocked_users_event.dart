import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

abstract class BlockedUsersEvent extends Equatable{
  const BlockedUsersEvent();

  @override
  List<Object> get props => [];
}

class BlockedUsersFetched extends BlockedUsersEvent {}

class BlockedUsersRefreshed extends BlockedUsersEvent {}

class BlockedUsersRemoved extends BlockedUsersEvent {
  final int index;

  const BlockedUsersRemoved({@required this.index});

  @override
  List<Object> get props => [index];
}