// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as String?,
      name: json['name'] as String?,
      username: json['username'] as String?,
      imageUrl: json['imageUrl'] as String?,
      fcmToken: json['fcmToken'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      if (instance.userId case final value?) 'userId': value,
      if (instance.name case final value?) 'name': value,
      if (instance.username case final value?) 'username': value,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      if (instance.fcmToken case final value?) 'fcmToken': value,
    };
