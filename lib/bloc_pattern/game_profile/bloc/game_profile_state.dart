part of 'game_profile_bloc.dart';

abstract class GameProfileState extends Equatable {
  const GameProfileState();
  
  @override
  List<Object> get props => [];
}

class GameProfileInitial extends GameProfileState {}
