
import 'dart:convert';

class UserModel {
  String email;
  String name;
  String profilePic;
  String uid;
  String token;

  UserModel({
    required this.email,
    required this.name,
    required this.profilePic,
    required this.uid,
    required this.token,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    email: map["email"] ?? '',
    name: map["name"] ?? '' ,
    profilePic: map["profilePic"] ?? '',
    uid: map["_id"] ?? '',
    token: map["token"] ?? '',
  );

  Map<String, dynamic> toMap() {
    return {
      "email": email,
      "name": name,
      "profilePic": profilePic,
      "uid": uid,
      "token": token,
    };
  }

  String toJson() => json.encode(toMap());
  factory UserModel.fromJson(String source) => UserModel.fromMap(jsonDecode(source));

  UserModel copyWith({
    String? email,
    String? name,
    String? profilePic,
    String? uid,
    String? token,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      uid: uid ?? this.uid,
      token: token ?? this.token,
    );
  }


}

