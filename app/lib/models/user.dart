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

class Subscription {
  final String id;
  final String status;

  Subscription({
    required this.id,
    required this.status,
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
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
  final Subscription? subscription;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.role,
    required this.password,
    required this.avatar,
    this.subscription,
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
      subscription: map['subscription'] != null
          ? Subscription.fromMap(map['subscription'])
          : null,
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
      'subscription': subscription?.toMap(), // Nullable check
    };
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
