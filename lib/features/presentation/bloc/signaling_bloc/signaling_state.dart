part of 'signaling_bloc.dart';

abstract class SignalingState {}

class SignalingInitialState extends SignalingState {}

class SignalingFailureState extends SignalingState {}

class SignalingConnectingState extends SignalingState {}

class SignalingConnectedState extends SignalingState {}

class SignalingDisconnectedState extends SignalingState {}
