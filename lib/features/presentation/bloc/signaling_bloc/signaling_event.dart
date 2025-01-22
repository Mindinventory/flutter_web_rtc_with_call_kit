part of 'signaling_bloc.dart';

abstract class SignalingEvent {}

class CreateRtcRoomEvent extends SignalingEvent {
  MediaStream localStream;
  String roomId;

  CreateRtcRoomEvent({
    required this.localStream,
    required this.roomId,
  });
}

class JoinRtcRoomEvent extends SignalingEvent {
  MediaStream localStream;
  String roomId;

  JoinRtcRoomEvent({
    required this.localStream,
    required this.roomId,
  });
}

class HangUpCallEvent extends SignalingEvent {
  RTCVideoRenderer localRender;
  NotificationPayload payload;

  HangUpCallEvent({
    required this.localRender,
    required this.payload,
  });
}

class SignalingInitialEvent extends SignalingEvent {}

class SignalingConnectingEvent extends SignalingEvent {}

class SignalingConnectedEvent extends SignalingEvent {}

class SignalingDisConnectedEvent extends SignalingEvent {}
