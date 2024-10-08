import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/models/user.dart';
import 'package:test/providers/user_provider.dart';
import 'package:test/screens/home_screen.dart';
import 'package:test/screens/signup_screen.dart';
import 'package:test/utils/constants.dart';
import 'package:test/utils/utils.dart';

class AuthService {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required Uint8List avatarBytes,
    required String fileName,
  }) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${Constants.uri}/api/register'));
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['name'] = name;
      request.files.add(http.MultipartFile.fromBytes('file', avatarBytes,
          filename: fileName));
      var res = await request.send();

      if (res.statusCode == 201) {
        showSnackBar(
            context, 'Account created! Login with the same credentials!');
      } else {}
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/login'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          final data = jsonDecode(res.body);

          if (data != null && data['user'] != null && data['token'] != null) {
            final userJson = jsonEncode(data['user']);
            final user = User.fromMap(data['user']);
            final token = data['token'];

            userProvider.setUserFromModel(user.copyWith(token: token));

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('x-auth-token', token);

            navigator.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
              (route) => false,
            );
          } else {
            throw Exception('User data or token is missing in the response');
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void getUserData(
    BuildContext context,
  ) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        prefs.setString('x-auth-token', '');
      } else {
        var tokenRes = await http.post(
          Uri.parse('${Constants.uri}/api/tokenIsValid'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token,
          },
        );

        var response = jsonDecode(tokenRes.body);

        if (response == true) {
          http.Response userRes = await http.get(
            Uri.parse('${Constants.uri}/'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token,
            },
          );

          userProvider.setUserFromModel(
              User.fromMap(jsonDecode(userRes.body)).copyWith(token: token));
        }
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  static Future<Map<String, dynamic>> fetchUserData(String token) async {
    final response = await http.get(
      Uri.parse('${Constants.uri}/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user data');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', '');
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
      (route) => false,
    );
  }
}
