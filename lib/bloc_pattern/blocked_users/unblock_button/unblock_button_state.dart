import 'package:equatable/equatable.dart';

class UnblockButtonState extends Equatable {
  @override
  List<Object> get props => [];
}

class Initial extends UnblockButtonState {
  @override
  List<Object> get props => [];
}

class Loading extends UnblockButtonState {
  @override
  List<Object> get props => [];
}

class Failed extends UnblockButtonState {
  final error;

  Failed({this.error});

  @override
  List<Object> get props => [];
}

class Success extends UnblockButtonState {
  @override
  List<Object> get props => [];
}