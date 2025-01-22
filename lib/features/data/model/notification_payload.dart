import 'package:json_annotation/json_annotation.dart';

part 'notification_payload.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class NotificationPayload {
  String? userId;
  String? name;
  String? username;
  String? imageUrl;
  String? fcmToken;
  CallType? callType;
  CallAction? callAction;
  String? notificationId;
  String? webrtcRoomId;

  NotificationPayload({
    this.userId,
    this.name,
    this.username,
    this.imageUrl,
    this.fcmToken,
    this.callType,
    this.callAction,
    this.notificationId,
    this.webrtcRoomId,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPayloadToJson(this);
}

enum CallType { audio, video }

enum CallAction { create, join, end }
