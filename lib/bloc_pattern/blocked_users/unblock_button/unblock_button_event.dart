import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class UnblockButtonEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Reset extends UnblockButtonEvent {
  @override
  List<Object> get props => [];
}

class Remove extends UnblockButtonEvent {
  final int blockUserId;

  Remove({@required this.blockUserId});

  @override
  List<Object> get props => [];
}