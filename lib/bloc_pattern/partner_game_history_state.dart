import 'package:equatable/equatable.dart';

abstract class PartnerGameHistoryState extends Equatable{
  const PartnerGameHistoryState();
}

class PartnerGameHistoryInitial extends PartnerGameHistoryState {
  @override
  List<Object> get props => [];
}

class PartnerGameHistoryFailure extends PartnerGameHistoryState {
  @override
  List<Object> get props => [];
}

class PartnerGameHistorySuccess extends PartnerGameHistoryState {
  final List<String> data;
  final bool hasReachedMax;
  final int page;

  const PartnerGameHistorySuccess({this.data, this.hasReachedMax, this.page});

  PartnerGameHistorySuccess copyWith({List<String> data, bool hasReachedMax, int page}) {
    return PartnerGameHistorySuccess(
      data: data ?? this.data,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page
    );
  }

  @override
  List<Object> get props => [data, hasReachedMax];

  @override
  String toString() => 'PartnerGameHistorySuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}
