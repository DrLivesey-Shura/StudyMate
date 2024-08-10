import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:http/http.dart' as http;
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
    final response =
        await http.get(Uri.parse('${Constants.uri}/api/braintree/token'));
    final data = json.decode(response.body);

    setState(() {
      _clientToken = data['clientToken'];
    });
  }

  Future<void> _startPayment() async {
    if (_clientToken.isEmpty) return;

    var request = BraintreeDropInRequest(
      tokenizationKey: _clientToken,
      collectDeviceData: true,
      googlePaymentRequest: BraintreeGooglePaymentRequest(
        totalPrice: '10.00',
        currencyCode: 'USD',
        billingAddressRequired: false,
      ),
      paypalRequest: BraintreePayPalRequest(
        amount: '10.00',
        displayName: 'StudyMate Company',
      ),
      cardEnabled: true,
    );

    BraintreeDropInResult? result = await BraintreeDropIn.start(request);

    if (result != null) {
      await _sendNonceToServer(result.paymentMethodNonce.nonce);
    } else {
      print('User canceled payment');
    }
  }

  Future<void> _sendNonceToServer(String nonce) async {
    final response = await http.post(
      Uri.parse('${Constants.uri}/api/subscribe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'paymentMethodNonce': nonce}),
    );

    if (response.statusCode == 200) {
      print('Payment successful');
      widget.onPaymentSuccess();
      Navigator.pop(context);
    } else {
      print('Payment failed');
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
        child: ElevatedButton(
          onPressed: _startPayment,
          child: Text('Make Payment'),
        ),
      ),
    );
  }
}
