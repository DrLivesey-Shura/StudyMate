import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:js/js.dart';
import '../utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  final Function onPaymentSuccess;

  PaymentScreen({required this.onPaymentSuccess});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _clientToken = '';

  @override
  void initState() {
    super.initState();
    _fetchClientToken();
  }

  Future<void> _fetchClientToken() async {
    try {
      final response =
          await http.get(Uri.parse('${Constants.uri}/api/braintree/token'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _clientToken = data['token'];
          print('Client token fetched successfully: $_clientToken');
        });

        Future.delayed(Duration(milliseconds: 500), () {
          _setupBraintree();
        });
      } else {
        throw Exception('Failed to fetch client token');
      }
    } catch (e) {
      print('Error fetching client token: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching client token: $e')),
      );
    }
  }

  void _setupBraintree() {
    final script = html.ScriptElement()
      ..src =
          "https://js.braintreegateway.com/web/dropin/1.32.0/js/dropin.min.js"
      ..type = "text/javascript"
      ..async = true;

    html.document.body!.append(script);

    script.onLoad.listen((_) {
      html.window.console.log("Braintree script loaded.");

      // Ensure the Braintree container exists
      var dropinContainer = html.document.getElementById('dropin-container');

      if (dropinContainer == null) {
        // Create the container if it does not exist
        dropinContainer = html.DivElement()..id = 'dropin-container';
        html.document.body!.append(dropinContainer);
      }

      var submitButton = html.document.getElementById('submit-button');
      if (submitButton == null) {
        submitButton = html.ButtonElement()
          ..id = 'submit-button'
          ..text = 'Make Payment'
          ..style.marginTop = '20px';
        dropinContainer.append(submitButton);
      }

      createDropin(_clientToken,
          allowInterop((dynamic error, dynamic instance) {
        if (error != null) {
          print('Error creating Drop-in UI: $error');
          return;
        }

        if (instance == null) {
          print('Instance is null');
          return;
        }

        submitButton!.onClick.listen((event) {
          instance.requestPaymentMethod(
              allowInterop((dynamic error, dynamic payload) {
            if (error != null) {
              print('Error requesting payment method: $error');
              return;
            }

            if (payload == null) {
              print('Payload is null');
              return;
            }

            print('Payment method nonce received: ${payload.nonce}');
            _sendNonceToServer(payload.nonce);
          }));
        });
      }));
    });
  }

  Future<void> _sendNonceToServer(String nonce) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/subscribe'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'paymentMethodNonce': nonce}),
      );

      if (response.statusCode == 200) {
        print('Payment successful');
        widget.onPaymentSuccess();
      } else {
        print('Payment failed with status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed. Please try again.')),
        );
      }
    } catch (e) {
      print('Error sending nonce to server: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              key: Key('braintree-container'),
              height: 400,
              width: 300,
              child:
                  Placeholder(), // Just a placeholder; real elements are managed in the DOM
            ),
            // The submit button will be created directly in the DOM
          ],
        ),
      ),
    );
  }
}

@JS()
external void createDropin(String token, Function callback);
