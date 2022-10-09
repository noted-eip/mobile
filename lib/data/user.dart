// import 'package:json_annotation/json_annotation.dart';

// part 'user_info.g.dart';

class User {
  final String username;
  final String email;
  final String token;
  final String id;

  User(
      {required this.username,
      required this.token,
      required this.id,
      required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      token: json['token'],
      id: json['id'],
      email: json['email'],
    );
  }
}

// @JsonSerializable()
// class UserInfo {
//   String name;
//   String job;
//   String? id;
//   String? createdAt;
//   String? updatedAt;

//   UserInfo({
//     required this.name,
//     required this.job,
//     this.id,
//     this.createdAt,
//     this.updatedAt,
//   });

//   factory UserInfo.fromJson(Map<String, dynamic> json) =>
//       _$UserInfoFromJson(json);
//   Map<String, dynamic> toJson() => _$UserInfoToJson(this);
// }
