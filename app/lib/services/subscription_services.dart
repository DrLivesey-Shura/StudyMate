import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_node_auth/utils/constants.dart';

class SubscribeService {
  static Future<void> subscribe(String token) async {
    final response = await http.post(
      Uri.parse('${Constants.uri}/api/subscribe'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'paymentMethodNonce': 'fake-valid-nonce'}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to subscribe');
    }
  }

  static Future<void> cancelSubscription(String token) async {
    final response = await http.delete(
      Uri.parse('${Constants.uri}/api/subscribe/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel subscription');
    }
  }
}
