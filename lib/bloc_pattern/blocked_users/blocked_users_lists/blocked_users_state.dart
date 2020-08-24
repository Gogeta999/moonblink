import 'package:equatable/equatable.dart';
import 'package:moonblink/models/blocked_user.dart';

abstract class BlockedUsersState extends Equatable{
  const BlockedUsersState();
}

class BlockedUsersInitial extends BlockedUsersState {
  @override
  List<Object> get props => [];
}

class BlockedUsersFailure extends BlockedUsersState {
  final error;

  const BlockedUsersFailure({this.error});

  @override
  List<Object> get props => [];
}

class BlockedUsersNoData extends BlockedUsersState {
  @override
  List<Object> get props => [];
}

class BlockedUsersSuccess extends BlockedUsersState {
  final List<BlockedUser> data;
  final bool hasReachedMax;
  final int page;

  const BlockedUsersSuccess({this.data, this.hasReachedMax, this.page});

  BlockedUsersSuccess copyWith({List<BlockedUser> data, bool hasReachedMax, int page}) {
    return BlockedUsersSuccess(
      data: data ?? this.data,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'BlockedUsersSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}