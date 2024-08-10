import 'package:flutter/material.dart';
import 'package:flutter_node_auth/models/user.dart';
import 'package:flutter_node_auth/services/auth_services.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    email: '',
    token: '',
    role: '',
    password: '',
    avatar: Avatar(publicId: '', url: ''),
    subscription: Subscription(id: '', status: ''),
  );

  User get user => _user;

  String get token => _user.token;

  Future<void> fetchUser() async {
    final userData = await AuthService.fetchUserData(token);
    _user = User.fromJson(userData as String);
    notifyListeners();
  }

  void setUser(String user) {
    _user = User.fromJson(user);
    notifyListeners();
  }

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }
}
