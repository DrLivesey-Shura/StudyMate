import 'dart:convert';

class Avatar {
  final String publicId;
  final String url;

  Avatar({
    required this.publicId,
    required this.url,
  });

  factory Avatar.fromMap(Map<String, dynamic> map) {
    return Avatar(
      publicId: map['public_id'] ?? '',
      url: map['url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'public_id': publicId,
      'url': url,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String token;
  final String role;
  final String password;
  final Avatar avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
    required this.password,
    required this.avatar,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
      role: map['role'] ?? '',
      password: map['password'] ?? '',
      avatar: Avatar.fromMap(map['avatar'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'token': token,
      'role': role,
      'password': password,
      'avatar': avatar.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
