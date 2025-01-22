import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class User {
  String? userId;
  String? name;
  String? username;
  String? imageUrl;
  String? fcmToken;

  User({
    this.userId,
    this.name,
    this.username,
    this.imageUrl,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
