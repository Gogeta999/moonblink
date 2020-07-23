import 'package:equatable/equatable.dart';

abstract class PartnerGameHistoryEvent extends Equatable{
  const PartnerGameHistoryEvent();

  @override
  List<Object> get props => [];
}

class PartnerGameHistoryFetched extends PartnerGameHistoryEvent {}

class PartnerGameHistoryRefreshed extends PartnerGameHistoryEvent {}