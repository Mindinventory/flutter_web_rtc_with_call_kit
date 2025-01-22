// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPayload _$NotificationPayloadFromJson(Map<String, dynamic> json) =>
    NotificationPayload(
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      imageUrl: json['imageUrl'] as String?,
      fcmToken: json['fcmToken'] as String?,
      callType: $enumDecodeNullable(_$CallTypeEnumMap, json['callType']),
      callAction: $enumDecodeNullable(_$CallActionEnumMap, json['callAction']),
      notificationId: json['notificationId'] as String?,
      webrtcRoomId: json['webrtcRoomId'] as String?,
    );

Map<String, dynamic> _$NotificationPayloadToJson(
        NotificationPayload instance) =>
    <String, dynamic>{
      if (instance.userId case final value?) 'userId': value,
      if (instance.name case final value?) 'name': value,
      if (instance.username case final value?) 'username': value,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.fcmToken case final value?) 'fcmToken': value,
      if (_$CallTypeEnumMap[instance.callType] case final value?)
        'callType': value,
      if (_$CallActionEnumMap[instance.callAction] case final value?)
        'callAction': value,
      if (instance.notificationId case final value?) 'notificationId': value,
      if (instance.webrtcRoomId case final value?) 'webrtcRoomId': value,
    };

const _$CallTypeEnumMap = {
  CallType.audio: 'audio',
  CallType.video: 'video',
};

const _$CallActionEnumMap = {
  CallAction.create: 'create',
  CallAction.join: 'join',
  CallAction.end: 'end',
};
